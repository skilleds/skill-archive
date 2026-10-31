#!/usr/bin/env bash
# collect-history.test.sh — o VERMELHO VISTO da coleta de historico (B1 da vistoria de 2026-08-21).
#
# Motivo: a /archive-todos varria so `chats/` enquanto as skills gravam handoff em `context/`.
# Intersecao ZERO: a skill de auditoria devolvia VAZIO SEM ERRO. Este teste monta projetos de
# mentira e exige que (a) handoff SO em context/ seja encontrado, (b) archive ausente reprove,
# (c) archive vazio reprove em vez de virar "checklist curto".
# Entrada: nenhuma. Saida: exit 0 todos os casos passam - exit 1 algum caso falhou.
# EXCEÇÃO DECLARADA de strict mode (`schematize-shell` -> `references/piso.md` secao 1):
# harness de teste roda sem `-e` de propósito — ele precisa continuar depois de um caso
# vermelho para reportar TODOS, em vez de parar no primeiro.
set -uo pipefail
S="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/collect-history.sh"
W="$(mktemp -d)"; trap 'rm -rf "$W"' EXIT
rc=0

echo "── B1: handoff SO em context/ (o caso real do catalogo) e ENCONTRADO"
P="$W/proj"; mkdir -p "$P/proj_archive/context" "$P/proj_archive/chats"
cat > "$P/proj_archive/context/2026-08-21-context.md" <<'M'
# handoff
## FEITO
- coisa
## EM ABERTO
- outra coisa
M
OUT=$(bash "$S" "$P" 2>&1); z=$?
if [ "$z" -eq 0 ] && grep -qE 'handoffs em context/ +1' <<<"$OUT"; then
  echo "  ✔ achou 1 handoff em context/ (a varredura antiga devolvia zero)"
else echo "  ✖ nao achou: $OUT"; rc=1; fi

echo "── archive AUSENTE reprova (gap de criticidade 0)"
Q="$W/sem"; mkdir -p "$Q"
OUT=$(bash "$S" "$Q" 2>&1); z=$?
if [ "$z" -eq 1 ] && grep -q 'SEM ARCHIVE' <<<"$OUT"; then echo "  ✔ exit 1"; else echo "  ✖ exit $z: $OUT"; rc=1; fi

echo "── archive VAZIO reprova em vez de virar 'checklist curto'"
R="$W/vazio"; mkdir -p "$R/r_archive/chats" "$R/r_archive/context"
OUT=$(bash "$S" "$R" 2>&1); z=$?
if [ "$z" -eq 1 ] && grep -q 'ZERO historico recuperavel' <<<"$OUT"; then echo "  ✔ exit 1 e diz em voz alta"; else echo "  ✖ exit $z: $OUT"; rc=1; fi

echo
[ $rc -eq 0 ] && echo "✔ collect-history.test.sh: todos os casos" || echo "✖ collect-history.test.sh: falhou"
exit $rc
