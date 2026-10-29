-- Usuals: first-time Supabase database setup.
-- Run ONCE in the Supabase SQL Editor on a NEW project.
-- Never run the old user_id-based supabase-setup.sql alongside this file.

create table public.households (
  id uuid primary key default gen_random_uuid(),
  name text not null default 'My household' check (char_length(name) between 1 and 100),
  created_by uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table public.household_members (
  household_id uuid not null references public.households(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'member' check (role in ('owner', 'member')),
  joined_at timestamptz not null default now(),
  primary key (household_id, user_id)
);
create index household_members_user_idx on public.household_members(user_id);

create table public.grocery_lists (
  household_id uuid primary key references public.households(id) on delete cascade,
  data jsonb not null default '[]'::jsonb check (jsonb_typeof(data) = 'array'),
  updated_at timestamptz not null default now()
);

-- Security-definer membership lookup avoids recursive row-security policies.
create function public.is_household_member(p_household_id uuid)
returns boolean
language sql stable security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.household_members m
    where m.household_id = p_household_id and m.user_id = (select auth.uid())
  );
$$;

-- Creates a private household and initializes its grocery list in one transaction.
create function public.create_household(p_name text default 'My household')
returns uuid
language plpgsql security definer
set search_path = ''
as $$
declare v_user_id uuid := auth.uid(); v_household_id uuid;
begin
  if v_user_id is null then raise exception 'Sign in required'; end if;
  if length(btrim(coalesce(p_name, ''))) not between 1 and 100 then
    raise exception 'Invalid household name';
  end if;
  insert into public.households(name, created_by)
  values (btrim(p_name), v_user_id) returning id into v_household_id;
  insert into public.household_members(household_id, user_id, role)
  values (v_household_id, v_user_id, 'owner');
  insert into public.grocery_lists(household_id) values (v_household_id);
  return v_household_id;
end;
$$;

-- Keep only authenticated clients able to call these helper functions.
revoke all on function public.is_household_member(uuid) from public, anon;
grant execute on function public.is_household_member(uuid) to authenticated;
revoke all on function public.create_household(text) from public, anon;
grant execute on function public.create_household(text) to authenticated;

alter table public.households enable row level security;
alter table public.household_members enable row level security;
alter table public.grocery_lists enable row level security;

create policy "Members can view their household" on public.households
for select to authenticated using (public.is_household_member(id));

create policy "Members can view household membership" on public.household_members
for select to authenticated using (public.is_household_member(household_id));

create policy "Members can read groceries" on public.grocery_lists
for select to authenticated using (public.is_household_member(household_id));
create policy "Members can update groceries" on public.grocery_lists
for update to authenticated using (public.is_household_member(household_id))
with check (public.is_household_member(household_id));

-- Household creation and invitation membership changes are handled by vetted
-- database functions, not by open client-side INSERT/UPDATE policies.

-- Enable realtime updates for grocery lists.
alter publication supabase_realtime add table public.grocery_lists;
