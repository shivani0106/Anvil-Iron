-- ============================================================
-- Run this in Supabase → SQL Editor → New Query
-- For EXISTING databases, also run migrations/001_user_isolation.sql
-- ============================================================

-- ── 1. Customers (must exist before orders references it) ────
CREATE TABLE IF NOT EXISTS customers (
  id           BIGSERIAL PRIMARY KEY,
  user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name         TEXT NOT NULL,
  mobile       TEXT NOT NULL,
  alt_number   TEXT,
  email        TEXT,
  address      TEXT,
  notes        TEXT,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);

-- ── 2. Base tables ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS orders (
  id          INTEGER PRIMARY KEY,
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
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
  user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
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
  user_id   UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  customer  TEXT NOT NULL,
  amount    NUMERIC NOT NULL,
  status    TEXT NOT NULL DEFAULT 'outstanding',
  date      TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS quotes (
  id        TEXT PRIMARY KEY,
  user_id   UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  customer  TEXT NOT NULL,
  amount    NUMERIC NOT NULL,
  status    TEXT NOT NULL DEFAULT 'pending',
  date      TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS suppliers (
  id             SERIAL PRIMARY KEY,
  user_id        UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
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
  user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name         TEXT NOT NULL,
  status       TEXT NOT NULL DEFAULT 'idle',
  utilization  NUMERIC NOT NULL DEFAULT 0,
  note         TEXT
);

CREATE TABLE IF NOT EXISTS drawings (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  file_name       TEXT NOT NULL,
  customer        TEXT NOT NULL DEFAULT '',
  storage_path    TEXT NOT NULL,
  signed_url      TEXT,
  url_expires_at  TIMESTAMPTZ,
  file_type       TEXT NOT NULL,
  file_size       BIGINT,
  rev             TEXT DEFAULT 'rev 1',
  uploaded_by     UUID REFERENCES auth.users(id),
  created_at      TIMESTAMPTZ DEFAULT NOW()
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
  user_id       UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
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
  user_id       UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
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
CREATE INDEX IF NOT EXISTS idx_job_materials_order_id  ON job_materials(order_id);
CREATE INDEX IF NOT EXISTS idx_job_teams_order_id      ON job_teams(order_id);
CREATE INDEX IF NOT EXISTS idx_orders_work_type        ON orders(work_type);
CREATE INDEX IF NOT EXISTS idx_orders_customer_id      ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_supplier_id      ON orders(supplier_id);
CREATE INDEX IF NOT EXISTS idx_orders_user_id          ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_customers_name          ON customers(name);
CREATE INDEX IF NOT EXISTS idx_customers_user_id       ON customers(user_id);
CREATE INDEX IF NOT EXISTS idx_suppliers_name          ON suppliers(name);
CREATE INDEX IF NOT EXISTS idx_suppliers_user_id       ON suppliers(user_id);
CREATE INDEX IF NOT EXISTS idx_materials_name          ON materials(name);
CREATE INDEX IF NOT EXISTS idx_materials_user_id       ON materials(user_id);
CREATE INDEX IF NOT EXISTS idx_teams_team_name         ON teams(team_name);
CREATE INDEX IF NOT EXISTS idx_teams_user_id           ON teams(user_id);
CREATE INDEX IF NOT EXISTS idx_machines_status         ON machines(status);
CREATE INDEX IF NOT EXISTS idx_machines_user_id        ON machines(user_id);
CREATE INDEX IF NOT EXISTS idx_drawings_user_id        ON drawings(user_id);
CREATE INDEX IF NOT EXISTS idx_inventory_items_user_id ON inventory_items(user_id);
CREATE INDEX IF NOT EXISTS idx_invoices_user_id        ON invoices(user_id);
CREATE INDEX IF NOT EXISTS idx_quotes_user_id          ON quotes(user_id);

-- ── 7. Row Level Security ────────────────────────────────────
ALTER TABLE orders            ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers         ENABLE ROW LEVEL SECURITY;
ALTER TABLE suppliers         ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_materials     ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_teams         ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_items   ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_log_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices          ENABLE ROW LEVEL SECURITY;
ALTER TABLE quotes            ENABLE ROW LEVEL SECURITY;
ALTER TABLE materials         ENABLE ROW LEVEL SECURITY;
ALTER TABLE teams             ENABLE ROW LEVEL SECURITY;
ALTER TABLE machines          ENABLE ROW LEVEL SECURITY;
ALTER TABLE drawings          ENABLE ROW LEVEL SECURITY;

-- drawings
CREATE POLICY "user_select_drawings" ON drawings FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "user_insert_drawings" ON drawings FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_update_drawings" ON drawings FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_delete_drawings" ON drawings FOR DELETE TO authenticated USING (user_id = auth.uid());

-- Storage bucket: project-files
-- Policy: authenticated users can upload to their own user_id folder
-- Policy: authenticated users can read/delete files they uploaded

-- orders (user owns their rows)
CREATE POLICY "user_select_orders" ON orders FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "user_insert_orders" ON orders FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_update_orders" ON orders FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_delete_orders" ON orders FOR DELETE TO authenticated USING (user_id = auth.uid());

-- customers
CREATE POLICY "user_select_customers" ON customers FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "user_insert_customers" ON customers FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_update_customers" ON customers FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_delete_customers" ON customers FOR DELETE TO authenticated USING (user_id = auth.uid());

-- suppliers
CREATE POLICY "user_select_suppliers" ON suppliers FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "user_insert_suppliers" ON suppliers FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_update_suppliers" ON suppliers FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_delete_suppliers" ON suppliers FOR DELETE TO authenticated USING (user_id = auth.uid());

-- inventory_items
CREATE POLICY "user_select_inventory" ON inventory_items FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "user_insert_inventory" ON inventory_items FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_update_inventory" ON inventory_items FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_delete_inventory" ON inventory_items FOR DELETE TO authenticated USING (user_id = auth.uid());

-- invoices
CREATE POLICY "user_select_invoices" ON invoices FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "user_insert_invoices" ON invoices FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_update_invoices" ON invoices FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_delete_invoices" ON invoices FOR DELETE TO authenticated USING (user_id = auth.uid());

-- quotes
CREATE POLICY "user_select_quotes" ON quotes FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "user_insert_quotes" ON quotes FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_update_quotes" ON quotes FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_delete_quotes" ON quotes FOR DELETE TO authenticated USING (user_id = auth.uid());

-- machines
CREATE POLICY "user_select_machines" ON machines FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "user_insert_machines" ON machines FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_update_machines" ON machines FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_delete_machines" ON machines FOR DELETE TO authenticated USING (user_id = auth.uid());

-- materials catalog
CREATE POLICY "user_select_materials" ON materials FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "user_insert_materials" ON materials FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_update_materials" ON materials FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_delete_materials" ON materials FOR DELETE TO authenticated USING (user_id = auth.uid());

-- teams
CREATE POLICY "user_select_teams" ON teams FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "user_insert_teams" ON teams FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_update_teams" ON teams FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_delete_teams" ON teams FOR DELETE TO authenticated USING (user_id = auth.uid());

-- job_materials (no user_id column — inherits ownership from parent order)
CREATE POLICY "user_select_job_materials" ON job_materials FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM orders WHERE orders.id = job_materials.order_id AND orders.user_id = auth.uid()));
CREATE POLICY "user_insert_job_materials" ON job_materials FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM orders WHERE orders.id = job_materials.order_id AND orders.user_id = auth.uid()));
CREATE POLICY "user_update_job_materials" ON job_materials FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM orders WHERE orders.id = job_materials.order_id AND orders.user_id = auth.uid()));
CREATE POLICY "user_delete_job_materials" ON job_materials FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM orders WHERE orders.id = job_materials.order_id AND orders.user_id = auth.uid()));

