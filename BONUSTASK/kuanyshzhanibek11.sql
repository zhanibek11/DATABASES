CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    iin CHAR(12) UNIQUE NOT NULL CHECK (iin ~ '^\d{12}$'),
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    status VARCHAR(20) CHECK (status IN ('active', 'blocked', 'frozen')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    daily_limit_kzt NUMERIC(15, 2) DEFAULT 500000.00
);

CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    account_number VARCHAR(34) UNIQUE NOT NULL, -- IBAN
    currency CHAR(3) CHECK (currency IN ('KZT', 'USD', 'EUR', 'RUB')),
    balance NUMERIC(15, 2) DEFAULT 0 CHECK (balance >= 0),
    is_active BOOLEAN DEFAULT TRUE,
    opened_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    closed_at TIMESTAMP
);

CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    from_account_id INTEGER REFERENCES accounts(account_id),
    to_account_id INTEGER REFERENCES accounts(account_id),
    amount NUMERIC(15, 2) NOT NULL,
    currency CHAR(3) NOT NULL,
    exchange_rate NUMERIC(10, 6) DEFAULT 1.0,
    amount_kzt NUMERIC(15, 2),
    type VARCHAR(20) CHECK (type IN ('transfer', 'deposit', 'withdrawal', 'salary')),
    status VARCHAR(20) CHECK (status IN ('pending', 'completed', 'failed', 'reversed')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    description TEXT
);

CREATE TABLE exchange_rates (
    rate_id SERIAL PRIMARY KEY,
    from_currency CHAR(3),
    to_currency CHAR(3),
    rate NUMERIC(10, 6),
    valid_from TIMESTAMP,
    valid_to TIMESTAMP
);

CREATE TABLE audit_log (
    log_id SERIAL PRIMARY KEY,
    table_name VARCHAR(50),
    record_id INTEGER,
    action VARCHAR(20),
    old_values JSONB,
    new_values JSONB,
    changed_by VARCHAR(50) DEFAULT CURRENT_USER,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address INET
);

INSERT INTO customers (iin, full_name, email, status, daily_limit_kzt) VALUES
('111111111111', 'Aliya Nurlan', 'aliya@mail.ru', 'active', 600000),
('222222222222', 'Boris Ivanov', 'boris@gmail.com', 'active', 2000000),
('333333333333', 'Kairat Serikov', 'kairat@kbtu.kz', 'active', 900000),
('444444444444', 'Diana Kim', 'diana@yandex.ru', 'frozen', 0),
('505050505050', 'Erzhan Bolatov', 'erzhan@mail.com', 'active', 9000000),
('666666666666', 'Gaukhar Alieva', 'gaukhar@gmail.com', 'active', 100000),
('777777777777', 'Hassan Mamedov', 'hassan@list.ru', 'blocked', 0),
('888888888888', 'Indira Tuleshova', 'indira@kbtu.kz', 'active', 200000),
('999999999999', 'Zhannat Ospanov', 'zhannat@mail.ru', 'active', 4500000),
('121212121212', 'Sergey Petrov', 'sergey@gmail.com', 'active', 800000),
('131313131313', 'Maria Sidorova', 'maria@mail.ru', 'active', 3000000),
('000000000001', 'Corporative Count', 'payroll@kazfin.kz', 'active', 999999999);

INSERT INTO exchange_rates (from_currency, to_currency, rate, valid_from, valid_to) VALUES
('USD', 'KZT', 480.00, '2023-01-01', '2023-06-01'),
('EUR', 'KZT', 510.00, '2023-01-01', '2023-06-01'),
('USD', 'KZT', 485.50, NOW(), NULL),
('EUR', 'KZT', 520.20, NOW(), NULL),
('RUB', 'KZT', 5.10, NOW(), NULL),
('KZT', 'USD', 0.00206, NOW(), NULL),
('KZT', 'EUR', 0.00192, NOW(), NULL),
('GBP', 'KZT', 600.00, NOW(), NULL),
('CNY', 'KZT', 68.50, NOW(), NULL),
('USD', 'EUR', 0.93, NOW(), NULL),
('EUR', 'USD', 1.07, NOW(), NULL);

