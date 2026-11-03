#!/usr/bin/env bash
# Vermelho primeiro do gate do archive. Cada caso planta UMA coisa que nunca pode entrar.
# Nota: os segredos aqui sao sinteticos (nao correspondem a credencial nenhuma) — plantar segredo
# real num fixture de teste seria cometer o defeito que o gate persegue.
# EXCEÇÃO DECLARADA de strict mode (`schematize-shell` -> `references/piso.md` secao 1):
# harness de teste roda sem `-e` de propósito — ele precisa continuar depois de um caso
# vermelho para reportar TODOS, em vez de parar no primeiro.
set -u
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
G="$AQUI/check-archive.sh"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
ok=0; fail=0
checa() { local nome="$1" esp="$2" agulha="$3"; shift 3
  local saida; saida="$("$@" 2>&1)"; local rc=$?
  if [ "$rc" != "$esp" ]; then echo "  ✖ $nome: exit $rc, esperado $esp"; sed 's/^/      /' <<<"$saida"; fail=$((fail+1)); return; fi
  if [ -n "$agulha" ] && ! grep -qF -- "$agulha" <<<"$saida"; then echo "  ✖ $nome: exit certo, saida sem \"$agulha\""; sed 's/^/      /' <<<"$saida"; fail=$((fail+1)); return; fi
  echo "  ✔ $nome"; ok=$((ok+1)); }

# gh de mentira: visibilidade controlada por STUB_PRIVATE (true|false|erro). Nunca toca a rede.
mkdir -p "$TMP/stubs"
cat > "$TMP/stubs/gh" <<'GH'
#!/usr/bin/env bash
case "${STUB_PRIVATE:-true}" in true) echo true ;; false) echo false ;; *) exit 1 ;; esac
GH
chmod +x "$TMP/stubs/gh"; export PATH="$TMP/stubs:$PATH"

novo() { # $1 = nome do fixture -> ecoa o caminho
  local d="$TMP/$1"; rm -rf "${d:?}"; mkdir -p "$d"/{chats,context,decisoes,overdev}
  printf '# sessao\n\nfizemos o gate do archive.\n' > "$d/chats/2026-08-21-saneamento.md"
  printf '# handoff\n' > "$d/context/2026-08-21-fase-b-context.md"
  printf '# ADR-0001\n' > "$d/decisoes/ADR-0001-planta-unica.md"
  git -C "$d" init -q 2>/dev/null
  git -C "$d" remote add origin git@github.com:org/projeto_archive.git 2>/dev/null
  echo "$d"
}

echo "== verde de partida =="
d="$(novo ok)"
checa "archive limpo passa" 0 "convencao de nome ok" bash "$G" "$d"
checa "e diz que verde nao e permissao" 0 "nao e permissao para colar .env" bash "$G" "$d"

d="$TMP/naoarchive"; mkdir -p "$d"; echo x > "$d/leia.md"
checa "diretorio que nao e archive sai 2" 2 "nao parece um" bash "$G" "$d"

echo "== ritmo (piso 26) =="
d="$(novo ritmo)"
checa "sem .ritmo.json avisa" 0 ".ritmo.json ausente" bash "$G" "$d"
checa "sem relatorios/ avisa" 0 "relatorios/ ausente" bash "$G" "$d"
mkdir -p "$d/relatorios"; : > "$d/relatorios/2026-10-31_1000.md"
printf '{"ultimo_relatorio":"2020-01-01T00:00:00Z","ultimo_handoff":"2020-01-01T00:00:00Z"}\n' > "$d/.ritmo.json"
checa "carimbo de relatorio velho avisa" 0 "ultimo_relatorio com" bash "$G" "$d"
checa "carimbo de handoff velho avisa" 0 "ultimo_handoff com" bash "$G" "$d"
agora="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
printf '{"ultimo_relatorio":"%s","ultimo_handoff":"%s"}\n' "$agora" "$agora" > "$d/.ritmo.json"
checa "carimbos frescos nao avisam" 0 "convencao de nome ok" bash "$G" "$d"
if bash "$G" "$d" 2>&1 | grep -q "passou do limite"; then echo "  ✖ fresco avisou"; fail=$((fail+1)); else echo "  ✔ fresco sem aviso"; ok=$((ok+1)); fi
: > "$d/relatorios/lixo.md"
checa "relatorio fora da convencao avisa" 0 "relatorios/lixo.md fora da convencao" bash "$G" "$d"

