---
description: schematize-archive — context compact: grava o handoff no archive e roda /compact.
---
Antes de compactar, **grave o handoff** em `<projeto>/<projeto>_archive/context/` no par
**context + checklist** do padrão da `schematize-archive` (prefixo `AAAA-MM-DD-<slug>-`), FEITO vs
ABERTO. Inclua: o que foi criado ou recuperado no archive, os achados do `scripts/check-archive.sh`
que ficaram abertos, os afazeres gerados pelo `/archive-todos` ainda não tickeados e o estado do
commit/push do repo do archive. Nunca inclua segredo ou PII. Só então rode `/compact`.
