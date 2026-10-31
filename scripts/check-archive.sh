#!/usr/bin/env bash
# schematize-archive — a rede embaixo do trapezio. Varre o archive antes do commit procurando o que
# NUNCA pode entrar (references/archive.md) e confere a convencao de nome.
#
# Honestidade sobre o alcance: segredo tem infinitas formas, e este script conhece um punhado.
# VERDE AQUI NAO E PERMISSAO PARA COLAR `.env` — e so a ultima checagem antes de um commit que,
# uma vez feito, nao se desfaz (segredo commitado esta vazado; a acao e ROTACIONAR).
#
# uso: check-archive.sh [dir-do-archive]   ·  0 = passa · 1 = REPROVA · 2 = nao e um archive
# EXCEÇÃO DECLARADA de strict mode (`schematize-shell` -> `references/piso.md` secao 1):
# este script é um COLETOR — ele varre tudo e SOMA os achados. Com `set -e` abortaria no
# primeiro problema e reportaria um, escondendo os outros. Por isso `set -uo pipefail` sem `-e`.
set -uo pipefail
raiz="${1:-.}"
erros=(); avisos=()

# Reconhece o archive pela planta, nao pelo nome do diretorio (o nome varia com o projeto).
if [ ! -d "$raiz/chats" ] && [ ! -d "$raiz/decisoes" ] && [ ! -d "$raiz/overdev" ]; then
  echo "✖ $raiz nao parece um <projeto>_archive (sem chats/, decisoes/ nem overdev/)." >&2
  exit 2
fi

arquivos=$(find "$raiz" -type f -not -path '*/.git/*' 2>/dev/null)
[ -n "$arquivos" ] || { echo "✖ archive vazio — nao ha rastro para verificar." >&2; exit 2; }

# --- 1. segredo -------------------------------------------------------------------------------
# Cada padrao tem um nome legivel, porque "deu match na regex 3" nao ajuda ninguem a consertar.
padroes=(
  'header Authorization com credencial|[Aa]uthorization:[[:space:]]*(Bearer|Basic)[[:space:]]+[A-Za-z0-9._~+/=-]{16,}'
  'chave privada (bloco PEM)|-----BEGIN[[:space:]]+(RSA|EC|OPENSSH|PGP|DSA)?[[:space:]]*PRIVATE KEY'
  'token de provedor|(gh[pousr]_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9]{20,}|xox[baprs]-[A-Za-z0-9-]{10,}|AKIA[0-9A-Z]{16})'
  'string de conexao com senha|(postgres|postgresql|mysql|mongodb(\+srv)?|redis|amqp)://[^:@[:space:]]+:[^@[:space:]]+@'
  'variavel de segredo com valor|(PASSWORD|SENHA|SECRET|API_KEY|APIKEY|PRIVATE_KEY|ACCESS_TOKEN|CLIENT_SECRET)[[:space:]]*=[[:space:]]*[^[:space:]$#"'"'"'{<]{8,}'
)
for p in "${padroes[@]}"; do
  rotulo="${p%%|*}"; regex="${p#*|}"
  # `-e` obrigatorio: o padrao do PEM comeca com `-----`, e sem isto o grep o le como opcao e nunca
  # casa — um gate silenciosamente cego justo para chave privada.
  achados=$(grep -rEn --binary-files=without-match -e "$regex" "$raiz" --exclude-dir=.git 2>/dev/null | head -5)
  [ -n "$achados" ] && while IFS= read -r l; do
    # Mostra arquivo:linha, NUNCA o valor casado — o relatorio do gate nao pode ser a segunda copia.
    erros+=("$rotulo em ${l%%:*}:$(cut -d: -f2 <<<"$l")")
  done <<< "$achados"
done

# --- 2. dado pessoal (o que da para pegar por forma) -------------------------------------------
cpf=$(grep -rEn --binary-files=without-match '\b[0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}\b' "$raiz" --exclude-dir=.git 2>/dev/null | head -3)
[ -n "$cpf" ] && while IFS= read -r l; do erros+=("CPF formatado em ${l%%:*}:$(cut -d: -f2 <<<"$l")"); done <<< "$cpf"
cartao=$(grep -rEn --binary-files=without-match '\b(4[0-9]{15}|5[1-5][0-9]{14}|3[47][0-9]{13})\b' "$raiz" --exclude-dir=.git 2>/dev/null | head -3)
[ -n "$cartao" ] && while IFS= read -r l; do erros+=("numero de cartao em ${l%%:*}:$(cut -d: -f2 <<<"$l")"); done <<< "$cartao"

# --- 3. binario grande: o archive e texto que conta a evolucao, nao bucket ---------------------
while IFS= read -r f; do
  [ -n "$f" ] || continue
  tam=$(stat -c %s "$f" 2>/dev/null || echo 0)
  case "$f" in
    *.png|*.jpg|*.jpeg|*.gif|*.mp4|*.mov|*.zip|*.tar|*.gz|*.pdf|*.sqlite|*.db|*.dump)
      [ "$tam" -gt 1048576 ] && erros+=("binario de $((tam/1024))KB em ${f#$raiz/} — o archive e texto, nao bucket") ;;
    *) [ "$tam" -gt 10485760 ] && avisos+=("arquivo de $((tam/1048576))MB em ${f#$raiz/}") ;;
  esac
done <<< "$arquivos"

# --- 4. .gitignore dentro do archive: anula o repo cuja funcao e guardar rastro ----------------
if [ -f "$raiz/.gitignore" ] && grep -qvE '^\s*(#|$)' "$raiz/.gitignore" 2>/dev/null; then
  erros+=(".gitignore com regras dentro do archive — o que nao pode ser guardado nao pode ter entrado")