echo "== segredo =="
d="$(novo auth)";  printf 'colei o curl:\nAuthorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9\n' >> "$d/chats/2026-08-21-saneamento.md"
checa "header Authorization colado reprova" 1 "header Authorization com credencial" bash "$G" "$d"

d="$(novo pem)"; printf -- '-----BEGIN OPENSSH PRIVATE KEY-----\nb3BlbnNzaC1rZXktdjEAAAAA\n' > "$d/chats/2026-08-21-chave.md"
checa "bloco PEM de chave privada reprova" 1 "chave privada" bash "$G" "$d"

d="$(novo tok)"; printf 'o token era ghp_%s\n' "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" >> "$d/chats/2026-08-21-saneamento.md"
checa "token de provedor reprova" 1 "token de provedor" bash "$G" "$d"

d="$(novo conn)"; printf 'DATABASE_URL=postgres://app:umaSenhaQualquer@db.interno:5432/prd\n' >> "$d/chats/2026-08-21-saneamento.md"
checa "string de conexao com senha reprova" 1 "string de conexao com senha" bash "$G" "$d"

d="$(novo env)"; printf 'CLIENT_SECRET=abcdefgh12345678\n' > "$d/chats/2026-08-21-env.md"
checa "variavel de segredo com valor reprova" 1 "variavel de segredo" bash "$G" "$d"

echo "== o relatorio nao vira a segunda copia do segredo =="
d="$(novo naoecoa)"; printf 'CLIENT_SECRET=abcdefgh12345678\n' > "$d/chats/2026-08-21-env.md"
saida="$(bash "$G" "$d" 2>&1)"
if grep -q 'abcdefgh12345678' <<<"$saida"; then echo "  ✖ o gate ECOOU o segredo na saida"; fail=$((fail+1))
else echo "  ✔ o gate aponta arquivo:linha e nao ecoa o valor"; ok=$((ok+1)); fi

echo "== dado pessoal =="
d="$(novo cpf)"; printf 'cliente 529.982.247-25 reclamou\n' >> "$d/chats/2026-08-21-saneamento.md"
checa "CPF formatado reprova" 1 "CPF formatado" bash "$G" "$d"
d="$(novo cartao)"; printf 'pagou com 4111111111111111\n' >> "$d/chats/2026-08-21-saneamento.md"
checa "numero de cartao reprova" 1 "numero de cartao" bash "$G" "$d"

echo "== o archive nao e bucket =="
d="$(novo bin)"; head -c 2000000 /dev/zero > "$d/chats/captura.png"
checa "binario de 2MB reprova" 1 "nao bucket" bash "$G" "$d"

echo "== gitignore dentro do archive =="
d="$(novo ign)"; printf '*.log\n' > "$d/.gitignore"
checa ".gitignore com regras reprova" 1 "nao pode ter entrado" bash "$G" "$d"

echo "== convencao de nome =="
d="$(novo nome)"; printf '# x\n' > "$d/chats/anotacoes.md"
checa "arquivo sem data na frente avisa" 0 "ordem alfabetica virar cronologica" bash "$G" "$d"
d="$(novo adr)"; printf '# y\n' > "$d/decisoes/ADR-0001-outra-coisa.md"
checa "numero de ADR reusado reprova" 1 "numero reusado" bash "$G" "$d"

for pasta in plan scan qa audit postmortems pentest orchestration scaffold; do
  d="$(novo n_$pasta)"; mkdir -p "$d/$pasta"; printf '# x\n' > "$d/$pasta/rascunho.md"
  checa "$pasta/ sem data na frente avisa" 0 "$pasta/rascunho.md fora da convencao" bash "$G" "$d"
  d="$(novo v_$pasta)"; mkdir -p "$d/$pasta"; printf '# x\n' > "$d/$pasta/2026-10-14-ok.md"
  checa "$pasta/ com nome certo nao avisa" 0 "convencao de nome ok" bash "$G" "$d"
