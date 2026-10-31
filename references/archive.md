# O `<projeto>/<projeto>_archive/` — estrutura obrigatória (criticidade 0)

DENTRO do dir do projeto: `<projeto>/<projeto>_archive/` — **irmão dos diretórios de microserviços** (não irmão do projeto). TUDO fica dentro do projeto. O `<projeto>` é o NOME DO PROJETO — o prefixo comum dos microserviços (`<projeto>_<microservice>`, ex.: `schematize_cli_rs`/`schematizeskills_api_rs` → `schematize`) — pra o archive nunca misturar com o de outro projeto. O motor `schematize overdev start` já cria e
espelha `overdev/`. Se o projeto não tem archive, **criá-lo é o 1º item** — nunca siga sem archive.

## Estrutura — a planta CANÔNICA (esta skill é a dona; as outras apontam para cá)

> Até 2026-08-21 havia **três plantas concorrentes** no catálogo (aqui, em
> `schematize-docs/references/indice-diagramas.md` e em `schematize-scaffold`), cada uma com um
> conjunto de pastas diferente — e **quatro caminhos de ADR** distintos, o que tornava o piso
> *"ADR `proposed` é órfão RED"* inexequível por construção: o `/docs-adr` gravava num lugar, a
> `/archive-todos` procurava noutro e a `/audit-run` num terceiro (achado B2/B2b). Esta é a planta
> única; qualquer outra citação do catálogo é **ponteiro para cá**, nunca uma segunda definição.

```
<projeto>/<projeto>_archive/
  overdev/     # OBJETIVO.md, PLAN.md, DECISOES.md, CHECKLIST.md, NOTAS.md,
               #   premature-stops.log, PERGUNTAS-OVERDEV.txt e o briefing da Fase 0
               #   AAAA-MM-DD-CONTEXTO.md (schematize-overdev-context)
  index/       # MAPA.md + INDEX_GLOBAL.md + INDEX_FUNCTIONS.md + grafos (§39)
  decisoes/    # ADRs no ciclo proposed -> accepted/rejected (uma decisão = um arquivo datado).
               #   CAMINHO ÚNICO de ADR da casa: quem grava (/docs-adr), quem lê (/archive-todos)
               #   e quem audita (/audit-run) usam ESTE. Nada de `docs/adr/` nem `archive/adr/`.
  postmortems/ # postmortems blameless de incidente, um arquivo por incidente (schematize-incident →
               #   references/postmortem.md); o rito de incidente mora lá, o ARQUIVO mora aqui
  chats/       # rastro BRUTO da sessão: cada mensagem extraída pelo `schematize archive`
  context/     # handoffs RICOS de contexto: os pares context.md + checklist.md (FEITO-vs-ABERTO)
               #   gravados por `/<slug>-cc` e `/<slug>-handoff` (todas as skills de linguagem e de domínio)
  context_agent/ # contexto portável `#N.txt` gerado pelo `schematize archive` (entre PCs/apps)
  plan/        # planos do /eng-plan (fases + DoD + checklist)
  scan/        # achados do /eng-scan
  qa/          # planos e relatórios do Q.A. plan-first (/qa-plan, /qa-run)
  audit/       # relatórios da schematize-audit
  pentest/     # relatórios da schematize-pentest
  orchestration/ # checkpoints e briefs da orquestração (schematize-engineering)
  scaffold/    # relatórios do scaffold de projeto novo (schematize-scaffold)
  relatorios/  # RELATÓRIO de andamento a cada 30 min em trabalho ativo: AAAA-MM-DD_HHMM.md
               #   (modelo em assets/relatorio.template.md; engineering piso 26)
  .ritmo.json  # carimbos {"ultimo_relatorio","ultimo_handoff"} em ISO-8601 (versionado, não ignorado)
