#!/usr/bin/env bash
# collect-history.sh — enumera, POR CONTAGEM, todo o historico recuperavel de um projeto.
#
# Motivo: a /archive-todos varria so `_archive/chats/` enquanto os comandos `-cc`/`-handoff` das
# skills gravam em `_archive/context/` — intersecao ZERO. A skill cuja funcao e enumerar o que
# ficou aberto devolvia VAZIO SEM ERRO (achado B1 da vistoria de 2026-08-21), o pior modo de falha
# de uma ferramenta de auditoria. Este script torna a varredura deterministica e testavel: quem
# gera o checklist parte da contagem dele, nao da memoria.
# Entrada: $1 opcional = raiz do projeto (default: diretorio atual).
# Saida: relatorio por fonte no stdout. exit 0 achou historico - exit 1 NAO ha historico recuperavel
#        (e dizer isso em voz alta e o resultado, nunca um checklist curto fingindo historia curta).
# EXCEÇÃO DECLARADA de strict mode (`schematize-shell` -> `references/piso.md` secao 1):
# COLETOR: enumera todo o histórico recuperável e soma; `grep` sem match sai 1 e é resultado normal, não erro.
set -uo pipefail
RAIZ="${1:-$PWD}"
cd "$RAIZ" || { echo "raiz inexistente: $RAIZ"; exit 2; }

# Descobre o `<projeto>_archive/` (irmao dos microservicos, dentro do projeto).
ARCH="${ARCHIVE_DIR:-}"
if [ -z "$ARCH" ]; then
  ARCH="$(find . -maxdepth 2 -type d -name '*_archive' -not -path '*/.*' 2>/dev/null | head -1)"
fi
SD=".schematize/overdev"

total=0
linha() { # linha <rotulo> <n> [detalhe]
  printf '%-46s %6s  %s\n' "$1" "$2" "${3:-}"
  total=$(( total + $2 ))
}
conta_grep() { # conta_grep <regex> <caminhos...>
  local re="$1"; shift
  local n=0
  [ "$#" -gt 0 ] && n="$(grep -rlaE "$re" "$@" 2>/dev/null | wc -l)"
  echo "$n"
}

echo "== historico recuperavel em $RAIZ"
echo "   archive: ${ARCH:-<AUSENTE - gap de criticidade 0>}"
echo

# 1) checklists (operacional vivo + espelho no archive)
# O archive ESPELHA o operacional vivo: contar os dois dobraria o mesmo item. Prefere-se o vivo.
cl_paths=()
if [ -f "$SD/CHECKLIST.md" ]; then
  cl_paths+=("$SD/CHECKLIST.md")
  if [ -n "$ARCH" ] && [ -d "$ARCH/overdev" ]; then
    while IFS= read -r f; do
      [ "$(basename "$f")" = "CHECKLIST.md" ] || cl_paths+=("$f")
    done < <(find "$ARCH/overdev" -type f -name '*.md' 2>/dev/null)
  fi
elif [ -n "$ARCH" ] && [ -d "$ARCH/overdev" ]; then
  cl_paths+=("$ARCH/overdev")
fi
abertos=0; onhold=0; humanos=0
if [ "${#cl_paths[@]}" -gt 0 ]; then
  abertos="$(grep -rhaE '^[[:space:]]*- \[ \]' "${cl_paths[@]}" 2>/dev/null | wc -l)"
  humanos="$(grep -rhaE '^[[:space:]]*- \[H \]' "${cl_paths[@]}" 2>/dev/null | wc -l)"
  onhold="$(grep -rhaE '^[[:space:]]*- \[~\]' "${cl_paths[@]}" 2>/dev/null | wc -l)"
fi
linha "checklist: itens '- [ ]' (maquina)" "$abertos"
linha "checklist: itens '- [H ]' (humano)" "$humanos"
linha "checklist: itens '- [~]' (on-hold = ABERTO)" "$onhold"

# 2) handoffs — os DOIS diretorios. Varrer so um foi o defeito B1.
for d in chats context; do
  n=0; [ -n "$ARCH" ] && [ -d "$ARCH/$d" ] && n="$(find "$ARCH/$d" -type f -name '*.md' 2>/dev/null | wc -l)"
  n_ab=0
  [ "$n" -gt 0 ] && n_ab="$(conta_grep 'EM ABERTO|ABERTO|proximos passos|próximos passos' "$ARCH/$d")"
  linha "handoffs em $d/" "$n" "$n_ab com secao ABERTO"
done

# 3) ADRs proposed (nunca viraram accepted/rejected)
n=0; [ -n "$ARCH" ] && [ -d "$ARCH/decisoes" ] && n="$(conta_grep 'status:[[:space:]]*proposed|\*\*proposed\*\*' "$ARCH/decisoes")"
linha "ADRs 'proposed' sem desfecho" "$n"

# 4) perguntas parkeadas e paradas prematuras
n=0; n="$(find . -name 'PERGUNTAS*' -not -path '*/.git/*' 2>/dev/null | wc -l)"
linha "arquivos PERGUNTAS-OVERDEV" "$n"
n=0; n="$(find . -name 'premature-stops*' -not -path '*/.git/*' 2>/dev/null | wc -l)"
linha "logs premature-stops" "$n"

# 5) qualquer .md do archive com item aberto (fora do overdev/)
n=0
[ -n "$ARCH" ] && n="$(grep -rlaE '^[[:space:]]*- \[( |~)\]|EM ABERTO' "$ARCH" --include='*.md' 2>/dev/null | grep -cv "^$ARCH/overdev/")"
linha "outros .md do archive com item aberto" "$n"

# 6) TODO/FIXME vivos no codigo
n="$(grep -rlaE '(TODO|FIXME|XXX|HACK)[:( ]' . --include='*.go' --include='*.rs' --include='*.py' \
      --include='*.sh' --include='*.mjs' --include='*.js' --include='*.ts' --include='*.ex' \
      --include='*.rb' --include='*.cs' --include='*.zig' 2>/dev/null | grep -v '/.git/' | wc -l)"
linha "arquivos de codigo com TODO/FIXME" "$n"

echo
if [ -z "$ARCH" ]; then
  echo "✖ SEM ARCHIVE: gap de observabilidade de criticidade 0. Rode /archive-init antes de qualquer coisa."
  exit 1
fi
if [ "$total" -eq 0 ]; then
  echo "✖ ZERO historico recuperavel encontrado. Isso NAO autoriza um checklist curto:"
  echo "  ou o projeto e novo, ou o rastro nao esta sendo gravado (que ja e o 1o afazer)."
  exit 1
fi
echo "✔ $total sinais recuperaveis — derive o CHECKLIST a partir desta contagem, fonte a fonte."
