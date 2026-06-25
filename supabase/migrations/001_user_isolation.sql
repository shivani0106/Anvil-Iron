-- ============================================================
-- Migration 001: User Data Isolation
-- Apply this in Supabase → SQL Editor → New Query
-- Safe to run multiple times (IF NOT EXISTS / IF EXISTS guards).
-- ============================================================

-- ── 1. Add user_id to all top-level tables ───────────────────
ALTER TABLE orders          ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE customers       ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE suppliers       ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE inventory_items ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE invoices        ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE quotes          ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE machines        ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE drawings        ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE materials       ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE teams           ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;

-- ── 2. Indexes for query performance ─────────────────────────
CREATE INDEX IF NOT EXISTS idx_orders_user_id          ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_customers_user_id       ON customers(user_id);
CREATE INDEX IF NOT EXISTS idx_suppliers_user_id       ON suppliers(user_id);
CREATE INDEX IF NOT EXISTS idx_inventory_items_user_id ON inventory_items(user_id);
CREATE INDEX IF NOT EXISTS idx_invoices_user_id        ON invoices(user_id);
CREATE INDEX IF NOT EXISTS idx_quotes_user_id          ON quotes(user_id);
CREATE INDEX IF NOT EXISTS idx_machines_user_id        ON machines(user_id);
CREATE INDEX IF NOT EXISTS idx_materials_user_id       ON materials(user_id);
CREATE INDEX IF NOT EXISTS idx_teams_user_id           ON teams(user_id);

-- ── 3. Drop the old permissive "auth_all_*" policies ─────────
DROP POLICY IF EXISTS "auth_all_orders"          ON orders;
DROP POLICY IF EXISTS "auth_all_customers"       ON customers;
DROP POLICY IF EXISTS "auth_all_suppliers"       ON suppliers;
DROP POLICY IF EXISTS "auth_all_job_materials"   ON job_materials;
DROP POLICY IF EXISTS "auth_all_job_teams"       ON job_teams;
DROP POLICY IF EXISTS "auth_all_inventory"       ON inventory_items;
DROP POLICY IF EXISTS "auth_all_stock_log"       ON stock_log_entries;
DROP POLICY IF EXISTS "auth_all_invoices"        ON invoices;
DROP POLICY IF EXISTS "auth_all_materials"       ON materials;
DROP POLICY IF EXISTS "auth_all_teams"           ON teams;
DROP POLICY IF EXISTS "auth_all_workflow_steps"  ON workflow_steps;

-- ── 4. User-scoped RLS policies — top-level tables ───────────

-- orders
CREATE POLICY "user_select_orders" ON orders
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "user_insert_orders" ON orders
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_update_orders" ON orders
  FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_delete_orders" ON orders
  FOR DELETE TO authenticated USING (user_id = auth.uid());

-- customers
CREATE POLICY "user_select_customers" ON customers
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "user_insert_customers" ON customers
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_update_customers" ON customers
  FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_delete_customers" ON customers
  FOR DELETE TO authenticated USING (user_id = auth.uid());

-- suppliers
CREATE POLICY "user_select_suppliers" ON suppliers
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "user_insert_suppliers" ON suppliers
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_update_suppliers" ON suppliers
  FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_delete_suppliers" ON suppliers
  FOR DELETE TO authenticated USING (user_id = auth.uid());

-- inventory_items
CREATE POLICY "user_select_inventory" ON inventory_items
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "user_insert_inventory" ON inventory_items
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_update_inventory" ON inventory_items
  FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_delete_inventory" ON inventory_items
  FOR DELETE TO authenticated USING (user_id = auth.uid());

-- invoices
CREATE POLICY "user_select_invoices" ON invoices
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "user_insert_invoices" ON invoices
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_update_invoices" ON invoices
  FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_delete_invoices" ON invoices
  FOR DELETE TO authenticated USING (user_id = auth.uid());

-- quotes
CREATE POLICY "user_select_quotes" ON quotes
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "user_insert_quotes" ON quotes
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_update_quotes" ON quotes
  FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_delete_quotes" ON quotes
  FOR DELETE TO authenticated USING (user_id = auth.uid());

-- machines
CREATE POLICY "user_select_machines" ON machines
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "user_insert_machines" ON machines
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_update_machines" ON machines
  FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_delete_machines" ON machines
  FOR DELETE TO authenticated USING (user_id = auth.uid());

-- materials (catalog)
CREATE POLICY "user_select_materials" ON materials
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "user_insert_materials" ON materials
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_update_materials" ON materials
  FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_delete_materials" ON materials
  FOR DELETE TO authenticated USING (user_id = auth.uid());

-- teams
CREATE POLICY "user_select_teams" ON teams
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "user_insert_teams" ON teams
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_update_teams" ON teams
  FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_delete_teams" ON teams
  FOR DELETE TO authenticated USING (user_id = auth.uid());

-- ── 5. Child table policies — scoped via parent FK ────────────
-- No user_id column needed; ownership is inherited from the parent row.