done
d="$(novo ca)"; mkdir -p "$d/context_agent"; printf 'x\n' > "$d/context_agent/ctx-final.txt"
checa "context_agent/ fora de #N.txt avisa" 0 "context_agent/ctx-final.txt fora da convencao" bash "$G" "$d"
d="$(novo cav)"; mkdir -p "$d/context_agent"; printf 'x\n' > "$d/context_agent/#3.txt"
checa "context_agent/#3.txt passa sem aviso" 0 "convencao de nome ok" bash "$G" "$d"
d="$(novo od)"; printf '# x\n' > "$d/overdev/CONTEXTO-hoje.md"
checa "overdev/ briefing sem AAAA-MM-DD-CONTEXTO.md avisa" 0 "overdev/CONTEXTO-hoje.md fora da convencao" bash "$G" "$d"
d="$(novo odv)"; printf '# x\n' > "$d/overdev/2026-10-14-CONTEXTO.md"
checa "overdev/2026-10-14-CONTEXTO.md passa" 0 "convencao de nome ok" bash "$G" "$d"

echo "== repo proprio =="
d="$(novo semgit)"; rm -rf "${d:?}/.git"
checa "archive que nao e repo git reprova" 1 "repo PROPRIO e PRIVADO" bash "$G" "$d"
d="$(novo semremote)"; git -C "$d" remote remove origin 2>/dev/null
checa "sem remote REPROVA (piso 22: nao sobrevive a maquina)" 1 "nao sobrevive a perda da maquina" bash "$G" "$d"
d="$(novo publico)"
export STUB_PRIVATE=false; checa "remote PUBLICO reprova" 1 "PUBLICO" bash "$G" "$d"
export STUB_PRIVATE=erro; checa "visibilidade nao confirmavel so avisa" 0 "nao foi possivel confirmar" bash "$G" "$d"
export STUB_PRIVATE=true; checa "remote privado passa" 0 "convencao de nome ok" bash "$G" "$d"; unset STUB_PRIVATE

echo "== --conclusao (piso 22) e --ativo (piso 26) =="
d="$(novo concl)"; mkdir -p "$d/custos"
git init -q --bare "$TMP/concl-remoto.git"; git -C "$d" remote set-url origin "$TMP/concl-remoto.git"
git -C "$d" -c user.name=t -c user.email=t@t add -A; git -C "$d" -c user.name=t -c user.email=t@t commit -qm i; git -C "$d" push -q -u origin HEAD 2>/dev/null
checa "conclusao com tudo empurrado passa" 0 "convencao de nome ok" bash "$G" --conclusao "$d"
echo y > "$d/chats/2026-08-22-novo.md"
checa "conclusao com arvore suja REPROVA" 1 "arvore do archive suja" bash "$G" --conclusao "$d"
git -C "$d" -c user.name=t -c user.email=t@t add -A; git -C "$d" -c user.name=t -c user.email=t@t commit -qm j
checa "conclusao com commit nao empurrado REPROVA" 1 "HEAD do archive != origin" bash "$G" --conclusao "$d"
checa "sem --conclusao a arvore/commit pendente passa (pre-commit)" 0 "convencao de nome ok" bash "$G" "$d"
d="$(novo semcustos)"
checa "custos/ ausente avisa" 0 "custos/ ausente" bash "$G" "$d"
checa "custos/ ausente REPROVA na conclusao" 1 "custos/ ausente" bash "$G" --conclusao "$d"
mkdir -p "$d/custos"; printf '{quebrado' > "$d/custos/custos.json"
checa "custos.json invalido reprova" 1 "custos/custos.json nao e JSON valido" bash "$G" "$d"
printf '{"total_usd": 1.5}\n' > "$d/custos/custos.json"
checa "custos.json valido passa" 0 "convencao de nome ok" bash "$G" "$d"
d="$(novo ativo)"
checa "sem ritmo, --ativo REPROVA" 1 ".ritmo.json ausente" bash "$G" --ativo "$d"
mkdir -p "$d/relatorios"; : > "$d/relatorios/2026-10-31_1000.md"
printf '{"ultimo_relatorio":"2020-01-01T00:00:00Z",\n "ultimo_handoff":"2020-01-01T00:00:00Z"}\n' > "$d/.ritmo.json"
checa "carimbo velho (JSON em 2 linhas), --ativo REPROVA" 1 "ultimo_relatorio com" bash "$G" --ativo "$d"
checa "carimbo velho sem --ativo so avisa" 0 "ultimo_relatorio com" bash "$G" "$d"

echo; echo "check-archive: $ok ok, $fail falha(s)"; [ "$fail" = 0 ]
