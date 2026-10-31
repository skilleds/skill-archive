---
description: Materializa o <projeto>/<projeto>_archive/ OBRIGATÓRIO (criticidade 0) — cria a estrutura, espelha o .schematize/ e grava o handoff da sessão; reporta o que estava ausente.
---
Materialize o **`<projeto>/<projeto>_archive/`** — **DENTRO** do diretório do projeto, **irmão dos
diretórios de microserviços** (a convenção "irmão do projeto" foi **revogada na v0.1.1**; a planta
canônica é a de `references/archive.md`). Archive é **CRITICIDADE 0 — não opcional**.

Passos — os **cinco**, na ordem:

1. **Crie a estrutura** (`overdev/ index/ decisoes/ chats/ context/ context_agent/ plan/ scan/ qa/ audit/ pentest/ orchestration/ scaffold/ relatorios/`)
   se faltar — **`context/` junto de `chats/`**, que é onde os comandos `/<slug>-cc` e
   `/<slug>-handoff` gravam e onde a `/archive-todos` também lê.
   Crie também o **`.ritmo.json`** inicial (engineering piso 26) com o instante atual, e o
   primeiro relatório a partir de `assets/relatorio.template.md`:
   `{"ultimo_relatorio":"<ISO-8601 agora>","ultimo_handoff":"<ISO-8601 agora>"}`.
   Ele é versionado (nunca no `.gitignore`).
2. **`git init`** no `<projeto>_archive/` se ainda não for repo, **e garanta o remote PRIVADO**
   (`gh repo create <org>/<projeto>_archive --private`). Este passo **faltava aqui** e é o que separa
   um archive de uma pasta: sem repo próprio e remoto, o rastro de criticidade 0 **não sobrevive à
   perda da máquina** — e sem `--private`, o histórico interno vira público.
3. **Espelhe** o operacional vivo de `.schematize/` (overdev, grafos) para o archive.
4. **Grave o handoff** da sessão atual (FEITO / EM ABERTO) em `context/<AAAA-MM-DD>-<slug>-context.md`
   — o mesmo lugar dos `-cc`/`-handoff`, para a `/archive-todos` recuperar. Renove `ultimo_handoff`.
5. **Reporte o que estava AUSENTE** (o gap de observabilidade que você acabou de fechar).

Rode `/archive-check` depois: ele confere o que **nunca pode entrar** (segredo, PII, binário), a
convenção de nome e se o archive é mesmo um repo. Nunca siga um trabalho relevante sem o archive
existir.
