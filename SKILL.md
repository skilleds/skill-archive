---
name: schematize-archive
metadata:
  version: 0.6.0
description: >-
  Rege o `<projeto>/<projeto>_archive/` obrigatório (repo git privado: overdev, ADRs, handoffs, postmortems). Use ao iniciar/retomar projeto ou fechar marco (`/archive-init`).
---

# O ARCHIVE da casa (schematize-archive) — criticidade 0

Armazenar o histórico da evolução do sistema **NÃO é opcional**. O `<projeto>/<projeto>_archive/` é o rastro
**durável e recuperável** que responde, a qualquer momento, *o que foi decidido, planejado, feito, e o
que ficou aberto* — a **observabilidade da evolução**. Sem ele, o sistema é uma caixa-preta: cada
retomada recomeça do zero, promessas somem, "feito" não se prova. **Archive ausente = bug de
criticidade 0**, não um detalhe de fim de tarefa.

**Versão:** skill `schematize-archive` v0.6.0. Changelog em `CHANGELOG.md`.

## Piso inegociável
- **O archive é OBRIGATÓRIO** em todo projeto — materializado como `<projeto>/<projeto>_archive/`, **DENTRO do
  dir do projeto, irmão dos diretórios de microserviços** (não irmão do projeto). TUDO fica dentro do
  projeto. O motor `schematize overdev start` já o cria/espelha; sem archive, **criá-lo é o 1º item**.
- **O archive é um REPOSITÓRIO git PRÓPRIO, PRIVADO e obrigatório** — assim como os repos dos
  microserviços, mas sua função é a **evolução do projeto DOCUMENTADA**. Nasce com `git init`, tem
  **remote privado** (`<projeto>_archive`, private), e é **versionado por marco** (commit a cada
  decisão/plano/handoff/fechamento). NÃO é gitignored no projeto — é um repo, não lixo operacional.
  (O operacional volátil é o `.schematize/`, esse sim gitignored.)
- **O que MORA no archive** (durável, recuperável): `overdev/` (OBJETIVO, PLAN, DECISOES, CHECKLIST,
  NOTAS, premature-stops, AAAA-MM-DD-CONTEXTO.md), `index/` (MAPA + grafos §39), `decisoes/` (ADRs
  `ADR-NNNN-<slug>.md`, ciclo proposed→accepted/rejected), `chats/` (rastro bruto da sessão),
  `context/` (handoffs `AAAA-MM-DD-<slug>-context.md` — o FEITO-vs-ABERTO de cada sessão),
  `postmortems/` (um por incidente; rito em `schematize-incident → references/postmortem.md`),
  `context_agent/` (contexto portável), `plan/`, `scan/`, `qa/`, `audit/`, `pentest/`,
  `orchestration/` e `scaffold/` (relatórios de cada skill), `relatorios/` (andamento a cada 30 min), `custos/` (`custos.{json,md}` do app, citados em cada relatório) e `.ritmo.json` (carimbos). Planta completa em `references/archive.md`. O operacional vivo é `.schematize/`; o **espelho durável é o archive**.
- **Ritmo de registro** (`schematize-engineering` piso 26; piso 25 = sem agents inúteis): em trabalho
  ativo, **RELATÓRIO a cada 30 min** em `relatorios/` com nome data_hora (modelo: `assets/relatorio.template.md`)
  e **HANDOFF a cada 6 h** (e em fim de sessão/marco/compact) em `context/`. Carimbos em
  `.ritmo.json` (`ultimo_relatorio`, `ultimo_handoff`, ISO-8601). Tudo entra no git na hora.
- <!-- herdado:engineering/pisos-22-29:bloco -->**Herda os pisos 22–29 da `schematize-engineering`** (texto completo em `assets/CLAUDE.md` dela): 22 tudo no git — sem remote, push falho ou HEAD≠origin a demanda NÃO se conclui; 23 deploy só do git (VETADO scp/rsync/tar|ssh/docker save|load/git bundle); 24 o ops é o gate da IA — a IA nunca muda a VPS direto nem escreve SQL, só operação nomeada (`ssh vps "ops <op>"`); 25 sem agents inúteis (entregou, morreu); 26 relatório a cada 30 min e handoff a cada 6 h; 27 CI remoto só antes do hml, a pedido ou em tag (`workflow_dispatch` + `hml-*`/`v*`; VETADO `pull_request`, `push` em branch, `workflow_run`, cron sem justificativa); 28 microserviço autônomo (fila durável + 7 testes de resiliência); 29 build/teste na máquina dev/hml quando existe (ponte só no workspace de build, nunca prd) + higiene (`scripts/higiene.sh`).<!-- /herdado -->
- **Nada de histórico só na cabeça/no chat volátil.** Decisão tomada → grava no archive. Plano feito →
  archive. Sessão que fez handoff → archive. É o que a schematize-audit depois COBRA.

## Comandos
- **`/archive-init`** — materializa a estrutura obrigatória do `<projeto>/<projeto>_archive/` e checa o que falta
- **`/archive-check`** — o gate do archive (remote privado obrigatório; `--ativo`: ritmo 30 min/6 h reprova; `--conclusao`: árvore limpa + `HEAD == origin`): segredo/PII/binário/`.gitignore` interno/ADR duplicado/convenção de nome, com o procedimento de **recuperação** ensaiado ao lado (`scripts/check-archive.sh`)
  (nunca deixa o archive ausente). Ver `references/archive.md`.
