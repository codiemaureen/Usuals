-- Run this in Supabase > SQL Editor. Each user can access only their own list.
create table if not exists public.grocery_lists (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now()
);
alter table public.grocery_lists enable row level security;
create policy "Read own list" on public.grocery_lists for select to authenticated using ((select auth.uid()) = user_id);
create policy "Insert own list" on public.grocery_lists for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "Update own list" on public.grocery_lists for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
-- Optional: enable realtime for instant refresh across logged-in devices
alter publication supabase_realtime add table public.grocery_lists;