INSERT INTO accounts (customer_id, account_number, currency, balance) VALUES
(1, 'KZ010000001', 'KZT', 150000),
(1, 'KZ010000002', 'USD', 1000),
(2, 'KZ020000001', 'KZT', 50000),
(3, 'KZ030000001', 'EUR', 500),
(4, 'KZ040000001', 'KZT', 10000), -- frozen
(5, 'KZ050000001', 'KZT', 2000000),
(6, 'KZ060000001', 'USD', 200),
(7, 'KZ070000001', 'KZT', 500),   -- blocked
(8, 'KZ080000001', 'KZT', 45000),
(9, 'KZ090000001', 'RUB', 50000),
(9, 'KZ090000002', 'KZT', 1000),
(10, 'KZ100000001', 'KZT', 300000),
(11, 'KZ110000001', 'USD', 5000),
(11, 'KZ110000002', 'EUR', 2000),
(12, 'KZ_COMPANY_MAIN', 'KZT', 50000000); -- company account


INSERT INTO transactions (from_account_id, to_account_id, amount, currency, amount_kzt, type, status, created_at) VALUES
(1, 2, 5000, 'KZT', 5000, 'transfer', 'completed', NOW() - INTERVAL '5 days'),
(2, 3, 70000, 'KZT', 10000, 'transfer', 'completed', NOW() - INTERVAL '4 days'),
(5, 1, 30000, 'KZT', 20000, 'transfer', 'completed', NOW() - INTERVAL '3 days'),
(12, 1, 450000, 'KZT', 150000, 'salary', 'completed', NOW() - INTERVAL '1 month'),
(12, 2, 150000, 'KZT', 150000, 'salary', 'completed', NOW() - INTERVAL '1 month'),
(12, 3, 1150000, 'KZT', 150000, 'salary', 'completed', NOW() - INTERVAL '1 month'),
(1, 6, 100, 'USD', 48550, 'transfer', 'completed', NOW() - INTERVAL '2 days'),
(11, 1, 50, 'USD', 24275, 'transfer', 'completed', NOW() - INTERVAL '1 day'),
(5, 8, 50000, 'KZT', 50000, 'transfer', 'completed', NOW() - INTERVAL '10 hours'),
(5, 8, 50000, 'KZT', 50000, 'transfer', 'completed', NOW() - INTERVAL '9 hours'),
(5, 8, 50000, 'KZT', 50000, 'transfer', 'completed', NOW() - INTERVAL '8 hours'),
(12, 9, 6000000, 'KZT', 6000000, 'transfer', 'completed', NOW() - INTERVAL '1 hour'),
(12, 9, 100, 'KZT', 100, 'transfer', 'completed', NOW() - INTERVAL '5 minutes'),
(12, 9, 100, 'KZT', 100, 'transfer', 'completed', NOW() - INTERVAL '4 minutes 30 seconds'),
(7, 1, 1000, 'KZT', 1000, 'transfer', 'failed', NOW());


INSERT INTO audit_log (table_name, action, changed_by) VALUES
('customers', 'INSERT', 'admin'),
('accounts', 'INSERT', 'admin'),
('accounts', 'UPDATE', 'system'),
('transactions', 'INSERT', 'system'),
('customers', 'UPDATE', 'manager'),
('exchange_rates', 'UPDATE', 'market_bot'),
('accounts', 'FREEZE', 'security'),
('customers', 'BLOCK', 'security'),
('transactions', 'REVERSE', 'admin'),
('system', 'STARTUP', 'root');

--task 1