- **`/archive-todos`** — o principal: **gera afazeres pro overdev a partir do histórico recuperável**.
  Varre o archive + git, enumera o ABERTO/prometido-e-não-provado, e deriva o
  `.schematize/overdev/CHECKLIST.md`. Ver `references/gerar-afazeres.md`.
- **`schematize archive`** (CLI/GUI) — POPULA o archive: extrai o chat da sessão pro `chats/` (cada mensagem = um item), gera o `context_agent/#N.txt` (contexto portável entre PCs/apps) e commita. É o que torna a disciplina EXECUTÁVEL (não manual).
- **`/archive-load`** · **`/archive-claude`** — carrega o corpo normativo / cria ou mescla o `CLAUDE.md` sempre-on.
- **`/archive-cc`** · **`/archive-handoff`** — context compact / handoff no archive (`context/`).
- **`/archive-help`** — mapa da skill.

## Precedência e herança (leia antes de divergir)

<!-- herdado:engineering/precedencia:dominio intro="Esta skill é o recorte **Archive obrigatório (`<projeto>/<projeto>_archive/`)** da `schematize-engineering`: **disciplina de domínio**, não linguagem de backend." cmd="archive" -->Esta skill é o recorte **Archive obrigatório (`<projeto>/<projeto>_archive/`)** da `schematize-engineering`: **disciplina de domínio**, não linguagem de backend.

1. **Onde esta skill divergir da base, a BASE MANDA.** Aqui mora a especialização do domínio ou da
   ferramenta — o como, o padrão, o gate. Divergência de *piso* é defeito desta skill, não variante local.
2. **O que não está repetido aqui é HERDADO, não dispensado.** Esta skill herda os pisos da base e
   os comandos dela cobrem o **domínio**, não o piso geral. Valem integralmente, sem cópia local:
   - **§28 Archive** — `<projeto>/<projeto>_archive/` é **repositório git próprio, PRIVADO e
     obrigatório**, criticidade 0 (`schematize-archive`).
   - **§35 Definition of Done** e a lista de anti-padrões (citada por **título**, nunca por número).
   - **§39 Índice/MAPA** — enumeração exaustiva (uma entrada por unidade chamável, `M == N`) e grafo
     com arestas em ASCII (`A -> B`), nunca a seta unicode.
   - **IAM** (`schematize-engineering` → `references/iam.md`): identidade ≠ email, ≥2 fatores, ReBAC
     multi-tenant, argon2id-only para senha nova, sessão longa e logout irreversível.
   - **Efeito externo** nunca sai de não-produção (`schematize-engineering` →
     `references/efeitos-externos.md`).
   - **Orquestração** (`schematize-engineering` → `references/orquestracao.md` §9): o principal não
     desenvolve (é Claude Opus); executor mais barato que resolve — `haiku`/`sonnet` → Codex Terra → Cursor → `opus` só após falha; visual direto ao Codex; imagem nunca pelo Claude: detecta Codex/Gemini e pergunta ao usuário qual usar (Codex é a sugestão, não automática), nunca API paga.
3. **QA, ops, IAM e índice não têm comando próprio aqui:** vêm da base `/eng-*`. Para trabalho
   contínuo use `/eng-overdev`; para planejar `/eng-plan`; para varrer a base `/eng-scan`; para
   revisão geral `/eng-review` (e `/eng-ops`, `/eng-iam`, `/eng-index`). Os comandos
   `/archive-*` cobrem o domínio desta skill; o piso geral é o da base.<!-- /herdado -->

## Orquestração

<!-- herdado:engineering/orquestracao:curto -->**Orquestrador não desenvolve; subagent barato executa.** O agent principal só planeja, despacha e revisa; ação onerosa vira micro-tasks para o executor mais barato que resolve: `haiku` (mecânico) / `sonnet` (código; falhou → mesmo subagent corrige, até 2 rodadas) → Codex `gpt-5.6-terra` → Cursor → subagent `opus` (motivo) → `park`; **visual vai direto ao Codex**; **imagem nunca pelo Claude: detectar Codex/Gemini e perguntar ao usuário qual usar (Codex é a sugestão), nunca API de imagem paga**; papéis em `agentes.toml`. No overdev, cada item do checklist vai a um subagent e o principal revisa antes do `- [x]`. **Sem frota ociosa:** idle com pendência volta ao trabalho; dependente de outro agent → mata e enfileira com gatilho; terminou → mata (§9.6). Detalhe: `schematize-engineering` → `references/orquestracao.md` §9.<!-- /herdado -->

## Como se encaixa
- **schematize-engineering** (archive §28, overdev §0/§2, índice §39) — a BASE que exige o archive.
- **schematize-audit** — o oráculo dos órfãos RED: `/archive-todos` reusa a disciplina de "feito sem
  prova volta a aberto" e pode disparar `/audit-run` pra o veredito.
- **schematize-incident** — os postmortems moram em `<projeto>_archive/postmortems/`; o rito é de lá.
- **schematize-overdev-context** — a Fase 0: `/archive-todos` produz o insumo que a Fase 0 consome.
