-- ############################################################################
-- MIGRATION: financing_contracts - Contract Parties & Fees Expansion
-- VERSION: 1.2.0
-- DATE: 2026-07-24
-- DESCRIPTION:
--   Adds all fields required by the new approved Cash & Installment contract
--   templates (عقد بيع نقدي + عقد بيع بالأقساط) including:
--   - Full Guarantor 2 info
--   - Guarantor 1 address field
--   - Down payment (الدفعة المقدمة)
--   - 6 detailed service fees breakdown
--   - Contract notes
--   - Multi-vehicle list (JSONB)
--   - Contract type flag
-- ############################################################################

-- SAFE: Uses DO block + IF NOT EXISTS to avoid errors on existing databases
DO $$
BEGIN

  -- --------------------------------------------------------
  -- 1. Contract Type (بيع نقدي / بيع بالأقساط)
  -- --------------------------------------------------------
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'financing_contracts' AND column_name = 'type'
  ) THEN
    ALTER TABLE public.financing_contracts ADD COLUMN type TEXT DEFAULT 'installments';
    RAISE NOTICE 'Added: type';
  END IF;

  -- --------------------------------------------------------
  -- 2. Guarantor 1 - Extra Fields
  -- --------------------------------------------------------
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'financing_contracts' AND column_name = 'guarantor_1_name'
  ) THEN
    ALTER TABLE public.financing_contracts ADD COLUMN guarantor_1_name TEXT;
    RAISE NOTICE 'Added: guarantor_1_name';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'financing_contracts' AND column_name = 'guarantor_1_id'
  ) THEN
    ALTER TABLE public.financing_contracts ADD COLUMN guarantor_1_id TEXT;
    RAISE NOTICE 'Added: guarantor_1_id';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'financing_contracts' AND column_name = 'guarantor_1_phone'
  ) THEN
    ALTER TABLE public.financing_contracts ADD COLUMN guarantor_1_phone TEXT;
    RAISE NOTICE 'Added: guarantor_1_phone';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'financing_contracts' AND column_name = 'guarantor_1_work'
  ) THEN
    ALTER TABLE public.financing_contracts ADD COLUMN guarantor_1_work TEXT;
    RAISE NOTICE 'Added: guarantor_1_work';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'financing_contracts' AND column_name = 'guarantor_1_address'
  ) THEN
    ALTER TABLE public.financing_contracts ADD COLUMN guarantor_1_address TEXT;
    RAISE NOTICE 'Added: guarantor_1_address';
  END IF;

  -- --------------------------------------------------------
  -- 3. Guarantor 2 - Full Info (الكفيل الثاني)
  -- --------------------------------------------------------
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'financing_contracts' AND column_name = 'guarantor_2_name'
  ) THEN
    ALTER TABLE public.financing_contracts ADD COLUMN guarantor_2_name TEXT;
    RAISE NOTICE 'Added: guarantor_2_name';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'financing_contracts' AND column_name = 'guarantor_2_id'
  ) THEN
    ALTER TABLE public.financing_contracts ADD COLUMN guarantor_2_id TEXT;
    RAISE NOTICE 'Added: guarantor_2_id';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'financing_contracts' AND column_name = 'guarantor_2_phone'
  ) THEN
    ALTER TABLE public.financing_contracts ADD COLUMN guarantor_2_phone TEXT;
    RAISE NOTICE 'Added: guarantor_2_phone';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'financing_contracts' AND column_name = 'guarantor_2_work'
  ) THEN
    ALTER TABLE public.financing_contracts ADD COLUMN guarantor_2_work TEXT;
    RAISE NOTICE 'Added: guarantor_2_work';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'financing_contracts' AND column_name = 'guarantor_2_address'
  ) THEN
    ALTER TABLE public.financing_contracts ADD COLUMN guarantor_2_address TEXT;
    RAISE NOTICE 'Added: guarantor_2_address';
  END IF;

  -- --------------------------------------------------------
  -- 4. Witnesses (الشهود)
  -- --------------------------------------------------------
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'financing_contracts' AND column_name = 'witness_1'
  ) THEN
    ALTER TABLE public.financing_contracts ADD COLUMN witness_1 TEXT;
    RAISE NOTICE 'Added: witness_1';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'financing_contracts' AND column_name = 'witness_2'
  ) THEN
    ALTER TABLE public.financing_contracts ADD COLUMN witness_2 TEXT;
    RAISE NOTICE 'Added: witness_2';
  END IF;

  -- --------------------------------------------------------
  -- 5. Down Payment (الدفعة المقدمة)
  -- --------------------------------------------------------
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'financing_contracts' AND column_name = 'down_payment'
  ) THEN
    ALTER TABLE public.financing_contracts ADD COLUMN down_payment DECIMAL(15,2) DEFAULT 0.00;
    RAISE NOTICE 'Added: down_payment';
  END IF;

  -- --------------------------------------------------------
  -- 6. Fees Breakdown - 6 Service Items (الرسوم التفصيلية)
  -- --------------------------------------------------------
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'financing_contracts' AND column_name = 'moroor_fees'
  ) THEN
    ALTER TABLE public.financing_contracts ADD COLUMN moroor_fees DECIMAL(15,2) DEFAULT 0.00;
    RAISE NOTICE 'Added: moroor_fees';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'financing_contracts' AND column_name = 'tamm_fees'
  ) THEN
    ALTER TABLE public.financing_contracts ADD COLUMN tamm_fees DECIMAL(15,2) DEFAULT 0.00;
    RAISE NOTICE 'Added: tamm_fees';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'financing_contracts' AND column_name = 'insurance_fees'
  ) THEN
    ALTER TABLE public.financing_contracts ADD COLUMN insurance_fees DECIMAL(15,2) DEFAULT 0.00;
    RAISE NOTICE 'Added: insurance_fees';
  END IF;

  -- رسوم الفحص الدوري
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'financing_contracts' AND column_name = 'inspection_fees'
  ) THEN
    ALTER TABLE public.financing_contracts ADD COLUMN inspection_fees DECIMAL(15,2) DEFAULT 0.00;
    RAISE NOTICE 'Added: inspection_fees';
  END IF;

  -- رسوم إصدار اللوحات
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'financing_contracts' AND column_name = 'plate_fees'
  ) THEN
    ALTER TABLE public.financing_contracts ADD COLUMN plate_fees DECIMAL(15,2) DEFAULT 0.00;
    RAISE NOTICE 'Added: plate_fees';
  END IF;

  -- سداد المخالفات المرورية
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'financing_contracts' AND column_name = 'traffic_violations_fees'
  ) THEN
    ALTER TABLE public.financing_contracts ADD COLUMN traffic_violations_fees DECIMAL(15,2) DEFAULT 0.00;
    RAISE NOTICE 'Added: traffic_violations_fees';
  END IF;

  -- رسوم أخرى
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'financing_contracts' AND column_name = 'other_fees'
  ) THEN
    ALTER TABLE public.financing_contracts ADD COLUMN other_fees DECIMAL(15,2) DEFAULT 0.00;
    RAISE NOTICE 'Added: other_fees';
  END IF;

  -- ضريبة القيمة المضافة
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'financing_contracts' AND column_name = 'vat_amount'
  ) THEN
    ALTER TABLE public.financing_contracts ADD COLUMN vat_amount DECIMAL(15,2) DEFAULT 0.00;
    RAISE NOTICE 'Added: vat_amount';
  END IF;

  -- --------------------------------------------------------
  -- 7. Notes & Multi-Vehicle Support
  -- --------------------------------------------------------
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'financing_contracts' AND column_name = 'notes'
  ) THEN
    ALTER TABLE public.financing_contracts ADD COLUMN notes TEXT;
    RAISE NOTICE 'Added: notes';
  END IF;

  -- Multi-vehicle list stored as JSONB array:
  -- Example: [{"make":"كيا","model":"2022","plate":"أ ب ج 123","chassis":"XYZ123"}]
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'financing_contracts' AND column_name = 'vehicles_list'
  ) THEN
    ALTER TABLE public.financing_contracts ADD COLUMN vehicles_list JSONB DEFAULT '[]'::jsonb;
    RAISE NOTICE 'Added: vehicles_list';
  END IF;

END $$;

-- ############################################################################
-- VERIFY: Show final column list of financing_contracts
-- ############################################################################
SELECT 
  column_name,
  data_type,
  column_default,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'financing_contracts'
ORDER BY ordinal_position;
