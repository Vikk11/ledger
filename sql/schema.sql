CREATE TABLE customers (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE orders (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,

    CONSTRAINT fk_orders_customers
                    FOREIGN KEY (customer_id)
                    REFERENCES customers(id),

    CONSTRAINT chk_order_amount
                    CHECK (amount > 0)
);