-- ============================================================
-- Run this in Supabase → SQL Editor → New Query
-- ============================================================

-- ── 1. Customers (must exist before orders references it) ────
CREATE TABLE IF NOT EXISTS customers (
  id           BIGSERIAL PRIMARY KEY,
  name         TEXT NOT NULL,
  mobile       TEXT NOT NULL,
  alt_number   TEXT,
  email        TEXT,
  address      TEXT,
  notes        TEXT,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);

-- ── 2. Base tables (original) ────────────────────────────────
CREATE TABLE IF NOT EXISTS orders (
  id          INTEGER PRIMARY KEY,
  customer    TEXT NOT NULL,
  item        TEXT NOT NULL,
  spec        TEXT,
  qty         INTEGER NOT NULL DEFAULT 1,
  material    TEXT,
  due         TEXT NOT NULL,
  ordered     TEXT NOT NULL,
  stage       TEXT NOT NULL DEFAULT 'queued',
  delivered   BOOLEAN NOT NULL DEFAULT FALSE,
  drawing     TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS inventory_items (
  id           INTEGER PRIMARY KEY,
  name         TEXT NOT NULL,
  category     TEXT NOT NULL,
  qty          NUMERIC NOT NULL DEFAULT 0,
  unit         TEXT NOT NULL,
  reorder_qty  NUMERIC NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS stock_log_entries (
  id          BIGSERIAL PRIMARY KEY,
  item_id     INTEGER REFERENCES inventory_items(id) ON DELETE CASCADE,
  date        TEXT NOT NULL,
  delta       NUMERIC NOT NULL,
  note        TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS invoices (
  id        TEXT PRIMARY KEY,
  customer  TEXT NOT NULL,
  amount    NUMERIC NOT NULL,
  status    TEXT NOT NULL DEFAULT 'outstanding',
  date      TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS quotes (
  id        TEXT PRIMARY KEY,
  customer  TEXT NOT NULL,
  amount    NUMERIC NOT NULL,
  status    TEXT NOT NULL DEFAULT 'pending',
  date      TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS suppliers (
  id             INTEGER PRIMARY KEY,
  name           TEXT NOT NULL,
  materials      TEXT,
  phone          TEXT,
  location       TEXT,
  contact_person TEXT,
  mobile         TEXT,
  email          TEXT,
  address        TEXT,
  notes          TEXT,
  created_at     TIMESTAMPTZ DEFAULT NOW(),
  updated_at     TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS machines (
  id           INTEGER PRIMARY KEY,
  name         TEXT NOT NULL,
  status       TEXT NOT NULL DEFAULT 'idle',
  utilization  NUMERIC NOT NULL DEFAULT 0,
  note         TEXT
);

CREATE TABLE IF NOT EXISTS drawings (
  name      TEXT PRIMARY KEY,
  customer  TEXT NOT NULL,
  size      TEXT,
  rev       TEXT
);

CREATE TABLE IF NOT EXISTS team_members (
  name      TEXT PRIMARY KEY,
  initials  TEXT,
  role      TEXT,
  task      TEXT
);

-- ── 3. Alter orders — add new columns ─────────────────────────
ALTER TABLE orders
  ADD COLUMN IF NOT EXISTS work_type   TEXT NOT NULL DEFAULT 'in_house',
  ADD COLUMN IF NOT EXISTS customer_id BIGINT REFERENCES customers(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS supplier_id INTEGER REFERENCES suppliers(id) ON DELETE SET NULL;

-- ── 3b. Extend machines table ────────────────────────────────
ALTER TABLE machines
  ADD COLUMN IF NOT EXISTS machine_number TEXT,
  ADD COLUMN IF NOT EXISTS type           TEXT,
  ADD COLUMN IF NOT EXISTS manufacturer   TEXT,
  ADD COLUMN IF NOT EXISTS model_number   TEXT,
  ADD COLUMN IF NOT EXISTS capacity       TEXT,
  ADD COLUMN IF NOT EXISTS purchase_date  TEXT,
  ADD COLUMN IF NOT EXISTS created_at     TIMESTAMPTZ DEFAULT NOW(),
  ADD COLUMN IF NOT EXISTS updated_at     TIMESTAMPTZ DEFAULT NOW();

-- ── 3c. Standalone materials catalog ─────────────────────────
CREATE TABLE IF NOT EXISTS materials (
  id            BIGSERIAL PRIMARY KEY,
  name          TEXT NOT NULL,
  type          TEXT,
  quality       TEXT,
  quantity      NUMERIC NOT NULL DEFAULT 0,
  unit          TEXT,
  supplier_name TEXT,
  cost          NUMERIC,
  notes         TEXT,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ── 3d. Standalone teams catalog ─────────────────────────────
CREATE TABLE IF NOT EXISTS teams (
  id            BIGSERIAL PRIMARY KEY,
  team_name     TEXT NOT NULL,
  leader        TEXT,
  contact       TEXT,
  email         TEXT,
  members_count INTEGER NOT NULL DEFAULT 1,
  skills        TEXT,
  notes         TEXT,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ── 4. Job materials ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS job_materials (
  id         BIGSERIAL PRIMARY KEY,
  order_id   INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  name       TEXT NOT NULL,
  type       TEXT,
  quality    TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── 5. Job teams ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS job_teams (
  id            BIGSERIAL PRIMARY KEY,
  order_id      INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  team_name     TEXT NOT NULL,
  leader        TEXT,
  contact       TEXT,
  members_count INTEGER NOT NULL DEFAULT 1,
  notes         TEXT,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ── 6. Indexes ───────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_job_materials_order_id ON job_materials(order_id);
CREATE INDEX IF NOT EXISTS idx_job_teams_order_id     ON job_teams(order_id);
CREATE INDEX IF NOT EXISTS idx_orders_work_type        ON orders(work_type);
CREATE INDEX IF NOT EXISTS idx_orders_customer_id      ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_supplier_id      ON orders(supplier_id);
CREATE INDEX IF NOT EXISTS idx_customers_name          ON customers(name);
CREATE INDEX IF NOT EXISTS idx_suppliers_name          ON suppliers(name);
CREATE INDEX IF NOT EXISTS idx_materials_name          ON materials(name);
CREATE INDEX IF NOT EXISTS idx_teams_team_name         ON teams(team_name);
CREATE INDEX IF NOT EXISTS idx_machines_status         ON machines(status);

-- ── 7. Row Level Security ────────────────────────────────────
ALTER TABLE orders         ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers      ENABLE ROW LEVEL SECURITY;
ALTER TABLE suppliers      ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_materials  ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_teams      ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_log_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices       ENABLE ROW LEVEL SECURITY;
ALTER TABLE materials      ENABLE ROW LEVEL SECURITY;
ALTER TABLE teams          ENABLE ROW LEVEL SECURITY;

-- Authenticated users can read/write all rows
CREATE POLICY "auth_all_orders"        ON orders         FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "auth_all_customers"     ON customers      FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "auth_all_suppliers"     ON suppliers      FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "auth_all_job_materials" ON job_materials  FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "auth_all_job_teams"     ON job_teams      FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "auth_all_inventory"     ON inventory_items FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "auth_all_stock_log"     ON stock_log_entries FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "auth_all_invoices"      ON invoices       FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "auth_all_materials"     ON materials      FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "auth_all_teams"         ON teams          FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- ── 8. updated_at trigger ────────────────────────────────────
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_customers_updated_at
  BEFORE UPDATE ON customers
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_suppliers_updated_at
  BEFORE UPDATE ON suppliers
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_materials_updated_at
  BEFORE UPDATE ON materials
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_teams_updated_at
  BEFORE UPDATE ON teams
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_machines_updated_at
  BEFORE UPDATE ON machines
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ── 9. Workflow steps ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS workflow_steps (
  id         BIGSERIAL PRIMARY KEY,
  order_id   INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  name       TEXT NOT NULL,
  position   INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_workflow_steps_order_id ON workflow_steps(order_id);

ALTER TABLE workflow_steps ENABLE ROW LEVEL SECURITY;
CREATE POLICY "auth_all_workflow_steps" ON workflow_steps FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- ── 10. Enable Realtime ────────────────────────────────────────
-- Run in Supabase Dashboard → Database → Replication → enable for these tables:
-- machines, materials, teams
-- Or run: ALTER TABLE machines  REPLICA IDENTITY FULL;
--         ALTER TABLE materials REPLICA IDENTITY FULL;
--         ALTER TABLE teams     REPLICA IDENTITY FULL;
