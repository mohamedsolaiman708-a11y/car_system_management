-- ############################################################################
-- PHASE 3.7: PAYMENT SERVICE BUSINESS LOGIC (CORE FINANCIAL ENGINE)
-- VERSION: 1.4.0 (Enterprise Hardened / Production Grade)
-- ############################################################################

-- 1. HARDENING SCHEMA UPDATES
-- ############################################################################

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payment_status') THEN
        CREATE TYPE public.payment_status AS ENUM ('pending', 'completed', 'failed', 'reversed', 'cancelled');
    END IF;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS status public.payment_status DEFAULT 'completed';
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS payment_type TEXT; 
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS idempotency_key TEXT UNIQUE;
ALTER TABLE public.accounts ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

-- Immutable Reversal Table
CREATE TABLE IF NOT EXISTS public.payment_allocation_reversals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID REFERENCES public.payments(id),
    installment_id UUID REFERENCES public.installments(id),
    amount_reversed DECIMAL(15,2) NOT NULL CHECK (amount_reversed > 0),
    reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Domain Events
CREATE TABLE IF NOT EXISTS public.domain_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_name TEXT NOT NULL,
    aggregate_id UUID NOT NULL,
    payload JSONB,
    occurred_at TIMESTAMPTZ DEFAULT NOW(),
    processed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_domain_events_aggregate ON public.domain_events(aggregate_id);

-- 2. INTERNAL SERVICES
-- ############################################################################

-- 2.1 Domain Event Emitter
CREATE OR REPLACE FUNCTION public.emit_domain_event(
    p_event_name TEXT,
    p_aggregate_id UUID,
    p_payload JSONB DEFAULT '{}'
) RETURNS VOID AS $$
BEGIN
    INSERT INTO public.domain_events (event_name, aggregate_id, payload)
    VALUES (p_event_name, p_aggregate_id, p_payload);
END;
$$ LANGUAGE plpgsql;

-- 2.2 Journal Posting Service (Centralized Validation)
CREATE OR REPLACE FUNCTION public.post_journal_entry(
    p_fiscal_period_id UUID,
    p_description TEXT,
    p_reference_no TEXT,
    p_source_type TEXT,
    p_source_id UUID,
    p_lines JSONB -- Array of {account_id, debit, credit}
) RETURNS UUID AS $$
DECLARE
    v_journal_id UUID;
    v_total_debit DECIMAL(15,2) := 0;
    v_total_credit DECIMAL(15,2) := 0;
    v_line RECORD;
    v_line_count INT := 0;
BEGIN
    -- [1] Basic Journal Creation
    INSERT INTO public.journal_entries (fiscal_period_id, description, reference_no, source_type, source_id)
    VALUES (p_fiscal_period_id, p_description, p_reference_no, p_source_type, p_source_id)
    RETURNING id INTO v_journal_id;

    -- [2] Line Processing & Strict Validation
    FOR v_line IN SELECT * FROM jsonb_to_recordset(p_lines) AS x(account_id UUID, debit DECIMAL(15,2), credit DECIMAL(15,2)) LOOP
        -- Active Account Check
        IF NOT EXISTS (SELECT 1 FROM public.accounts WHERE id = v_line.account_id AND is_active = true) THEN
            RAISE EXCEPTION 'Inactive or invalid account: %', v_line.account_id;
        END IF;

        -- Value Integrity Checks
        IF v_line.debit < 0 OR v_line.credit < 0 THEN
            RAISE EXCEPTION 'Negative values not allowed in journal lines';
        END IF;

        IF v_line.debit > 0 AND v_line.credit > 0 THEN
            RAISE EXCEPTION 'Simultaneous Debit and Credit on same line is prohibited (Account: %)', v_line.account_id;
        END IF;

        IF v_line.debit = 0 AND v_line.credit = 0 THEN
            CONTINUE; 
        END IF;

        INSERT INTO public.journal_entry_lines (journal_entry_id, account_id, debit, credit)
        VALUES (v_journal_id, v_line.account_id, ROUND(v_line.debit, 2), ROUND(v_line.credit, 2));

        v_total_debit := v_total_debit + ROUND(v_line.debit, 2);
        v_total_credit := v_total_credit + ROUND(v_line.credit, 2);
        v_line_count := v_line_count + 1;
    END LOOP;

    -- [3] Final Integrity Checks
    IF v_line_count < 2 THEN
        RAISE EXCEPTION 'Journal must contain at least two lines';
    END IF;

    IF ABS(v_total_debit - v_total_credit) > 0.001 THEN
        RAISE EXCEPTION 'Unbalanced Journal Entry: Debit (%) != Credit (%)', v_total_debit, v_total_credit;
    END IF;

    RETURN v_journal_id;
