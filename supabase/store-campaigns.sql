-- Run this focused migration to enable scheduled storefront campaigns.
create table if not exists public.store_campaigns (
  id text primary key check (id = 'active'),
  campaign jsonb not null default '{}'::jsonb check (jsonb_typeof(campaign) = 'object'),
  updated_at timestamptz not null default now()
);

alter table public.store_campaigns enable row level security;
revoke all on public.store_campaigns from public, anon, authenticated;
grant select on public.store_campaigns to anon, authenticated;
grant insert, update on public.store_campaigns to authenticated;

drop policy if exists "Public can read active storefront campaign" on public.store_campaigns;
create policy "Public can read active storefront campaign" on public.store_campaigns
  for select to anon, authenticated
  using (id = 'active');

drop policy if exists "Admins can insert storefront campaign" on public.store_campaigns;
create policy "Admins can insert storefront campaign" on public.store_campaigns
  for insert to authenticated
  with check (id = 'active' and (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

drop policy if exists "Admins can update storefront campaign" on public.store_campaigns;
create policy "Admins can update storefront campaign" on public.store_campaigns
  for update to authenticated
  using (id = 'active' and (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
  with check (id = 'active' and (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');