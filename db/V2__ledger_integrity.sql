-- V2: Improve ledger integrity

-- 1. Allow composite foreign keys to reference (id, currency).
ALTER TABLE accounts
ADD CONSTRAINT uq_accounts_id_currency
UNIQUE (id, currency);

-- 2. Replace single-column transfer foreign keys
-- with composite foreign keys that include currency.

ALTER TABLE transfers
DROP CONSTRAINT transfers_from_account_id_fkey;

ALTER TABLE transfers
DROP CONSTRAINT transfers_to_account_id_fkey;

ALTER TABLE transfers
ADD CONSTRAINT fk_transfers_from_account_currency
FOREIGN KEY (from_account_id, currency)
REFERENCES accounts (id, currency);

ALTER TABLE transfers
ADD CONSTRAINT fk_transfers_to_account_currency
FOREIGN KEY (to_account_id, currency)
REFERENCES accounts (id, currency);

-- 3. Replace the ledger_entries account foreign key
-- with a composite foreign key that includes currency.

ALTER TABLE ledger_entries
DROP CONSTRAINT ledger_entries_account_id_fkey;

ALTER TABLE ledger_entries
ADD CONSTRAINT fk_ledger_entries_account_currency
FOREIGN KEY (account_id, currency)
REFERENCES accounts (id, currency);

-- 4. Prevent changes to historical financial records.

CREATE OR REPLACE FUNCTION forbid_change()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION '% on % is not allowed: the ledger is append-only',
        TG_OP, TG_TABLE_NAME;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ledger_entries_append_only
BEFORE UPDATE OR DELETE ON ledger_entries
FOR EACH ROW
EXECUTE FUNCTION forbid_change();

CREATE TRIGGER transfers_append_only
BEFORE UPDATE OR DELETE ON transfers
FOR EACH ROW
EXECUTE FUNCTION forbid_change();

-- 5. Add indexes to frequently used foreign-key columns.

CREATE INDEX idx_accounts_customer_id
ON accounts(customer_id);

CREATE INDEX idx_transfers_from_account_id
ON transfers(from_account_id);

CREATE INDEX idx_transfers_to_account_id
ON transfers(to_account_id);