-- job_teams
CREATE POLICY "user_select_job_teams" ON job_teams FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM orders WHERE orders.id = job_teams.order_id AND orders.user_id = auth.uid()));
CREATE POLICY "user_insert_job_teams" ON job_teams FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM orders WHERE orders.id = job_teams.order_id AND orders.user_id = auth.uid()));
CREATE POLICY "user_update_job_teams" ON job_teams FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM orders WHERE orders.id = job_teams.order_id AND orders.user_id = auth.uid()));
CREATE POLICY "user_delete_job_teams" ON job_teams FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM orders WHERE orders.id = job_teams.order_id AND orders.user_id = auth.uid()));

-- stock_log_entries (inherits from inventory_items)
CREATE POLICY "user_select_stock_log" ON stock_log_entries FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM inventory_items WHERE inventory_items.id = stock_log_entries.item_id AND inventory_items.user_id = auth.uid()));
CREATE POLICY "user_insert_stock_log" ON stock_log_entries FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM inventory_items WHERE inventory_items.id = stock_log_entries.item_id AND inventory_items.user_id = auth.uid()));
CREATE POLICY "user_update_stock_log" ON stock_log_entries FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM inventory_items WHERE inventory_items.id = stock_log_entries.item_id AND inventory_items.user_id = auth.uid()));
CREATE POLICY "user_delete_stock_log" ON stock_log_entries FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM inventory_items WHERE inventory_items.id = stock_log_entries.item_id AND inventory_items.user_id = auth.uid()));

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

-- workflow_steps (inherits ownership from parent order)
CREATE POLICY "user_select_workflow_steps" ON workflow_steps FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM orders WHERE orders.id = workflow_steps.order_id AND orders.user_id = auth.uid()));
CREATE POLICY "user_insert_workflow_steps" ON workflow_steps FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM orders WHERE orders.id = workflow_steps.order_id AND orders.user_id = auth.uid()));
CREATE POLICY "user_update_workflow_steps" ON workflow_steps FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM orders WHERE orders.id = workflow_steps.order_id AND orders.user_id = auth.uid()));
CREATE POLICY "user_delete_workflow_steps" ON workflow_steps FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM orders WHERE orders.id = workflow_steps.order_id AND orders.user_id = auth.uid()));

-- ── 10. Workflow step progress tracking ──────────────────────────
-- Run this migration in Supabase SQL Editor if not already applied:
ALTER TABLE orders ADD COLUMN IF NOT EXISTS current_step INTEGER DEFAULT -1;

-- ── 11. Enable Realtime ────────────────────────────────────────
-- Run in Supabase Dashboard → Database → Replication → enable for these tables:
-- machines, materials, teams
-- Or run: ALTER TABLE machines  REPLICA IDENTITY FULL;
--         ALTER TABLE materials REPLICA IDENTITY FULL;
--         ALTER TABLE teams     REPLICA IDENTITY FULL;
