-- Supabase Dashboard > SQL Editor > New query mein paste karke Run karo (ek baar)

create table if not exists rooms (
  code text primary key,
  members text[] not null default '{}',
  created_at timestamptz not null default now()
);

create table if not exists categories (
  id uuid primary key default gen_random_uuid(),
  room_code text not null references rooms(code) on delete cascade,
  name text not null,
  unique (room_code, name)
);

create table if not exists expenses (
  id uuid primary key default gen_random_uuid(),
  room_code text not null references rooms(code) on delete cascade,
  amount numeric not null check (amount > 0),
  category text not null default 'Other',
  note text not null default '',
  paid_by text not null,
  added_by text not null,
  created_at timestamptz not null default now()
);
create index if not exists expenses_room_idx on expenses (room_code, created_at desc);

-- Row Level Security (dono dost browser se anon key se access karenge)
alter table rooms enable row level security;
alter table categories enable row level security;
alter table expenses enable row level security;

create policy "rooms all" on rooms for all to anon using (true) with check (true);
create policy "categories all" on categories for all to anon using (true) with check (true);
create policy "expenses all" on expenses for all to anon using (true) with check (true);

-- Live sync (Realtime) ke liye
alter publication supabase_realtime add table rooms, categories, expenses;

-- ===== Month close (khata band) feature =====
create table if not exists month_closings (
  id uuid primary key default gen_random_uuid(),
  room_code text not null references rooms(code) on delete cascade,
  month text not null,
  closed_by text not null,
  total numeric not null default 0,
  summary jsonb not null default '[]',
  closed_at timestamptz not null default now(),
  unique (room_code, month)
);
alter table month_closings enable row level security;
drop policy if exists "closings all" on month_closings;
create policy "closings all" on month_closings for all to anon using (true) with check (true);
do $$
begin
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='month_closings') then
    alter publication supabase_realtime add table public.month_closings;
  end if;
end $$;
