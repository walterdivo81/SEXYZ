-- SEXYZ: complemento de segurança para denúncias e moderação.
-- Validação de maioridade no próprio banco (a validação no navegador pode ser contornada).
create or replace function public.require_adult_registration() returns trigger
language plpgsql security definer set search_path = public as $$
declare birth_date date;
begin
  birth_date := nullif(new.raw_user_meta_data->>'data_nascimento', '')::date;
  if birth_date is null or birth_date > (current_date - interval '18 years')::date then
    raise exception 'Cadastro permitido somente para maiores de 18 anos';
  end if;
  return new;
end;
$$;
drop trigger if exists validate_adult_registration on auth.users;
create trigger validate_adult_registration before insert on auth.users
for each row execute function public.require_adult_registration();

-- Execute após CREATE TABLE DATABASE 01.txt e 02.txt no Supabase SQL Editor.
create table if not exists public.reports (
 id uuid primary key default gen_random_uuid(),
 reporter_id uuid not null references public.profiles(id) on delete cascade,
 reported_id uuid not null references public.profiles(id) on delete cascade,
 reason text not null check (char_length(reason) between 3 and 1000),
 status text not null default 'pending' check (status in ('pending','reviewed','dismissed')),
 created_at timestamptz not null default now(),
 check (reporter_id <> reported_id)
);
alter table public.reports enable row level security;
grant insert, select, update on public.reports to authenticated;
drop policy if exists "criar denuncia propria" on public.reports;
create policy "criar denuncia propria" on public.reports for insert to authenticated
 with check (auth.uid() = reporter_id);
drop policy if exists "ver denuncias proprias" on public.reports;
create policy "ver denuncias proprias" on public.reports for select to authenticated
 using (auth.uid() = reporter_id);
drop policy if exists "admin ler denuncias" on public.reports;
create policy "admin ler denuncias" on public.reports for select to authenticated
 using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
drop policy if exists "admin atualizar denuncias" on public.reports;
create policy "admin atualizar denuncias" on public.reports for update to authenticated
 using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
 with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
-- Atribua app_metadata.role=admin somente por ambiente confiável/painel Supabase.
