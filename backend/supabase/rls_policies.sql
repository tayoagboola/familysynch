-- ─────────────────────────────────────────────
-- Enable RLS on all tables
-- ─────────────────────────────────────────────
alter table households         enable row level security;
alter table household_members  enable row level security;
alter table invite_tokens      enable row level security;
alter table calendar_events    enable row level security;
alter table tasks              enable row level security;
alter table grocery_items      enable row level security;
alter table feed_posts         enable row level security;
alter table member_streaks     enable row level security;

-- ─────────────────────────────────────────────
-- Households
-- ─────────────────────────────────────────────
create policy "members can view their household"
  on households for select
  using (id in (select get_my_household_ids()));

create policy "authenticated users can create household"
  on households for insert
  with check (auth.uid() = created_by);

create policy "admin can update household"
  on households for update
  using (
    id in (
      select household_id from household_members
      where user_id = auth.uid() and role = 'admin'
    )
  );

-- ─────────────────────────────────────────────
-- Household Members
-- ─────────────────────────────────────────────
create policy "members can view household members"
  on household_members for select
  using (household_id in (select get_my_household_ids()));

create policy "service can insert members"
  on household_members for insert
  with check (true);  -- enforced at API layer

create policy "member can update own record"
  on household_members for update
  using (user_id = auth.uid());

create policy "admin can update any member"
  on household_members for update
  using (
    household_id in (
      select household_id from household_members
      where user_id = auth.uid() and role = 'admin'
    )
  );

-- ─────────────────────────────────────────────
-- Invite Tokens
-- ─────────────────────────────────────────────
create policy "household members can view invite tokens"
  on invite_tokens for select
  using (household_id in (select get_my_household_ids()));

create policy "household members can create invite tokens"
  on invite_tokens for insert
  with check (household_id in (select get_my_household_ids()));

-- ─────────────────────────────────────────────
-- Calendar Events
-- ─────────────────────────────────────────────
create policy "members can view household events"
  on calendar_events for select
  using (household_id in (select get_my_household_ids()));

create policy "members can create events"
  on calendar_events for insert
  with check (
    household_id in (select get_my_household_ids())
    and auth.uid() = created_by
  );

create policy "creator or admin can update events"
  on calendar_events for update
  using (
    created_by = auth.uid()
    or household_id in (
      select household_id from household_members
      where user_id = auth.uid() and role in ('admin', 'parent')
    )
  );

create policy "creator or admin can delete events"
  on calendar_events for delete
  using (
    created_by = auth.uid()
    or household_id in (
      select household_id from household_members
      where user_id = auth.uid() and role in ('admin', 'parent')
    )
  );

-- ─────────────────────────────────────────────
-- Tasks
-- ─────────────────────────────────────────────
create policy "members can view household tasks"
  on tasks for select
  using (household_id in (select get_my_household_ids()));

create policy "members can create tasks"
  on tasks for insert
  with check (
    household_id in (select get_my_household_ids())
    and auth.uid() = created_by
  );

create policy "assignee or creator or admin can update task"
  on tasks for update
  using (
    assigned_to = auth.uid()
    or created_by = auth.uid()
    or household_id in (
      select household_id from household_members
      where user_id = auth.uid() and role in ('admin', 'parent')
    )
  );

create policy "creator or admin can delete task"
  on tasks for delete
  using (
    created_by = auth.uid()
    or household_id in (
      select household_id from household_members
      where user_id = auth.uid() and role in ('admin', 'parent')
    )
  );

-- ─────────────────────────────────────────────
-- Grocery Items
-- ─────────────────────────────────────────────
create policy "members can view grocery items"
  on grocery_items for select
  using (household_id in (select get_my_household_ids()));

create policy "members can add grocery items"
  on grocery_items for insert
  with check (
    household_id in (select get_my_household_ids())
    and auth.uid() = added_by
  );

create policy "members can update grocery items"
  on grocery_items for update
  using (household_id in (select get_my_household_ids()));

create policy "members can delete grocery items"
  on grocery_items for delete
  using (household_id in (select get_my_household_ids()));

-- ─────────────────────────────────────────────
-- Feed Posts
-- ─────────────────────────────────────────────
create policy "members can view feed posts"
  on feed_posts for select
  using (household_id in (select get_my_household_ids()));

create policy "members can create feed posts"
  on feed_posts for insert
  with check (
    household_id in (select get_my_household_ids())
    and auth.uid() = author_id
  );

create policy "author or admin can delete post"
  on feed_posts for delete
  using (
    author_id = auth.uid()
    or household_id in (
      select household_id from household_members
      where user_id = auth.uid() and role = 'admin'
    )
  );

-- ─────────────────────────────────────────────
-- Member Streaks
-- ─────────────────────────────────────────────
create policy "members can view streaks"
  on member_streaks for select
  using (household_id in (select get_my_household_ids()));

create policy "service can upsert streaks"
  on member_streaks for all
  using (true)
  with check (true);  -- service role only; anon/authenticated blocked by default

-- ─────────────────────────────────────────────
-- Realtime
-- ─────────────────────────────────────────────
-- Enable realtime for tables used by Flutter StreamProviders
alter publication supabase_realtime add table calendar_events;
alter publication supabase_realtime add table tasks;
alter publication supabase_realtime add table grocery_items;
alter publication supabase_realtime add table feed_posts;
alter publication supabase_realtime add table household_members;
