create table if not exists public.portal_config (
  id integer primary key default 1 check (id = 1),
  dados jsonb not null,
  atualizado_em timestamptz not null default now()
);

alter table public.portal_config enable row level security;

drop policy if exists "Leitura publica do portal" on public.portal_config;
drop policy if exists "Administradores atualizam o portal" on public.portal_config;

create policy "Leitura publica do portal"
on public.portal_config for select
to anon, authenticated
using (true);

create policy "Administradores atualizam o portal"
on public.portal_config for all
to authenticated
using (true)
with check (true);

insert into storage.buckets (id, name, public)
values ('treinamentos', 'treinamentos', true)
on conflict (id) do update set public = true;

drop policy if exists "Arquivos publicos para leitura" on storage.objects;
drop policy if exists "Administradores enviam arquivos" on storage.objects;
drop policy if exists "Administradores alteram arquivos" on storage.objects;
drop policy if exists "Administradores excluem arquivos" on storage.objects;

create policy "Arquivos publicos para leitura"
on storage.objects for select
to anon, authenticated
using (bucket_id = 'treinamentos');

create policy "Administradores enviam arquivos"
on storage.objects for insert
to authenticated
with check (bucket_id = 'treinamentos');

create policy "Administradores alteram arquivos"
on storage.objects for update
to authenticated
using (bucket_id = 'treinamentos')
with check (bucket_id = 'treinamentos');

create policy "Administradores excluem arquivos"
on storage.objects for delete
to authenticated
using (bucket_id = 'treinamentos');
