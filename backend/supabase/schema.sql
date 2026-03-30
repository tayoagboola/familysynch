-- Enable required extensions
create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- ─────────────────────────────────────────────
-- Households
-- ─────────────────────────────────────────────
create table if not exists households (
  id          uuid primary key default uuid_generate_v4(),
  name        text not null,
  emoji       text not null default '🏠',
  invite_code text not null unique,
  created_by  uuid not null references auth.users(id),
  created_at  timestamptz not null default now()
);

-- ─────────────────────────────────────────────
-- Household Members
-- ─────────────────────────────────────────────
create table if not exists household_members (
  id           uuid primary key default uuid_generate_v4(),
  household_id uuid not null references households(id) on delete cascade,
  user_id      uuid not null references auth.users(id),
  display_name text not null,
  avatar_url   text,
  color        text not null default '#2E7D6B',
  role         text not null default 'parent' check (role in ('admin', 'parent', 'child')),
  fcm_token    text,
  joined_at    timestamptz not null default now(),
  unique(household_id, user_id)
);

-- ─────────────────────────────────────────────
-- Invite Tokens
-- ─────────────────────────────────────────────
create table if not exists invite_tokens (
  id           uuid primary key default uuid_generate_v4(),
  token        text not null unique,
  household_id uuid not null references households(id) on delete cascade,
  created_by   uuid not null references auth.users(id),
  expires_at   timestamptz not null,
  used_at      timestamptz,
  created_at   timestamptz not null default now()
);

-- ─────────────────────────────────────────────
-- Calendar Events
-- ─────────────────────────────────────────────
create table if not exists calendar_events (
  id           uuid primary key default uuid_generate_v4(),
  household_id uuid not null references households(id) on delete cascade,
  title        text not null,
  description  text,
  start_time   timestamptz not null,
  end_time     timestamptz,
  is_all_day   boolean not null default false,
  assigned_to  uuid references auth.users(id),
  color        text,
  created_by   uuid not null references auth.users(id),
  created_at   timestamptz not null default now()
);

create index if not exists calendar_events_household_start
  on calendar_events(household_id, start_time);

-- ─────────────────────────────────────────────
-- Tasks
-- ─────────────────────────────────────────────
create table if not exists tasks (
  id           uuid primary key default uuid_generate_v4(),
  household_id uuid not null references households(id) on delete cascade,
  title        text not null,
  description  text,
  due_date     timestamptz,
  assigned_to  uuid references auth.users(id),
  points       int not null default 0,
  completed    boolean not null default false,
  completed_at timestamptz,
  completed_by uuid references auth.users(id),
  created_by   uuid not null references auth.users(id),
  created_at   timestamptz not null default now()
);

create index if not exists tasks_household_id on tasks(household_id);
create index if not exists tasks_assigned_to  on tasks(assigned_to);

-- ─────────────────────────────────────────────
-- Grocery Items
-- ─────────────────────────────────────────────
create table if not exists grocery_items (
  id           uuid primary key default uuid_generate_v4(),
  household_id uuid not null references households(id) on delete cascade,
  name         text not null,
  quantity     text,
  category     text,
  checked      boolean not null default false,
  added_by     uuid not null references auth.users(id),
  checked_by   uuid references auth.users(id),
  created_at   timestamptz not null default now()
);

create index if not exists grocery_items_household_id on grocery_items(household_id);

-- ─────────────────────────────────────────────
-- Feed Posts
-- ─────────────────────────────────────────────
create table if not exists feed_posts (
  id           uuid primary key default uuid_generate_v4(),
  household_id uuid not null references households(id) on delete cascade,
  content      text not null,
  image_url    text,
  author_id    uuid not null references auth.users(id),
  created_at   timestamptz not null default now()
);

create index if not exists feed_posts_household_id on feed_posts(household_id, created_at desc);

-- ─────────────────────────────────────────────
-- Task Streaks (derived, updated by trigger)
-- ─────────────────────────────────────────────
create table if not exists member_streaks (
  id              uuid primary key default uuid_generate_v4(),
  household_id    uuid not null references households(id) on delete cascade,
  user_id         uuid not null references auth.users(id),
  current_streak  int not null default 0,
  longest_streak  int not null default 0,
  last_completed  date,
  updated_at      timestamptz not null default now(),
  unique(household_id, user_id)
);

-- Helper: returns all household_ids the current user belongs to
create or replace function get_my_household_ids()
returns setof uuid
language sql
security definer
stable
as $$
  select household_id from household_members where user_id = auth.uid();
$$;
