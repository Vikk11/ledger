CREATE TABLE customers (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE accounts (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES customers(id),
    currency CHAR(3) NOT NULL CHECK (currency ~ '^[A-Z]{3}$'),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transfers (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    from_account_id BIGINT NOT NULL REFERENCES accounts(id),
    to_account_id BIGINT NOT NULL REFERENCES accounts(id),
    amount NUMERIC(19, 2) NOT NULL CHECK (amount > 0),
    currency CHAR(3) NOT NULL CHECK (currency ~ '^[A-Z]{3}$'),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (from_account_id <> to_account_id)
);

CREATE TABLE ledger_entries (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    transfer_id BIGINT NOT NULL REFERENCES transfers(id) ON DELETE RESTRICT,
    account_id BIGINT NOT NULL REFERENCES accounts(id),
    amount NUMERIC(19, 2) NOT NULL CHECK (amount <> 0),
    currency CHAR(3) NOT NULL CHECK (currency ~ '^[A-Z]{3}$'),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (transfer_id, account_id)
);

CREATE INDEX idx_ledger_entries_account_id
    ON ledger_entries(account_id);

CREATE OR REPLACE FUNCTION check_transfer_balance()
RETURNS TRIGGER AS $$
DECLARE
    v_transfer_id BIGINT;
    v_entry_count BIGINT;
    v_total NUMERIC(19, 2);
    v_correct_debits BIGINT;
    v_correct_credits BIGINT;
BEGIN
    IF TG_TABLE_NAME = 'transfers' THEN
        v_transfer_id := NEW.id;
    ELSIF TG_OP = 'DELETE' THEN
        v_transfer_id := OLD.transfer_id;
    ELSE
        v_transfer_id := NEW.transfer_id;
    END IF;

    SELECT
        COUNT(le.id),
        COALESCE(SUM(le.amount), 0),
        COUNT(*) FILTER (
            WHERE le.account_id = t.from_account_id
                AND le.amount = -t.amount
                AND le.currency = t.currency
        ),
        COUNT(*) FILTER (
            WHERE le.account_id = t.to_account_id
                AND le.amount = t.amount
                AND le.currency = t.currency
        )
    INTO
        v_entry_count,
        v_total,
        v_correct_debits,
        v_correct_credits
    FROM transfers t
    LEFT JOIN ledger_entries le ON le.transfer_id = t.id
    WHERE t.id = v_transfer_id
    GROUP BY t.id;

    IF EXISTS (SELECT 1 FROM transfers WHERE id = v_transfer_id) THEN
        IF v_entry_count <> 2
           OR v_total <> 0
           OR v_correct_debits <> 1
           OR v_correct_credits <> 1 THEN
            RAISE EXCEPTION
                'Transfer % has invalid ledger entries.',
                v_transfer_id;
        END IF;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER check_transfer_entries
AFTER INSERT OR UPDATE ON transfers
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE FUNCTION check_transfer_balance();

CREATE CONSTRAINT TRIGGER check_ledger_entries
AFTER INSERT OR UPDATE OR DELETE ON ledger_entries
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE FUNCTION check_transfer_balance();