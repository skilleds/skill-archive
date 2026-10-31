---
description: schematize-archive — carrega à força TODO o corpo normativo do archive (criticidade 0) e passa a aplicá-lo nesta sessão.
---
Carregue **agora** o corpo normativo da skill `schematize-archive`. A partir daqui, nesta sessão,
isto **não é opcional**.

1. **Leia na íntegra, sem trabalhar de memória.** Caminho:
   `.claude/skills/schematize-archive/references/*.md` (projeto) ou
   `~/.claude/skills/schematize-archive/references/*.md` (global):
   - `archive.md` — a planta do `<projeto>/<projeto>_archive/` (repo git privado, o que mora em cada
     pasta, convenção de nome, recuperação).
   - `gerar-afazeres.md` — como o `/archive-todos` deriva o ABERTO do histórico recuperável.
2. **Rode o gate no projeto atual** antes de opinar:
   `bash .claude/skills/schematize-archive/scripts/check-archive.sh .`
3. **Aplique daqui em diante:** archive ausente é o 1º item a criar; decisão, plano e handoff viram
   arquivo durável no archive (ADRs em `decisoes/`, postmortems em `postmortems/` conforme
   `schematize-incident`, handoffs em `context/`); nunca `.env`, segredo ou PII no archive. Diga qual
   piso está aplicando quando ele mudar o que você ia fazer.
