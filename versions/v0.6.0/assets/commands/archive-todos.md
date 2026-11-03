---
description: GERA AFAZERES pro overdev a partir do histórico recuperável do archive (+ git) — deriva o .schematize/overdev/CHECKLIST.md do que ficou aberto/prometido-e-não-provado, com disciplina red-first.
argument-hint: "[escopo opcional]"
---
**PASSO 1 — a contagem, antes de qualquer prosa.** Rode
`bash .claude/skills/schematize-archive/scripts/collect-history.sh <raiz-do-projeto>`: ele enumera as fontes recuperáveis por
contagem (checklists nas 3 classes, handoffs em **`chats/` E `context/`**, ADRs `proposed`,
perguntas parkeadas, premature-stops, outros `.md` com item aberto, TODO/FIXME no código) e
**reprova (exit 1)** quando não há archive ou quando não há histórico nenhum. O checklist que você
vai derivar tem de **bater com essa contagem** — se o script achou 40 sinais e você produziu 6
itens, você perdeu 34. *(Varrer só `chats/` era o defeito B1: interseção zero com onde as skills
gravam, e a skill devolvia vazio sem erro.)*

**PASSO 2 —** gere os **afazeres do overdev** seguindo `references/gerar-afazeres.md`.
Varra EXAUSTIVAMENTE o `<projeto>/<projeto>_archive/` + `.schematize/` + histórico git: checklists com `- [ ]`/
`- [~]`, perguntas parkeadas (`PERGUNTAS-OVERDEV.txt`), premature-stops, ADRs `proposed`, planos com
itens abertos, handoffs de **`chats/` e `context/`** com seção EM ABERTO, TODOs/FIXMEs do git. Aplique a disciplina
red-first (**"feito" sem prova volta a ABERTO**; on-hold sem resposta = aberto). Derive um CHECKLIST
exaustivo (1 item/linha, cada um com COMO PROVAR, convenção de 3 classes: `- [ ]` máquina · `- [H ]` humano · `- [~]` on-hold) agrupado por origem, grave em
`.schematize/overdev/CHECKLIST.md` (+ OBJETIVO.md + espelho no archive) e reporte a contagem por fonte.
Se o archive não existir, rode `/archive-init` primeiro (criticidade 0). Sugira rodar sob o overdev
(`schematize overdev start` / o botão) — o agente não para até fechar. Veredito formal? `/audit-run`.