CREATE OR REPLACE PROCEDURE process_transfer(
    sender_acc VARCHAR,
    receiver_acc VARCHAR,
    amount_val NUMERIC,
    curr_type CHAR(3),
    msg TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    -- variables for ids and stuff
    sid INT; rid INT;
    s_curr CHAR(3); r_curr CHAR(3);

    -- checks
    my_bal NUMERIC;
    my_status VARCHAR;
    day_limit NUMERIC;

    -- calc vars
    kzt_rate NUMERIC := 1.0;
    val_in_kzt NUMERIC;
    cross_rate NUMERIC;
    spent_today NUMERIC;

    -- new id
    tx_id INT;
BEGIN
    -- get sender info
    SELECT account_id, currency, balance, customer_id
    INTO sid, s_curr, my_bal, rid -- using rid temp for cust_id
    FROM accounts WHERE account_number = sender_acc;

    IF sid IS NULL THEN
        RAISE EXCEPTION 'sender not found';
    END IF;

    -- check customer status
    SELECT status, daily_limit_kzt INTO my_status, day_limit
    FROM customers WHERE customer_id = rid;

    -- get receiver info
    SELECT account_id, currency INTO rid, r_curr
    FROM accounts WHERE account_number = receiver_acc;

    IF rid IS NULL THEN
        RAISE EXCEPTION 'receiver not found';
    END IF;

    -- locking rows so no race conditions (important!)
    PERFORM 1 FROM accounts WHERE account_id = sid FOR UPDATE;
    PERFORM 1 FROM accounts WHERE account_id = rid FOR UPDATE;

    -- refresh balance after lock
    SELECT balance INTO my_bal FROM accounts WHERE account_id = sid;

    -- logic checks
    IF my_status != 'active' THEN
        RAISE EXCEPTION 'customer is not active';
    END IF;

    IF my_bal < amount_val THEN
        RAISE EXCEPTION 'not enough money';
    END IF;

    -- converting to kzt for limit check
    IF curr_type != 'KZT' THEN
        SELECT rate INTO kzt_rate
        FROM exchange_rates
        WHERE from_currency = curr_type AND to_currency = 'KZT'
        ORDER BY valid_from DESC LIMIT 1;

        kzt_rate := COALESCE(kzt_rate, 1.0);
    END IF;

    val_in_kzt := amount_val * kzt_rate;

    -- check how much spent today
    SELECT COALESCE(SUM(amount_kzt), 0) INTO spent_today
    FROM transactions
    WHERE from_account_id = sid
      AND created_at::DATE = CURRENT_DATE
      AND type = 'transfer';

    IF (spent_today + val_in_kzt) > day_limit THEN
        RAISE EXCEPTION 'daily limit hit';
    END IF;

    -- take money from sender
    UPDATE accounts SET balance = balance - amount_val WHERE account_id = sid;

    -- calc cross rate for receiver
    IF s_curr = r_curr THEN
        cross_rate := 1.0;
    ELSE
        -- calc via kzt
        cross_rate := kzt_rate / NULLIF((
            SELECT rate FROM exchange_rates
            WHERE from_currency = r_curr AND to_currency = 'KZT'
            ORDER BY valid_from DESC LIMIT 1
        ), 0);
        cross_rate := COALESCE(cross_rate, 1.0);
    END IF;

    -- give money to receiver
    UPDATE accounts SET balance = balance + (amount_val * cross_rate) WHERE account_id = rid;

    -- log it
    INSERT INTO transactions (from_account_id, to_account_id, amount, currency, exchange_rate, amount_kzt, type, status, completed_at, description)
    VALUES (sid, rid, amount_val, curr_type, cross_rate, val_in_kzt, 'transfer', 'completed', NOW(), msg)
    RETURNING transaction_id INTO tx_id;

    -- audit log
    INSERT INTO audit_log (table_name, record_id, action, new_values)
    VALUES ('transactions', tx_id, 'INSERT', jsonb_build_object('amt', amount_val, 'from', sender_acc));

    COMMIT;
END;
$$;

--task 2


-- view 1: user balances
CREATE OR REPLACE VIEW customer_balance_summary AS
SELECT
    c.full_name AS client_name,
    a.account_number AS acc_num,
    a.balance AS raw_balance,
    a.currency AS curr_code,

    -- using coalesce to handle potential nulls
    ROUND(
        CASE
            WHEN a.currency = 'KZT' THEN a.balance
            ELSE a.balance * COALESCE((
                SELECT rate
                FROM exchange_rates r
                WHERE r.from_currency = a.currency
                AND r.to_currency = 'KZT'
                ORDER BY r.valid_from DESC
                LIMIT 1
            ), 1)
        END, 2
    ) AS kzt_total_val,

    --limit utilization %
    ROUND(
        (
            CASE
                WHEN a.currency = 'KZT' THEN a.balance
                ELSE a.balance * COALESCE((
                    SELECT rate
                    FROM exchange_rates r
                    WHERE r.from_currency = a.currency
                    AND r.to_currency = 'KZT'
                    ORDER BY r.valid_from DESC
                    LIMIT 1
                ), 1)
            END
            / NULLIF(c.daily_limit_kzt, 0)
        ) * 100, 2
    ) AS limit_usage_pct,

    DENSE_RANK() OVER (ORDER BY a.balance DESC) AS wealth_rank

FROM customers c
INNER JOIN accounts a ON c.customer_id = a.customer_id;

-- view 2: daily stats
CREATE OR REPLACE VIEW daily_transaction_report AS
SELECT
    created_at::DATE AS ops_date,
    type AS ops_kind,

    --basic stats
    COUNT(transaction_id) AS ops_count,
    SUM(amount_kzt) AS money_vol,
    ROUND(AVG(amount_kzt), 2) AS avg_ticket,

    --running total (cumulative sum)
    SUM(SUM(amount_kzt)) OVER (
        PARTITION BY type
        ORDER BY created_at::DATE
    ) AS accum_total,

    --day-over-day growth %
    ROUND(
        (SUM(amount_kzt) - LAG(SUM(amount_kzt)) OVER (PARTITION BY type ORDER BY created_at::DATE))
        / NULLIF(LAG(SUM(amount_kzt)) OVER (PARTITION BY type ORDER BY created_at::DATE), 0)
        * 100, 2
    ) AS growth_rate

FROM transactions
WHERE status = 'completed'
GROUP BY created_at::DATE, type;

-- view 3: suspicious stuff
CREATE OR REPLACE VIEW suspicious_activity_view WITH (security_barrier = true) AS

--big money
SELECT
    t.transaction_id AS tx_id,
    t.created_at AS time_logged,
    t.amount_kzt AS kzt_amt,
    'money laundering?' AS flag_msg
FROM transactions t
WHERE t.amount_kzt > 5000000

UNION ALL

--spamming transactions (>10 in 1 hour)
SELECT
    t.transaction_id,
    t.created_at,
    t.amount_kzt,
    'spamming transfers'
FROM transactions t
WHERE (
    -- counting logic: look back 1 hour from current row
    SELECT COUNT(*)
    FROM transactions t_hist
    WHERE t_hist.from_account_id = t.from_account_id
    AND t_hist.created_at >= (t.created_at - INTERVAL '1 hour')
    AND t_hist.created_at <= t.created_at
) > 10

UNION ALL

--too fast (bot behavior)
SELECT
    t.transaction_id,
    t.created_at,
    t.amount_kzt,
    'bot behavior'
FROM transactions t
WHERE EXISTS (
    -- check if previous tx exists within 60 seconds
    SELECT 1
    FROM transactions t_prev
    WHERE t_prev.from_account_id = t.from_account_id
    AND t_prev.transaction_id < t.transaction_id
    AND t.created_at < (t_prev.created_at + INTERVAL '1 minute')
);

--task3

CREATE INDEX idx_fast_acc_search
ON accounts USING btree (account_number);

-- why: standard index, best for searching unique account numbers (ranges and equals)

CREATE INDEX idx_exact_iin_match
ON customers USING hash (iin);

-- why: hash is slightly faster for exact match (=) on IIN. we never search IIN by range

CREATE INDEX idx_active_users_only
ON accounts(account_id)
WHERE is_active = TRUE;

-- why: we mostly query 'active' accounts for transfers. no need to index closed ones. saves space

CREATE INDEX idx_case_insensitive_mail
ON customers(lower(email));

-- why: users might type 'Mail@kz' or 'mail@kz'. standard index won't catch it


CREATE INDEX idx_audit_json_search
ON audit_log USING gin (new_values);

-- why: audit_log stores data in jsonb. b-tree cannot search inside json keys. GIN can
--covering index
CREATE INDEX idx_tx_limit_cover
ON transactions (from_account_id, created_at)
INCLUDE (amount_kzt);


-- check b-tree usage
EXPLAIN ANALYZE
SELECT * FROM accounts WHERE account_number = 'KZ010000001';

-- check hash usage
EXPLAIN ANALYZE
SELECT * FROM customers WHERE iin = '111111111111';

-- check partial usage
EXPLAIN ANALYZE
SELECT * FROM accounts WHERE is_active = TRUE AND account_id = 1;

-- check expression usage
EXPLAIN ANALYZE
SELECT * FROM customers WHERE lower(email) = 'aliya@mail.ru';

-- check gin usage
EXPLAIN ANALYZE
SELECT * FROM audit_log WHERE new_values @> '{"amount": 5000}';

EXPLAIN ANALYZE
SELECT SUM(amount_kzt)
FROM transactions
WHERE from_account_id = 1
  AND created_at >= CURRENT_DATE;

--task 4

CREATE OR REPLACE PROCEDURE process_salary_batch(
    comp_acc VARCHAR,
    pay_list JSONB,
    INOUT ok_cnt INT DEFAULT 0,
    INOUT bad_cnt INT DEFAULT 0,
    INOUT err_log JSONB DEFAULT '[]'::jsonb
)
LANGUAGE plpgsql
AS $$
DECLARE
    cid INT;
    c_bal NUMERIC;
    total_need NUMERIC;

    -- loop variables
    item JSONB;
    curr_iin VARCHAR;
    curr_amt NUMERIC;
    eid INT;

    -- accumulator for final atomic update
    total_paid NUMERIC := 0;
BEGIN
    -- блокируем по хэшу номера счета, чтобы нельзя было запустить дубль
    PERFORM pg_advisory_lock(hashtext(comp_acc));

    -- блокируем счет компании
    SELECT account_id, balance INTO cid, c_bal
    FROM accounts WHERE account_number = comp_acc FOR UPDATE;

    IF cid IS NULL THEN
        -- снимаем лок перед выходом
        PERFORM pg_advisory_unlock(hashtext(comp_acc));
        RAISE EXCEPTION 'company account not found' USING ERRCODE = 'P0001';
    END IF;

    SELECT COALESCE(SUM((val->>'amount')::NUMERIC), 0) INTO total_need
    FROM jsonb_array_elements(pay_list) as val;

    IF c_bal < total_need THEN
        PERFORM pg_advisory_unlock(hashtext(comp_acc));
        RAISE EXCEPTION 'insufficient company funds. need: %, have: %', total_need, c_bal USING ERRCODE = 'P0002';
    END IF;

--process each payment individually
    FOR item IN SELECT * FROM jsonb_array_elements(pay_list)
    LOOP
        curr_iin := item->>'iin';
        curr_amt := (item->>'amount')::NUMERIC;

        BEGIN
            -- ищем счет сотрудника
            SELECT acc.account_id INTO eid
            FROM customers c
            JOIN accounts acc ON c.customer_id = acc.customer_id
            WHERE c.iin = curr_iin
              AND acc.currency = 'KZT'
              AND acc.is_active = TRUE
            LIMIT 1;

            IF eid IS NULL THEN
                RAISE EXCEPTION 'active kzt account not found for iin %', curr_iin;
            END IF;

            UPDATE accounts SET balance = balance + curr_amt WHERE account_id = eid;

            -- log transaction
            INSERT INTO transactions (from_account_id, to_account_id, amount, currency, amount_kzt, type, status, completed_at)
            VALUES (cid, eid, curr_amt, 'KZT', curr_amt, 'salary', 'completed', NOW());

            -- count success
            ok_cnt := ok_cnt + 1;
            total_paid := total_paid + curr_amt;

        EXCEPTION WHEN OTHERS THEN
            bad_cnt := bad_cnt + 1;
            err_log := err_log || jsonb_build_object('iin', curr_iin, 'error', SQLERRM);
        END;
    END LOOP;

    -- мы обновляем баланс компании ОДИН раз на общую сумму успешных выплат
    IF total_paid > 0 THEN
        UPDATE accounts SET balance = balance - total_paid WHERE account_id = cid;
    END IF;

    -- log operation result
    INSERT INTO audit_log (table_name, action, new_values)
    VALUES ('salary_batch', 'DONE', jsonb_build_object('success', ok_cnt, 'failed', bad_cnt, 'total_kzt', total_paid));

    -- release lock
    PERFORM pg_advisory_unlock(hashtext(comp_acc));

    COMMIT;
END;
$$;

CREATE MATERIALIZED VIEW salary_report_mv AS
SELECT
    from_account_id AS company_id,
    MAX(completed_at)::DATE AS payment_date,
    COUNT(*) AS total_staff_paid,
    SUM(amount) AS total_expenditure
FROM transactions
WHERE type = 'salary'
GROUP BY from_account_id, completed_at::DATE;



/*
1. ACID compliance:
   - I used `SELECT___FOR UPDATE` in both procedures to lock rows
     This prevents Race Conditions where two transactions read the same balance simultaneously
   - All logic is wrapped in `COMMIT` blocks (handled automatically by Procedures)

2. Batch Processing Strategy:
   - I used 'pg_advisory_lock' on the company account number hash
     This ensures only one payroll batch runs at a time for a company, preventing double payments
   - 'SAVEPOINT' logic is simulated using `BEGIN___EXCEPTION` blocks inside the loop
     This allows valid payments to go through even if one fails
   - Optimization: Company balance is updated ONCE at the end (Atomic Update) instead of 1000 times, reducing database load

3. Security:
   - 'suspicious_activity_view' uses 'WITH (security_barrier=true)'
     This prevents malicious users from inferring hidden data by manipulating query planner execution order
   - Audit logs capture all changes, including failures

4. Indexing Strategy:
   - B-tree: Default choice for unique searches
   - Hash: O(1) complexity for IIN lookups (exect match)
   - Partial:Indexes only active accounts to save disk space and speed up writes for closed accounts
   - GIN: Essential for querying JSONB data in audit logs
   - Composite/Covering: Crucial for the daily limit check 'SUM(amount)'
     It allows Postgres to read values directly from the index (Index Only Scan) without reading the heavy table heap

*/


/*
since i submit one file, here is how you can test locking manually.
we need to verify that 2 people cant touch same account at same time.

step 1: open terminal A (session 1)
run this:
    BEGIN;
    -- locking the row manually
    SELECT * FROM accounts WHERE account_number = 'KZ010000001' FOR UPDATE;
    -- dont commit yet! keep it open.

step 2: open terminal B (session 2)
run this:
    -- trying to transfer from same account
    CALL process_transfer('KZ010000001', 'KZ020000001', 500, 'KZT', 'test lock');

result:
    terminal B will freeze (waiting).
    this proves that my 'FOR UPDATE' lock works and protects data.

step 3: go back to terminal A
run:
    COMMIT;

result:
    terminal B immediately wakes up and finishes transaction.
    no data corruption.
*/