# `/archive-todos` — gerar afazeres pro overdev a partir do histórico recuperável

Objetivo: transformar o que o archive (+ git) guarda em um `.schematize/overdev/CHECKLIST.md` pronto
pra rodar sob o overdev. É a ponte "história → próximo trabalho".

## Fontes recuperáveis a varrer (exaustivo, por contagem)
- `<projeto>/<projeto>_archive/overdev/CHECKLIST.md` (e o de `.schematize/`): todo `- [ ]` (aberto) e `- [~]`
  (on-hold/parkeado).
- `PERGUNTAS-OVERDEV.txt` + `premature-stops.log`: perguntas parkeadas sem resposta; paradas travadas.
- `<projeto>/<projeto>_archive/decisoes/*`: ADRs `proposed` que nunca viraram accepted/rejected.
- `<projeto>/<projeto>_archive/overdev/PLAN.md`: itens do plano sem prova de conclusão.
- `<projeto>/<projeto>_archive/chats/*` **E** `<projeto>/<projeto>_archive/context/*`: handoffs com
  seção ABERTO / "EM ABERTO" / "próximos passos". **Os DOIS diretórios, sempre** — `context/` é onde
  os comandos `/<slug>-cc` e `/<slug>-handoff` gravam e `chats/` é o
  rastro bruto. Varrer só um devolve vazio sem erro, que é o pior modo de falha de uma skill de
  auditoria (achado B1 da vistoria de 2026-08-21).
- **Se as duas pastas estiverem vazias ou ausentes, DIGA ISSO** — "0 handoffs encontrados em
  `chats/` e `context/`" — nunca produza um checklist curto como se a história fosse curta.
- Histórico git: TODOs/FIXMEs introduzidos e não resolvidos; promessas em mensagens de commit.
- Qualquer `.md` do archive com `- [ ]`/`- [~]`/"EM ABERTO".

## Disciplina (red-first, da schematize-audit)
- **"Feito" sem prova volta a ABERTO.** Checkbox `- [x]` cujo teste/commit/arquivo/gate NÃO passa hoje
  vira `- [ ]` de novo. Suspeito ≠ feito.
- On-hold cuja pergunta ninguém respondeu = item aberto (com a pergunta anexada).
- ADR `proposed` eterno = item aberto (decidir accepted/rejected).

## Saída
1. Deriva o CHECKLIST exaustivo (1 item/linha, cada um com **como provar**), na convenção de 2 níveis
   (`- [ ]` máquina · `- [H ]` humano · `- [~]` on-hold), agrupado por origem.
2. Grava em `.schematize/overdev/CHECKLIST.md` (+ OBJETIVO.md com o alvo "sanear o histórico recuperado").
3. Espelha no `<projeto>/<projeto>_archive/overdev/`.
4. Reporta a contagem por fonte e sugere `schematize overdev start "sanear archive"` (ou o botão) pra
   rodar sob a trava do overdev — o agente não para até fechar.

> Se quiser o VEREDITO formal (cobertura A/A + órfãos RED que travam), rode `/audit-run` depois.
