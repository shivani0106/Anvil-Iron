-- ============================================================
-- Migration 003: Add current_step column for workflow step tracking
-- Apply this in Supabase → SQL Editor → New Query
-- Safe to run multiple times (IF NOT EXISTS guard).
-- ============================================================

-- Tracks which workflow step is currently active for an order.
-- -1 = not started, 0..N-1 = active step index.
ALTER TABLE orders ADD COLUMN IF NOT EXISTS current_step INTEGER DEFAULT -1;
