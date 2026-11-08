# SEXYZ Frontend — versão HTML responsiva

## Estrutura
- `index.html`: página inicial.
- `pages/`: cadastro, login, recuperação de senha, descoberta, filtros, matches, mensagens, perfil, configurações e administração.
- `assets/style.css`: design system responsivo (mobile, tablet e desktop).
- `assets/app.js`: autenticação, navegação, consultas, uploads, matches e mensagens.
- `assets/config.js`: URL e chave pública do Supabase.
- `supabase/extra_security.sql`: complemento para denúncias e moderação.

## Como executar
1. Descompacte `SEXYZ_frontend` no diretório de seu projeto.
2. Sirva a pasta por HTTP (não abra via `file://`). Exemplo: `python -m http.server 8080`.
3. Abra `http://localhost:8080`.
4. Confirme URL e chave pública em `assets/config.js`.
5. No Supabase SQL Editor, execute os arquivos de banco enviados, depois `supabase/extra_security.sql`.
6. Crie o bucket `fotos` como privado e configure as políticas de Storage para restringir uploads à pasta do UID autenticado.
7. Configure Authentication > URL Configuration com a URL publicada e URLs de redirecionamento para recuperação de senha.
8. Para liberar o painel Admin, atribua `app_metadata.role = "admin"` à conta por ambiente confiável/painel Supabase. Nunca use user_metadata para autorização.

## Funcionalidades
- Supabase Auth para cadastro, login, sessão e recuperação de senha.
- Perfis, descoberta por filtros, curtidas e matches recíprocos.
- Mensagens entre matches com atualização Realtime.
- Upload de até seis fotos no bucket `fotos`, com URLs assinadas.
- Denúncia de perfis e painel administrativo protegido por app_metadata.

## Limitações que exigem backend adicional
- O front-end depende de RLS correta no Supabase; interface não substitui segurança no banco.
- O esquema original não implementa presença/usuários online, bloqueio de usuários, exclusão de conta, moderação de fotos nem auditoria completa.
- A role admin deve ser atribuída somente por administrador confiável.
- Revise os campos de perfil expostos aos usuários autenticados e não armazene dados sensíveis desnecessários.
- Mensagens dependem da publicação supabase_realtime configurada no SQL original.
- A chave `sb_publishable_...` é pública. Nunca inclua `service_role` ou segredos no navegador.
