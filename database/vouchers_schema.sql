-- ============================================================================
-- VOUCHERS SCHEMA & FINANCIAL INTEGRATION LOGIC
-- ============================================================================

-- 1. Create Vouchers Table
CREATE TABLE IF NOT EXISTS public.vouchers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    voucher_number TEXT UNIQUE NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('receipt', 'payment')),
    party_type TEXT NOT NULL DEFAULT 'general' CHECK (party_type IN ('investor', 'customer', 'general')),
    entity_id UUID,
    party_name TEXT NOT NULL,
    amount DECIMAL(15,2) NOT NULL CHECK (amount > 0),
    payment_method TEXT NOT NULL DEFAULT 'cash' CHECK (payment_method IN ('cash', 'cheque')),
    cheque_number TEXT,
    bank_name TEXT,
    purpose TEXT NOT NULL,
    voucher_date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.vouchers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated users full access to vouchers" ON public.vouchers;
CREATE POLICY "Allow authenticated users full access to vouchers" 
ON public.vouchers FOR ALL TO authenticated USING (true) WITH CHECK (true);

GRANT ALL ON public.vouchers TO authenticated;

-- 2. Function to generate sequential voucher numbers (e.g., REC-2026-0001, PAY-2026-0001)
CREATE OR REPLACE FUNCTION public.generate_voucher_number(p_type TEXT)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_prefix TEXT;
    v_year TEXT;
    v_count INT;
    v_voucher_num TEXT;
BEGIN
    IF p_type = 'receipt' THEN
        v_prefix := 'REC';
    ELSE
        v_prefix := 'PAY';
    END IF;

    v_year := EXTRACT(YEAR FROM CURRENT_DATE)::TEXT;

    SELECT COUNT(*) + 1 INTO v_count
    FROM public.vouchers
    WHERE type = p_type
      AND EXTRACT(YEAR FROM voucher_date)::TEXT = v_year;

    v_voucher_num := v_prefix || '-' || v_year || '-' || LPAD(v_count::TEXT, 4, '0');

    -- Ensure uniqueness in case of concurrent calls
    WHILE EXISTS (SELECT 1 FROM public.vouchers WHERE voucher_number = v_voucher_num) LOOP
        v_count := v_count + 1;
        v_voucher_num := v_prefix || '-' || v_year || '-' || LPAD(v_count::TEXT, 4, '0');
    END LOOP;

    RETURN v_voucher_num;
END;
$$;

GRANT EXECUTE ON FUNCTION public.generate_voucher_number(TEXT) TO authenticated;

-- 3. RPC to Create Voucher and automatically apply financial impact if investor is selected
CREATE OR REPLACE FUNCTION public.create_voucher_entry(
    p_type TEXT,
    p_party_type TEXT,
    p_entity_id UUID DEFAULT NULL,
    p_party_name TEXT DEFAULT '',
    p_amount DECIMAL(15,2) DEFAULT 0,
    p_payment_method TEXT DEFAULT 'cash',
    p_cheque_number TEXT DEFAULT NULL,
    p_bank_name TEXT DEFAULT NULL,
    p_purpose TEXT DEFAULT '',
    p_voucher_date DATE DEFAULT CURRENT_DATE
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_voucher_num TEXT;
    v_voucher_id UUID;
    v_fin_res JSONB;
BEGIN
    IF p_amount <= 0 THEN
        RAISE EXCEPTION 'مبلغ السند يجب أن يكون أكبر من صفر';
    END IF;

    -- Generate Voucher Number
    v_voucher_num := public.generate_voucher_number(p_type);

    -- Insert Voucher Record
    INSERT INTO public.vouchers (
        voucher_number,
        type,
        party_type,
        entity_id,
        party_name,
        amount,
        payment_method,
        cheque_number,
        bank_name,
        purpose,
        voucher_date,
        created_by
    ) VALUES (
        v_voucher_num,
        p_type,
        p_party_type,
        p_entity_id,
        p_party_name,
        p_amount,
        p_payment_method,
        p_cheque_number,
        p_bank_name,
        p_purpose,
        p_voucher_date,
        auth.uid()
    )
    RETURNING id INTO v_voucher_id;

    -- Apply financial processing if linked to an investor
    IF p_party_type = 'investor' AND p_entity_id IS NOT NULL THEN
        IF p_type = 'receipt' THEN
            -- Deposit: Adds money to investor balance & records accounting journal entry
            v_fin_res := public.process_investor_deposit(
                p_entity_id,
                p_amount,
                COALESCE(p_purpose, 'سند قبض رقم ' || v_voucher_num),
                v_voucher_num
            );
        ELSIF p_type = 'payment' THEN
            -- Withdrawal: Deducts money from investor balance & records accounting journal entry
            v_fin_res := public.process_investor_withdrawal(
                p_entity_id,
                p_amount,
                COALESCE(p_purpose, 'سند صرف رقم ' || v_voucher_num),
                v_voucher_num
            );
        END IF;
    END IF;

    RETURN jsonb_build_object(
        'success', true,
        'voucher_id', v_voucher_id,
        'voucher_number', v_voucher_num
    );
END;
$$;

GRANT EXECUTE ON FUNCTION public.create_voucher_entry(TEXT, TEXT, UUID, TEXT, DECIMAL, TEXT, TEXT, TEXT, TEXT, DATE) TO authenticated;
