-- Give inventory_items an auto-incrementing id so new rows can be inserted
-- without manually supplying a primary key value.
CREATE SEQUENCE IF NOT EXISTS inventory_items_id_seq;
SELECT setval(
  'inventory_items_id_seq',
  COALESCE((SELECT MAX(id) FROM inventory_items), 0) + 1,
  false
);
ALTER TABLE inventory_items
  ALTER COLUMN id SET DEFAULT nextval('inventory_items_id_seq');
