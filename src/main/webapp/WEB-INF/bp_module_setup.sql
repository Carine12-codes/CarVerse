-- =============================================================================
-- CarVerse — Business Partner Module Setup
-- Run ONCE on the CARVERSE schema before deploying the Business Partner module.
--
-- NOTE: Car data is stored in the existing CAR_DETAILS table.
--       CAR_DETAILS.COMPANY_ID holds the BUSINESS_PARTNERS.BUSINESS_ID for
--       cars registered by a business partner.  No separate car table is needed.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Add cancellation columns to BOOKING_DETAILS
--    (safe to re-run — ALTER TABLE is skipped if the column already exists)
-- -----------------------------------------------------------------------------

BEGIN
  EXECUTE IMMEDIATE
    'ALTER TABLE BOOKING_DETAILS ADD CANCELLATION_REASON VARCHAR2(500)';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -1430 THEN RAISE; END IF;  -- -1430 = column already exists
END;
/

BEGIN
  EXECUTE IMMEDIATE
    q'[ALTER TABLE BOOKING_DETAILS ADD CANCELLATION_STATUS VARCHAR2(20)
         DEFAULT 'NONE'
         CONSTRAINT bd_cancel_chk CHECK (CANCELLATION_STATUS IN
           ('NONE','REQUESTED','APPROVED','REJECTED'))]';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -1430 THEN RAISE; END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE
    'ALTER TABLE BOOKING_DETAILS ADD CANCELLATION_DATE DATE';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -1430 THEN RAISE; END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE
    'CREATE INDEX bd_cancel_status_idx ON BOOKING_DETAILS (CANCELLATION_STATUS)';
EXCEPTION
  WHEN OTHERS THEN NULL;  -- index may already exist
END;
/

-- -----------------------------------------------------------------------------
-- 2. COMMISSION_DETAILS — alter existing table to add commission config columns
--    PARTNER_ID  : NULL = default platform rate; set for partner-specific override
--    EFFECTIVE_FROM / EFFECTIVE_TO : rate validity window (NULL TO = still active)
--    NOTES       : free-text description of the rate entry
-- -----------------------------------------------------------------------------

-- Add PARTNER_ID (NULL = default rate applies to all partners)
BEGIN
  EXECUTE IMMEDIATE
    'ALTER TABLE COMMISSION_DETAILS ADD PARTNER_ID VARCHAR2(40)';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -1430 THEN RAISE; END IF;  -- -1430 = column already exists
END;
/

-- Add EFFECTIVE_FROM with default of SYSDATE
BEGIN
  EXECUTE IMMEDIATE
    'ALTER TABLE COMMISSION_DETAILS ADD EFFECTIVE_FROM DATE DEFAULT SYSDATE';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -1430 THEN RAISE; END IF;
END;
/

-- Add EFFECTIVE_TO (NULL = rate is currently active)
BEGIN
  EXECUTE IMMEDIATE
    'ALTER TABLE COMMISSION_DETAILS ADD EFFECTIVE_TO DATE';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -1430 THEN RAISE; END IF;
END;
/

-- Add NOTES for describing the rate entry
BEGIN
  EXECUTE IMMEDIATE
    'ALTER TABLE COMMISSION_DETAILS ADD NOTES VARCHAR2(500)';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -1430 THEN RAISE; END IF;
END;
/

-- Seed the default platform commission rate of 15%
-- Only inserts if no default config row exists yet
BEGIN
  EXECUTE IMMEDIATE
    q'[INSERT INTO COMMISSION_DETAILS
         (COMMISSION_ID, BOOKING_ID, PAYMENT_ID,
          COMMISSION_RATE, COMMISSION_AMOUNT, COMMISSION_STATUS,
          PARTNER_ID, EFFECTIVE_FROM, NOTES)
       SELECT 'CONF-DEFAULT', 'N/A', 'N/A',
              15.00, 0, 'Pending',
              NULL, SYSDATE, 'Default platform commission rate'
       FROM DUAL
       WHERE NOT EXISTS (
         SELECT 1 FROM COMMISSION_DETAILS WHERE COMMISSION_ID = 'CONF-DEFAULT'
       )]';
END;
/

COMMIT;

-- -----------------------------------------------------------------------------
-- 3. Verify
-- -----------------------------------------------------------------------------
SELECT 'CANCELLATION columns added to BOOKING_DETAILS.' AS STATUS FROM DUAL;
SELECT 'COMMISSION_DETAILS altered with config columns + default 15% rate.' AS STATUS FROM DUAL;
