create table if not exists public.store_discounts (
  id text primary key,
  user_id uuid references auth.users(id) on delete cascade default auth.uid(),
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

alter table public.store_discounts
  add column if not exists user_id uuid references auth.users(id) on delete cascade default auth.uid();

alter table public.store_discounts
  alter column user_id set default auth.uid();

create index if not exists store_discounts_user_id_created_at_idx
  on public.store_discounts (user_id, created_at desc);

alter table public.store_discounts enable row level security;

drop policy if exists "Users can read own discounts" on public.store_discounts;
drop policy if exists "Users can insert own discounts" on public.store_discounts;
drop policy if exists "Users can update own discounts" on public.store_discounts;
drop policy if exists "Users can delete own discounts" on public.store_discounts;

create policy "Users can read own discounts"
  on public.store_discounts
  for select
  using (auth.uid() = user_id);

create policy "Users can insert own discounts"
  on public.store_discounts
  for insert
  with check (auth.uid() = user_id);

create policy "Users can update own discounts"
  on public.store_discounts
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can delete own discounts"
  on public.store_discounts
  for delete
  using (auth.uid() = user_id);

grant usage on schema public to anon, authenticated;
grant select, insert, update, delete on public.store_discounts to authenticated;