fi

# --- 5. convencao de nome ----------------------------------------------------------------------
for d in chats context plan scan qa audit postmortems pentest orchestration scaffold; do
  [ -d "$raiz/$d" ] || continue
  for f in "$raiz/$d"/*; do
    [ -f "$f" ] || continue
    b="$(basename "$f")"
    case "$b" in README.md|.gitkeep) continue ;; esac
    grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}-[a-z0-9-]+' <<<"$b" \
      || avisos+=("$d/$b fora da convencao AAAA-MM-DD-<slug>.md — data na frente e o que faz ordem alfabetica virar cronologica")
  done
done
# context_agent/: contexto portavel gerado pelo app, nome #N.txt (N inteiro sequencial)
if [ -d "$raiz/context_agent" ]; then
  for f in "$raiz/context_agent"/*; do
    [ -f "$f" ] || continue
    b="$(basename "$f")"
    case "$b" in README.md|.gitkeep) continue ;; esac
    grep -qE '^#[0-9]+\.txt$' <<<"$b" \
      || avisos+=("context_agent/$b fora da convencao #N.txt — o app ordena e retoma pelo numero")
  done
fi
# overdev/: o briefing e AAAA-MM-DD-CONTEXTO.md (estado do control-plane, ex. iterations, nao e checado)
if [ -d "$raiz/overdev" ]; then
  for f in "$raiz/overdev"/*CONTEXTO*; do
    [ -f "$f" ] || continue
    b="$(basename "$f")"
    grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}-CONTEXTO\.md$' <<<"$b" \
      || avisos+=("overdev/$b fora da convencao AAAA-MM-DD-CONTEXTO.md")
  done
fi
# --- 5b. ritmo de registro (engineering piso 26): relatorio 30 min, handoff 6 h ------------------
# So AVISA (nao reprova): carimbo velho e sinal de trabalho sem registro, mas nao e vazamento.
# Idade so importa em trabalho ativo; fora dele o aviso e informativo.
if [ -d "$raiz/relatorios" ]; then
  for f in "$raiz/relatorios"/*; do
    [ -f "$f" ] || continue
    b="$(basename "$f")"
    case "$b" in README.md|.gitkeep) continue ;; esac
    grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{4}\.md$' <<<"$b" \
      || avisos+=("relatorios/$b fora da convencao AAAA-MM-DD_HHMM.md")
  done
else
  avisos+=("relatorios/ ausente — piso 26: relatorio a cada 30 min em trabalho ativo (/archive-init cria)")
fi
if [ -f "$raiz/.ritmo.json" ]; then
  agora=$(date +%s)
  for par in "ultimo_relatorio|1800|30 min" "ultimo_handoff|21600|6 h"; do
    chave="${par%%|*}"; resto="${par#*|}"; lim="${resto%%|*}"; rot="${resto#*|}"
    val=$(grep -oE "\"$chave\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" "$raiz/.ritmo.json" | sed -E 's/.*:[[:space:]]*"([^"]*)"/\1/')
    if [ -z "$val" ]; then avisos+=(".ritmo.json sem $chave (ISO-8601) — carimbo ausente"); continue; fi
    ts=$(date -d "$val" +%s 2>/dev/null) || { avisos+=(".ritmo.json: $chave='$val' nao e ISO-8601"); continue; }
    idade=$((agora-ts))
    [ "$idade" -gt "$lim" ] && avisos+=("$chave com $((idade/60)) min — passou do limite de $rot (piso 26); se ha trabalho ativo, registre agora")
  done
else
  avisos+=(".ritmo.json ausente — piso 26: carimbos {ultimo_relatorio, ultimo_handoff} (/archive-init cria)")
fi

if [ -d "$raiz/decisoes" ]; then
  declare -A vistos=()
  for f in "$raiz/decisoes"/*.md; do
    [ -f "$f" ] || continue
    b="$(basename "$f")"
    [ "$b" = "README.md" ] && continue
    if ! grep -qE '^ADR-[0-9]{4}-[a-z0-9-]+\.md$' <<<"$b"; then
      avisos+=("decisoes/$b fora do padrao ADR-NNNN-<slug>.md"); continue
    fi
    n="${b:4:4}"
    if [ -n "${vistos[$n]:-}" ]; then
      erros+=("decisoes/: numero ADR $n usado duas vezes (${vistos[$n]} e $b) — numero reusado faz duas decisoes responderem pela mesma referencia")
    fi
    vistos[$n]="$b"
  done
fi

# --- 6. o archive e repo git PRIVADO proprio ----------------------------------------------------
if [ -d "$raiz/.git" ]; then
  remoto=$(git -C "$raiz" remote get-url origin 2>/dev/null || true)
  [ -n "$remoto" ] || avisos+=("archive sem remote 'origin' — repo local nao sobrevive a perda da maquina")
else
  erros+=("$raiz nao e repo git — o archive e um repo PROPRIO e PRIVADO, nao uma pasta")
fi

for a in "${avisos[@]:-}"; do [ -n "$a" ] && echo "  ! $a" >&2; done
if [ ${#erros[@]} -gt 0 ]; then
  echo "✖ archive REPROVADO — ${#erros[@]} problema(s):" >&2
  for e in "${erros[@]}"; do echo "  · $e" >&2; done
  echo "  Se ja foi commitado: ROTACIONE a credencial primeiro. Reescrever historico vem depois, e nao desfaz o vazamento." >&2
  exit 1
fi
echo "✔ archive: nenhum segredo/PII/binario conhecido, convencao de nome ok. (Verde aqui nao e permissao para colar .env.)"
