-- ============================================================
-- Migration 002: Auto-increment ID for suppliers table
-- Apply this in Supabase → SQL Editor → New Query
-- Safe to run multiple times (IF NOT EXISTS guard on sequence).
-- ============================================================

-- Create a sequence starting after any existing rows
CREATE SEQUENCE IF NOT EXISTS suppliers_id_seq;
SELECT setval('suppliers_id_seq', COALESCE((SELECT MAX(id) FROM suppliers), 0) + 1, false);

-- Attach sequence as the default for suppliers.id
ALTER TABLE suppliers ALTER COLUMN id SET DEFAULT nextval('suppliers_id_seq');