```

> **Ritmo de registro (engineering piso 26 — a regra mora lá, não é repetida aqui).** Em trabalho
> ativo: RELATÓRIO a cada 30 min em `relatorios/` e HANDOFF a cada 6 h (e em fim de sessão, marco ou
> compact) em `context/`, completo o bastante para uma sessão nova retomar só com ele
> (`context.md` + `checklist.md`). Cada registro atualiza o carimbo em `.ritmo.json` e entra no git
> na hora. O relatório lista os agents vivos; os sem pendência são encerrados (piso 25).
> `/archive-check` avisa carimbo ausente ou vencido; `/archive-handoff` renova `ultimo_handoff`.

> **`chats/` e `context/` são os DOIS lugares do rastro de sessão, e os dois são recuperáveis.**
> A distinção: `chats/` é o bruto (mensagem a mensagem, gerado por máquina); `context/` é o handoff
> escrito pelo modelo, com FEITO-vs-ABERTO. Até 2026-08-21 a planta listava só `chats/` enquanto
> todos os comandos `-cc`/`-handoff` gravavam em `context/` — e a `/archive-todos`, que varria só
> `chats/`, **devolvia vazio sem erro** (achado B1). Quem lê história tem de varrer **os dois**.
O operacional VIVO fica em `.schematize/` (overdev/, grafos/); o **espelho durável é o archive** — é
dele que a auditoria, a retomada e o `/archive-todos` recuperam a história.

## O archive é um REPOSITÓRIO git PRÓPRIO (privado, obrigatório)
Não é uma pasta solta nem lixo gitignored: é um **repo git como os dos microserviços**, cuja função é
a **evolução do projeto DOCUMENTADA**.
- **`git init`** no `<projeto>_archive/` (o motor faz no `overdev start`; o `/archive-init` garante).
- **Remote PRIVADO** obrigatório: `<projeto>_archive` (visibilidade **private** — histórico interno,
  nunca público). Ex.: `gh repo create <org>/<projeto>_archive --private`.
- **Versionado por marco:** commit a cada decisão/plano/handoff/fechamento (a mensagem conta a
  evolução). É o `git log` do archive que responde "como o sistema evoluiu".
- **NÃO é gitignored** no projeto (é um repo). O que É gitignored é o `.schematize/` (operacional volátil).

## Populado AUTOMATICAMENTE: `schematize archive`
O archive não é opcional NEM manual: rode **`schematize archive`** (ou o botão na GUI) — ele
materializa a estrutura, **extrai CADA mensagem** (você + respostas) do transcript da sessão pro
`chats/<sessão>.md` (um item por mensagem), gera o próximo **`context_agent/#N.txt`** (o contexto
portável) e **commita** no repo do archive. Rode ao fechar um marco, ao migrar de PC/app, ou sempre
que quiser um snapshot. Disciplina: **cada mensagem → item em `chats/`; cada checklist → itens no
CHECKLIST; cada decisão → arquivo em `decisoes/`**. Nada de histórico volátil.

## O que NUNCA entra no archive

Este repo guarda **transcript de sessão inteiro**. Isso é o que o torna útil — e é exatamente o que
o torna perigoso: o que passou pela tela passa pelo `chats/`. A regra é curta:

**Nunca entra:** segredo em qualquer forma (senha, token, chave privada, `.env` real, string de
conexão com credencial, cookie de sessão) · **dado real de cliente** (PII, e-mail de pessoa real,
CPF/CNPJ, endereço, dado de saúde ou financeiro — LGPD não abre exceção para "é só o histórico") ·
dump de produção · anexo binário grande (imagem, vídeo, `.zip`, backup — o archive é **texto que
conta a evolução**, não bucket) · credencial de terceiro em log colado.

**Como isso costuma entrar, na prática:** um `curl -v` colado com o header `Authorization`, um stack
trace com a connection string, um "olha o retorno da API" com o payload do cliente, um `cat .env`
para depurar. Nenhum desses parece segredo na hora — todos são.

**Se entrou:** o commit **não resolve nada**. Segredo commitado uma vez está **vazado para sempre**,
e num repo com histórico o `git rm` só o esconde da última versão. A ação é, nesta ordem:
**(1) rotacionar** a credencial · (2) registrar o incidente em `postmortems/` (rito e formato: `schematize-incident → references/postmortem.md`) e, se mudou uma regra, a decisão em `decisoes/` como ADR ·
(3) só então reescrever o histórico, se valer a pena. Para dado pessoal, o passo (1) é **notificar
quem cuida de privacidade**, porque o prazo legal corre a partir do conhecimento.

**O gate:** `scripts/check-archive.sh` varre o archive antes do commit e reprova nos padrões acima.
Ele é falível por construção (segredo tem infinitas formas) — **um verde dele não é permissão para
colar `.env`**, é só a rede embaixo do trapézio. Instale-o como `pre-commit` no repo do archive.

## Convenção de nome (para quem vai LER daqui a um ano)

Arquivo que ninguém acha é arquivo que não existe. O padrão é **um só**: prefixo de data ISO, slug
em kebab-case, sem espaço, sem acento, sem maiúscula.

| Pasta | Padrão | Exemplo |
|---|---|---|
| `chats/` | `AAAA-MM-DD-<slug-da-sessao>.md` | 2026-08-21-saneamento-catalogo.md |
| `context/` | `AAAA-MM-DD-<slug>-context.md` e o par …-checklist.md | 2026-08-21-fase-b-context.md |
| `decisoes/` | `ADR-NNNN-<slug>.md` (sequencial, **nunca reusado**) | ADR-0007-skills-json-derivado.md |
| `postmortems/` | `AAAA-MM-DD-inc-NNN-<slug>.md` (`schematize-incident → references/postmortem.md`) | 2026-10-14-inc-001-queda-auth.md |
| `plan/` · `scan/` · `qa/` · `audit/` · `pentest/` · `orchestration/` · `scaffold/` | `AAAA-MM-DD-<slug>.md` | 2026-08-21-gate-owasp.md |
| `overdev/` (briefing) | AAAA-MM-DD-CONTEXTO.md | 2026-10-14-CONTEXTO.md |
| `index/` | nome fixo: MAPA.md, INDEX_GLOBAL.md, … | — |