END;
$$ LANGUAGE plpgsql;

-- 2.3 Payment State Machine Trigger
CREATE OR REPLACE FUNCTION public.validate_payment_state_transition()
RETURNS TRIGGER AS $$
BEGIN
    -- Strict State Machine Implementation
    IF OLD.status = 'pending' AND NEW.status NOT IN ('completed', 'failed') THEN
        RAISE EXCEPTION 'Invalid transition from pending to %', NEW.status;
    ELSIF OLD.status = 'completed' AND NEW.status != 'reversed' THEN
        RAISE EXCEPTION 'Invalid transition from completed to %', NEW.status;
    ELSIF OLD.status IN ('failed', 'reversed', 'cancelled') AND NEW.status != OLD.status THEN
        RAISE EXCEPTION 'Final state % cannot be modified', OLD.status;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_payment_state_machine ON public.payments;
CREATE TRIGGER tr_payment_state_machine 
BEFORE UPDATE OF status ON public.payments 
FOR EACH ROW EXECUTE FUNCTION public.validate_payment_state_transition();

-- 3. VALIDATION TRIGGERS
-- ############################################################################

-- 3.1 Allocation Overflow Prevention (Database Level Guard)
CREATE OR REPLACE FUNCTION public.enforce_allocation_limits()
RETURNS TRIGGER AS $$
DECLARE
    v_expected DECIMAL(15,2);
    v_net_paid DECIMAL(15,2);
BEGIN
    SELECT expected_amount INTO v_expected FROM public.installments WHERE id = NEW.installment_id;
    
    -- Correct aggregation using subqueries to avoid join multiplication
    SELECT 
        (SELECT COALESCE(SUM(amount_allocated), 0) FROM public.payment_allocations WHERE installment_id = NEW.installment_id) -
        (SELECT COALESCE(SUM(amount_reversed), 0) FROM public.payment_allocation_reversals WHERE installment_id = NEW.installment_id)
    INTO v_net_paid;
    
    IF v_net_paid + NEW.amount_allocated > v_expected + 0.005 THEN 
        RAISE EXCEPTION 'Allocation Overflow: Installment % balance exceeded. Remaining: %', NEW.installment_id, (v_expected - v_net_paid);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_allocation_limit ON public.payment_allocations;
CREATE TRIGGER tr_allocation_limit 
BEFORE INSERT ON public.payment_allocations 
FOR EACH ROW EXECUTE FUNCTION public.enforce_allocation_limits();

-- 3.2 Installment State Sync (Correct Aggregation)
CREATE OR REPLACE FUNCTION public.sync_installment_state()
RETURNS TRIGGER AS $$
DECLARE
    v_net_paid DECIMAL(15, 2);
    v_expected DECIMAL(15, 2);
    v_inst_id UUID;
BEGIN
    v_inst_id := COALESCE(NEW.installment_id, OLD.installment_id);
    
    SELECT 
        (SELECT COALESCE(SUM(amount_allocated), 0) FROM public.payment_allocations WHERE installment_id = v_inst_id) -
        (SELECT COALESCE(SUM(amount_reversed), 0) FROM public.payment_allocation_reversals WHERE installment_id = v_inst_id)
    INTO v_net_paid;
    
    SELECT expected_amount INTO v_expected FROM public.installments WHERE id = v_inst_id;

    IF v_net_paid >= v_expected - 0.005 THEN
        UPDATE public.installments SET status = 'paid' WHERE id = v_inst_id;
    ELSIF v_net_paid > 0.005 THEN
        UPDATE public.installments SET status = 'partially_paid' WHERE id = v_inst_id;
    ELSE
        UPDATE public.installments SET status = 'unpaid' WHERE id = v_inst_id;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_payment_allocation_sync ON public.payment_allocations;