-- job_materials (parent: orders)
CREATE POLICY "user_select_job_materials" ON job_materials
  FOR SELECT TO authenticated
  USING (EXISTS (
    SELECT 1 FROM orders
    WHERE orders.id = job_materials.order_id AND orders.user_id = auth.uid()
  ));
CREATE POLICY "user_insert_job_materials" ON job_materials
  FOR INSERT TO authenticated
  WITH CHECK (EXISTS (
    SELECT 1 FROM orders
    WHERE orders.id = job_materials.order_id AND orders.user_id = auth.uid()
  ));
CREATE POLICY "user_update_job_materials" ON job_materials
  FOR UPDATE TO authenticated
  USING (EXISTS (
    SELECT 1 FROM orders
    WHERE orders.id = job_materials.order_id AND orders.user_id = auth.uid()
  ));
CREATE POLICY "user_delete_job_materials" ON job_materials
  FOR DELETE TO authenticated
  USING (EXISTS (
    SELECT 1 FROM orders
    WHERE orders.id = job_materials.order_id AND orders.user_id = auth.uid()
  ));

-- job_teams (parent: orders)
CREATE POLICY "user_select_job_teams" ON job_teams
  FOR SELECT TO authenticated
  USING (EXISTS (
    SELECT 1 FROM orders
    WHERE orders.id = job_teams.order_id AND orders.user_id = auth.uid()
  ));
CREATE POLICY "user_insert_job_teams" ON job_teams
  FOR INSERT TO authenticated
  WITH CHECK (EXISTS (
    SELECT 1 FROM orders
    WHERE orders.id = job_teams.order_id AND orders.user_id = auth.uid()
  ));
CREATE POLICY "user_update_job_teams" ON job_teams
  FOR UPDATE TO authenticated
  USING (EXISTS (
    SELECT 1 FROM orders
    WHERE orders.id = job_teams.order_id AND orders.user_id = auth.uid()
  ));
CREATE POLICY "user_delete_job_teams" ON job_teams
  FOR DELETE TO authenticated
  USING (EXISTS (
    SELECT 1 FROM orders
    WHERE orders.id = job_teams.order_id AND orders.user_id = auth.uid()
  ));

-- workflow_steps (parent: orders)
CREATE POLICY "user_select_workflow_steps" ON workflow_steps
  FOR SELECT TO authenticated
  USING (EXISTS (
    SELECT 1 FROM orders
    WHERE orders.id = workflow_steps.order_id AND orders.user_id = auth.uid()
  ));
CREATE POLICY "user_insert_workflow_steps" ON workflow_steps
  FOR INSERT TO authenticated
  WITH CHECK (EXISTS (
    SELECT 1 FROM orders
    WHERE orders.id = workflow_steps.order_id AND orders.user_id = auth.uid()
  ));
CREATE POLICY "user_update_workflow_steps" ON workflow_steps
  FOR UPDATE TO authenticated
  USING (EXISTS (
    SELECT 1 FROM orders
    WHERE orders.id = workflow_steps.order_id AND orders.user_id = auth.uid()
  ));
CREATE POLICY "user_delete_workflow_steps" ON workflow_steps
  FOR DELETE TO authenticated
  USING (EXISTS (
    SELECT 1 FROM orders
    WHERE orders.id = workflow_steps.order_id AND orders.user_id = auth.uid()
  ));

-- stock_log_entries (parent: inventory_items)
CREATE POLICY "user_select_stock_log" ON stock_log_entries
  FOR SELECT TO authenticated
  USING (EXISTS (
    SELECT 1 FROM inventory_items
    WHERE inventory_items.id = stock_log_entries.item_id AND inventory_items.user_id = auth.uid()
  ));
CREATE POLICY "user_insert_stock_log" ON stock_log_entries
  FOR INSERT TO authenticated
  WITH CHECK (EXISTS (
    SELECT 1 FROM inventory_items
    WHERE inventory_items.id = stock_log_entries.item_id AND inventory_items.user_id = auth.uid()
  ));
CREATE POLICY "user_update_stock_log" ON stock_log_entries
  FOR UPDATE TO authenticated
  USING (EXISTS (
    SELECT 1 FROM inventory_items
    WHERE inventory_items.id = stock_log_entries.item_id AND inventory_items.user_id = auth.uid()
  ));
CREATE POLICY "user_delete_stock_log" ON stock_log_entries
  FOR DELETE TO authenticated
  USING (EXISTS (
    SELECT 1 FROM inventory_items
    WHERE inventory_items.id = stock_log_entries.item_id AND inventory_items.user_id = auth.uid()
  ));

-- ── 6. Enable RLS on tables that may be missing it ───────────
ALTER TABLE quotes          ENABLE ROW LEVEL SECURITY;
ALTER TABLE machines        ENABLE ROW LEVEL SECURITY;
ALTER TABLE drawings        ENABLE ROW LEVEL SECURITY;
ALTER TABLE workflow_steps  ENABLE ROW LEVEL SECURITY;
