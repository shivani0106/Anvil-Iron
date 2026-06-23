-- Run this in Supabase → SQL Editor → New Query

create table orders (
  id          integer primary key,
  customer    text not null,
  item        text not null,
  spec        text,
  qty         integer not null default 1,
  material    text,
  due         text not null,
  ordered     text not null,
  stage       text not null default 'queued',
  delivered   boolean not null default false,
  drawing     text,
  created_at  timestamptz default now()
);

create table inventory_items (
  id           integer primary key,
  name         text not null,
  category     text not null,
  qty          numeric not null default 0,
  unit         text not null,
  reorder_qty  numeric not null default 0
);

create table stock_log_entries (
  id          bigserial primary key,
  item_id     integer references inventory_items(id) on delete cascade,
  date        text not null,
  delta       numeric not null,
  note        text,
  created_at  timestamptz default now()
);

create table invoices (
  id        text primary key,
  customer  text not null,
  amount    numeric not null,
  status    text not null default 'outstanding',
  date      text not null
);

create table quotes (
  id        text primary key,
  customer  text not null,
  amount    numeric not null,
  status    text not null default 'pending',
  date      text not null
);

create table suppliers (
  id         integer primary key,
  name       text not null,
  materials  text,
  phone      text,
  location   text
);

create table machines (
  id           integer primary key,
  name         text not null,
  status       text not null default 'idle',
  utilization  numeric not null default 0,
  note         text
);

create table drawings (
  name      text primary key,
  customer  text not null,
  size      text,
  rev       text
);

create table team_members (
  name      text primary key,
  initials  text,
  role      text,
  task      text
);