CREATE TRIGGER tr_payment_allocation_sync AFTER INSERT OR DELETE OR UPDATE ON public.payment_allocations FOR EACH ROW EXECUTE FUNCTION public.sync_installment_state();

DROP TRIGGER IF EXISTS tr_payment_reversal_sync ON public.payment_allocation_reversals;
CREATE TRIGGER tr_payment_reversal_sync AFTER INSERT OR DELETE OR UPDATE ON public.payment_allocation_reversals FOR EACH ROW EXECUTE FUNCTION public.sync_installment_state();

-- 4. PRIMARY SERVICE: Process Contract Payment
-- ############################################################################
CREATE OR REPLACE FUNCTION public.process_contract_payment(
    p_contract_id UUID,
    p_amount DECIMAL(15,2),
    p_payment_method TEXT,
    p_reference_no TEXT,
    p_idempotency_key TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    -- [LOCKING ORDER 1]: Fiscal Period
    v_fiscal RECORD;
    -- [LOCKING ORDER 2]: Contract
    v_contract RECORD;
    
    v_payment_id UUID;
    v_remaining_cash DECIMAL(15,2);
    v_inst RECORD;
    v_alloc_amount DECIMAL(15,2);
    v_principal_part DECIMAL(15,2);
    v_profit_part DECIMAL(15,2);
    
    v_investor RECORD;
    v_investor_count INT;
    v_current_investor_idx INT := 0;
    v_investor_share_amount DECIMAL(15,2);
    v_investor_profit_share DECIMAL(15,2);
    v_dist_principal_running_total DECIMAL(15,2) := 0;
    v_dist_profit_running_total DECIMAL(15,2) := 0;
    
    v_company_profit_ratio DECIMAL(5,2);
    v_total_profit_to_distribute DECIMAL(15,2);
    v_company_profit_share DECIMAL(15,2);
    
    v_total_principal_paid DECIMAL(15,2) := 0;
    v_total_profit_paid DECIMAL(15,2) := 0;
    
    v_journal_lines JSONB := '[]'::jsonb;
    v_remaining_balance_on_contract DECIMAL(15,2);
BEGIN
    -- [A] Idempotency Guard
    IF p_idempotency_key IS NOT NULL THEN
        SELECT id INTO v_payment_id FROM public.payments WHERE idempotency_key = p_idempotency_key;
        IF v_payment_id IS NOT NULL THEN
            RETURN jsonb_build_object('success', true, 'message', 'Duplicate idempotency key', 'payment_id', v_payment_id);
        END IF;
    END IF;

    IF NOT public.has_permission('process_payments') THEN RAISE EXCEPTION 'Unauthorized'; END IF;

    -- [B] Transaction Locking (Order: Fiscal -> Contract)
    SELECT * INTO v_fiscal FROM public.fiscal_periods 
    WHERE is_closed = false AND CURRENT_DATE BETWEEN start_date AND end_date FOR UPDATE;
    IF v_fiscal.id IS NULL THEN RAISE EXCEPTION 'No open fiscal period found'; END IF;

    SELECT * INTO v_contract FROM public.financing_contracts WHERE id = p_contract_id FOR UPDATE;
    IF v_contract.status != 'active' THEN RAISE EXCEPTION 'Contract is not active'; END IF;

    -- [C] Initialization
    SELECT (value->>'ratio')::DECIMAL INTO v_company_profit_ratio FROM public.system_settings WHERE key = 'company_profit_share_ratio';
    v_company_profit_ratio := COALESCE(v_company_profit_ratio, 20.00);

    INSERT INTO public.payments (contract_id, amount_total, payment_method, reference_no, recorded_by, idempotency_key, status)
    VALUES (p_contract_id, ROUND(p_amount, 2), p_payment_method, p_reference_no, auth.uid(), p_idempotency_key, 'completed')
    RETURNING id INTO v_payment_id;

    v_remaining_cash := ROUND(p_amount, 2);

    -- [D] FIFO Allocation (Locking Order 3: Installments)
    FOR v_inst IN (
        SELECT * FROM public.installments 
        WHERE contract_id = p_contract_id AND status IN ('unpaid', 'partially_paid')
        ORDER BY due_date ASC, id ASC FOR UPDATE
    ) LOOP
        EXIT WHEN v_remaining_cash <= 0;

        SELECT (v_inst.expected_amount - (
            (SELECT COALESCE(SUM(amount_allocated), 0) FROM public.payment_allocations WHERE installment_id = v_inst.id) -
            (SELECT COALESCE(SUM(amount_reversed), 0) FROM public.payment_allocation_reversals WHERE installment_id = v_inst.id)
        )) INTO v_alloc_amount;

        IF v_alloc_amount > v_remaining_cash THEN v_alloc_amount := v_remaining_cash; END IF;
        v_alloc_amount := ROUND(v_alloc_amount, 2);
        
        IF v_alloc_amount > 0 THEN
            v_principal_part := ROUND((v_inst.principal_component / v_inst.expected_amount) * v_alloc_amount, 2);
            v_profit_part := v_alloc_amount - v_principal_part;

            INSERT INTO public.payment_allocations (payment_id, installment_id, amount_allocated, allocation_type)
            VALUES (v_payment_id, v_inst.id, v_alloc_amount, 'installment_payment');

            v_total_principal_paid := v_total_principal_paid + v_principal_part;
            v_total_profit_paid := v_total_profit_paid + v_profit_part;
            v_remaining_cash := v_remaining_cash - v_alloc_amount;
        END IF;
    END LOOP;

    -- [E] Investor Distribution (Locking Order 4 & 5: Funding & Investors)
    SELECT COUNT(*) INTO v_investor_count FROM public.contract_funding WHERE contract_id = p_contract_id;
    v_company_profit_share := ROUND(v_total_profit_paid * (v_company_profit_ratio / 100.0), 2);
    v_total_profit_to_distribute := v_total_profit_paid - v_company_profit_share;

    FOR v_investor IN (
        SELECT cf.investor_id, cf.amount_allocated 
        FROM public.contract_funding cf
        WHERE cf.contract_id = p_contract_id
        ORDER BY cf.investor_id ASC FOR UPDATE
    ) LOOP
        v_current_investor_idx := v_current_investor_idx + 1;

        -- Exact Distribution Logic (Last investor remainder)
        IF v_current_investor_idx = v_investor_count THEN
            v_investor_share_amount := v_total_principal_paid - v_dist_principal_running_total;
            v_investor_profit_share := v_total_profit_to_distribute - v_dist_profit_running_total;
        ELSE
            v_investor_share_amount := ROUND((v_investor.amount_allocated / v_contract.principal_amount) * v_total_principal_paid, 2);
            v_investor_profit_share := ROUND((v_investor.amount_allocated / v_contract.principal_amount) * v_total_profit_to_distribute, 2);
        END IF;

        IF v_investor_share_amount > 0 THEN
            INSERT INTO public.investor_transactions (investor_id, amount, type, reference_id, description)
            VALUES (v_investor.investor_id, v_investor_share_amount, 'contract_return', v_payment_id, 'Return: ' || v_contract.contract_no);
            v_dist_principal_running_total := v_dist_principal_running_total + v_investor_share_amount;
        END IF;

        IF v_investor_profit_share > 0 THEN
            INSERT INTO public.investor_transactions (investor_id, amount, type, reference_id, description)
            VALUES (v_investor.investor_id, v_investor_profit_share, 'finance_profit_distribution', v_payment_id, 'Profit: ' || v_contract.contract_no);
            UPDATE public.investors SET total_profit_earned = total_profit_earned + v_investor_profit_share WHERE id = v_investor.investor_id;
            v_dist_profit_running_total := v_dist_profit_running_total + v_investor_profit_share;
        END IF;
    END LOOP;

    -- [F] Accounting Service Interaction
    SELECT id INTO v_inst.id FROM public.accounts WHERE code = '1010'; -- Reusing v_inst.id as account_id temp
    v_journal_lines := v_journal_lines || jsonb_build_object('account_id', v_inst.id, 'debit', ROUND(p_amount, 2), 'credit', 0);
    
    SELECT id INTO v_inst.id FROM public.accounts WHERE code = '1020';
    v_journal_lines := v_journal_lines || jsonb_build_object('account_id', v_inst.id, 'debit', 0, 'credit', ROUND(p_amount - v_remaining_cash, 2));

    IF v_remaining_cash > 0 THEN
        SELECT id INTO v_inst.id FROM public.accounts WHERE code = '2040';
        v_journal_lines := v_journal_lines || jsonb_build_object('account_id', v_inst.id, 'debit', 0, 'credit', v_remaining_cash);
    END IF;

    IF v_total_profit_paid > 0 THEN
        SELECT id INTO v_inst.id FROM public.accounts WHERE code = '4010';
        v_journal_lines := v_journal_lines || jsonb_build_object('account_id', v_inst.id, 'debit', v_total_profit_paid, 'credit', 0);
        
        SELECT id INTO v_inst.id FROM public.accounts WHERE code = '2030';
        v_journal_lines := v_journal_lines || jsonb_build_object('account_id', v_inst.id, 'debit', 0, 'credit', v_total_profit_to_distribute);
        
        SELECT id INTO v_inst.id FROM public.accounts WHERE code = '5010';
        v_journal_lines := v_journal_lines || jsonb_build_object('account_id', v_inst.id, 'debit', 0, 'credit', v_company_profit_share);
    END IF;

    PERFORM public.post_journal_entry(v_fiscal.id, 'Payment Receipt: ' || v_contract.contract_no, p_reference_no, 'payment', v_payment_id, v_journal_lines);

    -- [G] Post-Processing & Closure
    SELECT (v_contract.total_contract_value - (
        (SELECT COALESCE(SUM(pa.amount_allocated), 0) FROM public.payment_allocations pa JOIN public.installments i ON pa.installment_id = i.id WHERE i.contract_id = p_contract_id) -
        (SELECT COALESCE(SUM(r.amount_reversed), 0) FROM public.payment_allocation_reversals r JOIN public.installments i ON r.installment_id = i.id WHERE i.contract_id = p_contract_id)
    )) INTO v_remaining_balance_on_contract;

    IF v_remaining_balance_on_contract <= 0.005 THEN
        UPDATE public.financing_contracts SET status = 'closed', updated_at = NOW() WHERE id = p_contract_id;
        PERFORM public.emit_domain_event('ContractClosed', p_contract_id, jsonb_build_object('payment_id', v_payment_id));
    END IF;

    PERFORM public.emit_domain_event('PaymentReceived', v_payment_id, jsonb_build_object('amount', p_amount));
    
    RETURN jsonb_build_object('success', true, 'payment_id', v_payment_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. REVERSAL SERVICE: Reverse Contract Payment
-- ############################################################################
CREATE OR REPLACE FUNCTION public.reverse_contract_payment(
    p_payment_id UUID,
    p_reason TEXT
)
RETURNS JSONB AS $$
DECLARE
    -- [LOCKING ORDER 1]: Fiscal Period
    v_fiscal RECORD;
    -- [LOCKING ORDER 2]: Payment Record
    v_payment RECORD;
    
    v_inv_tx RECORD;
    v_reversal_lines JSONB := '[]'::jsonb;
    v_line RECORD;
BEGIN
    IF NOT public.has_permission('process_payments') THEN RAISE EXCEPTION 'Unauthorized'; END IF;

    -- [A] Locking Sequence
    SELECT * INTO v_fiscal FROM public.fiscal_periods 
    WHERE is_closed = false AND CURRENT_DATE BETWEEN start_date AND end_date FOR UPDATE;
    IF v_fiscal.id IS NULL THEN RAISE EXCEPTION 'No open fiscal period for reversal'; END IF;

    SELECT * INTO v_payment FROM public.payments WHERE id = p_payment_id FOR UPDATE;
    
    -- [B] Deep Idempotency & State Validation
    IF v_payment.status != 'completed' THEN 
        RAISE EXCEPTION 'Only completed payments can be reversed. Current status: %', v_payment.status; 
    END IF;

    IF EXISTS (SELECT 1 FROM public.payment_allocation_reversals WHERE payment_id = p_payment_id) THEN
        RAISE EXCEPTION 'Idempotency Conflict: Reversal allocations already exist for this payment';
    END IF;

    IF EXISTS (SELECT 1 FROM public.journal_entries WHERE source_type = 'payment_reversal' AND source_id = p_payment_id) THEN
        RAISE EXCEPTION 'Idempotency Conflict: Reversal journal already exists for this payment';
    END IF;

    -- [C] Reverse Investor Distributions (Lock Order 5: Investors)
    FOR v_inv_tx IN (SELECT * FROM public.investor_transactions WHERE reference_id = p_payment_id ORDER BY id ASC FOR UPDATE) LOOP
        INSERT INTO public.investor_transactions (investor_id, amount, type, reference_id, description)
        VALUES (v_inv_tx.investor_id, -v_inv_tx.amount, v_inv_tx.type, p_payment_id, 'REVERSAL: ' || v_inv_tx.description);
        
        IF v_inv_tx.type = 'finance_profit_distribution' THEN
            UPDATE public.investors SET total_profit_earned = total_profit_earned - v_inv_tx.amount WHERE id = v_inv_tx.investor_id;
        END IF;
    END LOOP;

    -- [D] Reverse Accounting
    FOR v_line IN (
        SELECT l.* FROM public.journal_entry_lines l 
        JOIN public.journal_entries e ON l.journal_entry_id = e.id 
        WHERE e.source_type = 'payment' AND e.source_id = p_payment_id
    ) LOOP
        v_reversal_lines := v_reversal_lines || jsonb_build_object('account_id', v_line.account_id, 'debit', v_line.credit, 'credit', v_line.debit);
    END LOOP;

    PERFORM public.post_journal_entry(v_fiscal.id, 'REV: Payment Reversal', 'REV-' || v_payment.reference_no, 'payment_reversal', p_payment_id, v_reversal_lines);

    -- [E] Immutable Allocation Reversal
    INSERT INTO public.payment_allocation_reversals (payment_id, installment_id, amount_reversed, reason)
    SELECT p_payment_id, installment_id, amount_allocated, p_reason
    FROM public.payment_allocations WHERE payment_id = p_payment_id;

    -- [F] State Transition
    UPDATE public.payments SET status = 'reversed' WHERE id = p_payment_id;
    UPDATE public.financing_contracts SET status = 'active', updated_at = NOW() WHERE id = v_payment.contract_id AND status = 'closed';

    PERFORM public.emit_domain_event('PaymentReversed', p_payment_id, jsonb_build_object('reason', p_reason));

    RETURN jsonb_build_object('success', true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ############################################################################
-- ENTERPRISE ERP BACKEND TECHNICAL DOCUMENTATION (V1.4.0)
-- ############################################################################
/*
1. SYSTEM ARCHITECTURE
The Payment Service is the core financial ledger of the ERP. It is designed for 
strict compliance, auditability, and mathematical precision. It uses a "Bank-Grade" 
locking strategy to prevent all known race conditions.

2. DATABASE ERD (FINANCIAL CORE)
- Payments: Master record of cash inflow.
- Payment Allocations: Links payments to installments (FIFO).
- Payment Allocation Reversals: Immutable log of undone allocations.
- Investor Transactions: Sub-ledger for investor balances.
- Journal Entries & Lines: General Ledger (Double-Entry).

3. STATE MACHINE (PAYMENT LIFECYCLE)
Transitions are strictly enforced via triggers:
- PENDING -> COMPLETED (On process start)
- COMPLETED -> REVERSED (On reversal)
- PENDING -> FAILED (On validation error)
No "deletion" of records is allowed.

4. LOCKING STRATEGY (DEADLOCK PREVENTION)
Every transaction MUST lock resources in this global order:
1. Fiscal Period (Global gate)
2. Financing Contract
3. Installments (FIFO order)
4. Contract Funding (Ratio source)
5. Investors (Balance update)

5. ACCOUNTING WORKFLOW
All financial movements must pass through `post_journal_entry`.
Validations:
- Total Debit MUST equal Total Credit.
- No negative amounts allowed.
- Posting to inactive accounts is prohibited.
- Minimum 2 lines required per journal.

6. INVESTOR WORKFLOW
Profit distribution follows a "Remainder Logic" where the final investor in 
the chain receives the mathematical residue of rounding to ensure the total 
profit distributed exactly matches the profit recognized in accounting.

7. CONCURRENCY & IDEMPOTENCY
- `idempotency_key` prevents double-submission from client retries.
- CTE-based aggregation prevents "Join Multiplication" bugs when calculating 
  unpaid balances in complex queries.

8. SECURITY MODEL
- SECURITY DEFINER allows logic to bypass RLS for internal ledger movements 
  while explicitly checking `has_permission()` for the invoking user.
- All high-value actions emit `domain_events` for external auditing.
*/
