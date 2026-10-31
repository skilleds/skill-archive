---
description: Mapa da skill schematize-archive (o archive criticidade 0 + gerar afazeres do histórico).
---
**schematize-archive** — o archive da casa como CRITICIDADE 0.
- `/archive-init` — materializa o `<projeto>/<projeto>_archive/` obrigatório (nunca deixa ausente).
- `/archive-check` — varre o archive antes do commit (segredo, PII, binário, `.gitignore` interno, ADR duplicado, convenção de nome) e lembra o ensaio de recuperação. **Verde não é permissão para colar `.env`.**
- Ritmo (piso 26): relatório a cada 30 min em `relatorios/`, handoff a cada 6 h; carimbos em `.ritmo.json`; modelo em `assets/relatorio.template.md`.
- `/archive-todos` — GERA afazeres pro overdev a partir do histórico recuperável (o que ficou aberto).
- `/archive-load` — carrega à força o corpo normativo do archive e passa a aplicá-lo.
- `/archive-claude` — cria ou mescla o `CLAUDE.md` sempre-on do archive na raiz do repo.
- `/archive-cc` · `/archive-handoff` — context compact / handoff no archive.
- Pareia: schematize-engineering (archive §28), schematize-audit (órfãos RED), schematize-overdev-context (Fase 0), schematize-incident (postmortems moram em `postmortems/`).
