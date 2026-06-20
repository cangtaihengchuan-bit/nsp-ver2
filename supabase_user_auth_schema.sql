create extension if not exists pgcrypto;

create table if not exists public.nsp_user_discounts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  store_id text not null,
  store_name text not null,
  store_type text not null,
  item_name text not null,
  price numeric not null,
  sale_mode text not null default 'once',
  sale_date date,
  sale_weekday integer,
  sale_month_day integer,
  note text,
  created_at timestamptz not null default now()
);

create index if not exists nsp_user_discounts_user_created_idx
  on public.nsp_user_discounts (user_id, created_at desc);

create index if not exists nsp_user_discounts_store_idx
  on public.nsp_user_discounts (store_id);

alter table public.nsp_user_discounts enable row level security;

drop policy if exists "nsp users can read own discounts" on public.nsp_user_discounts;
drop policy if exists "nsp users can insert own discounts" on public.nsp_user_discounts;
drop policy if exists "nsp users can update own discounts" on public.nsp_user_discounts;
drop policy if exists "nsp users can delete own discounts" on public.nsp_user_discounts;

create policy "nsp users can read own discounts"
  on public.nsp_user_discounts
  for select
  to authenticated
  using (auth.uid() = user_id);

create policy "nsp users can insert own discounts"
  on public.nsp_user_discounts
  for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "nsp users can update own discounts"
  on public.nsp_user_discounts
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "nsp users can delete own discounts"
  on public.nsp_user_discounts
  for delete
  to authenticated
  using (auth.uid() = user_id);

grant usage on schema public to anon, authenticated;
grant select, insert, update, delete on public.nsp_user_discounts to authenticated;
