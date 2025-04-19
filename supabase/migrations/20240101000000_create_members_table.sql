-- Create members table for chat feature
create table if not exists public.members (
    id bigint primary key,
    name text not null,
    email text,
    phone text,
    unit_number text,
    building_name text,
    status text,
    last_synced_at timestamp with time zone default timezone('utc'::text, now()),
    created_at timestamp with time zone default timezone('utc'::text, now()),
    updated_at timestamp with time zone default timezone('utc'::text, now())
);

-- Create sync metadata table to track last sync timestamp
create table if not exists public.sync_metadata (
    id text primary key,
    last_sync_timestamp timestamp with time zone,
    created_at timestamp with time zone default timezone('utc'::text, now()),
    updated_at timestamp with time zone default timezone('utc'::text, now())
);

-- Add RLS policies
alter table public.members enable row level security;
alter table public.sync_metadata enable row level security;

-- Create policies
create policy "Members are viewable by authenticated users"
    on public.members for select
    to authenticated
    using (true);

create policy "Members are insertable by service role"
    on public.members for insert
    to service_role
    with check (true);

create policy "Members are updatable by service role"
    on public.members for update
    to service_role
    using (true);

-- Sync metadata policies
create policy "Sync metadata is viewable by service role"
    on public.sync_metadata for select
    to service_role
    using (true);

create policy "Sync metadata is insertable by service role"
    on public.sync_metadata for insert
    to service_role
    with check (true);

create policy "Sync metadata is updatable by service role"
    on public.sync_metadata for update
    to service_role
    using (true);