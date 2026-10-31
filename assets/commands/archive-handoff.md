---
description: schematize-archive — gera o handoff (context.md + checklist.md) no archive, sem compactar.
---
Gere o handoff em `<projeto>/<projeto>_archive/context/`: `AAAA-MM-DD-<slug>-context.md` (o que foi
feito, decisões, o que o `check-archive.sh` acusou, estado do archive e do remote privado) e
`AAAA-MM-DD-<slug>-checklist.md` (FEITO vs ABERTO, nas três classes da casa: `- [ ]` máquina ·
`- [H ]` humano · `- [~]` on-hold). Não compacte — só grave, commite e dê push no repo do archive.
Nunca grave segredo, `.env` ou PII no handoff.

Ao gravar, **renove `ultimo_handoff`** em `<projeto>_archive/.ritmo.json` (ISO-8601, `date -u +%Y-%m-%dT%H:%M:%SZ`),
preservando `ultimo_relatorio`; crie o arquivo se faltar. O handoff deve bastar para uma sessão nova
retomar só com ele (engineering piso 26: `context.md` + `checklist.md` completos). Mesmo commit.