**Por que a data na frente:** ordenação alfabética = ordenação cronológica, em qualquer ferramenta,
sem metadado. **Por que o número do ADR nunca se reusa:** ADR rejeitado continua existindo e sendo
citado; reusar o número faz duas decisões diferentes responderem pela mesma referência.

## Retenção e rotação — o `chats/` cresce para sempre

`chats/` é o único diretório que cresce sem limite natural: cada sessão acrescenta o transcript
inteiro. Sem política, ou o repo fica pesado demais para clonar, ou alguém "limpa" no susto e leva
junto o que importava.

- **Nada é apagado.** Criticidade 0 significa que a história é **recuperável**; apagar transcript
  quebra a única promessa desta skill. Retenção aqui é **arquivamento**, não expurgo.
- **Rotação por ano:** a partir de ~200 arquivos ou ~50 MB em `chats/`, mova o que passou do ano
  corrente para `chats/<ano>/`. É `git mv` — o histórico segue completo, o `ls` volta a ser legível.
- **Compressão só do que já foi movido**, e só se doer: `chats/<ano>.tar.zst` commitado com um
  `chats/<ano>/README.md` dizendo o que tem dentro e como abrir. Nunca comprima o ano corrente: o
  que a `/archive-todos` varre precisa continuar `grep`-ável.
- **O `context/` não rotaciona.** Ele é o resumo, é pequeno, e é por onde qualquer retomada começa.
- **Sem `.gitignore` seletivo dentro do archive.** Ignorar arquivo dentro do repo cuja função é
  guardar rastro é anular o repo — o que não pode ser guardado **não pode ter entrado** (seção
  anterior).

## Recuperação — o que "recuperável" significa em comandos

Rastro que ninguém sabe restaurar não é rastro; é sensação de segurança. **Este procedimento é
testado, não presumido** — ensaie-o quando o archive estiver saudável, não no dia do incidente.

**1. Trazer de volta (máquina nova, repo do projeto perdido):**

```bash
gh repo clone <org>/<projeto>_archive   # é repo git PRIVADO próprio: sobrevive à perda do projeto
cd <projeto>_archive && git log --oneline | head -30   # a evolução, em ordem
```

**2. Achar a história de um assunto** — varra os **dois** lugares do rastro, sempre:

```bash
grep -ril "<assunto>" chats/ context/ decisoes/ | sort   # bruto + handoff + decisão
git log --oneline -S "<assunto>"                          # quando o assunto ENTROU no repo
```

**3. Reconstruir o estado de trabalho** (é isto que devolve alguém ao teclado):
o `context/` mais recente do assunto (o handoff com FEITO-vs-ABERTO) · `overdev/CHECKLIST.md` (o
juiz: o que estava aberto) · `decisoes/` (por que as coisas são como são) · `index/MAPA.md` (onde
cada coisa mora).

**4. Recolocar o operacional:** o archive é o **espelho durável**; `.schematize/` é o vivo. Copie
`overdev/` do archive de volta para `.schematize/overdev/` e siga do primeiro item aberto.

**5. Verificar que a recuperação valeu** — a pergunta é uma só: *dá para retomar sem perguntar nada
a ninguém?* Se falta contexto, o buraco é do **archive**, não da memória de quem saiu; registre o
que faltou e corrija o hábito que causou (`/archive-todos`).

**Ensaio:** clone o archive **num diretório limpo** e responda três perguntas usando só ele — o que
estava aberto? por que a decisão X foi tomada? onde mora o serviço Y? Não conseguiu: o archive
reprovou, e isso é achado.

## `/archive-init` — o que faz
1. Detecta/deriva `<projeto>/<projeto>_archive/` (irmão dos microserviços, dentro do projeto). Cria a estrutura acima se faltar.
2. **`git init`** o `<projeto>_archive/` se ainda não for repo; garante o remote **privado** `<projeto>_archive`.
3. Espelha o que já existe em `.schematize/` (overdev, grafos) pro archive.
4. Grava um handoff mínimo em `context/AAAA-MM-DD-<slug>-context.md` da sessão atual (o que foi feito, o que ficou aberto).
5. Reporta o que estava AUSENTE (o gap de observabilidade que acabou de ser fechado).

Regra: **nada de histórico volátil.** Toda decisão/plano/handoff relevante vira arquivo no archive.
