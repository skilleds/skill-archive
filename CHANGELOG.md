# Changelog — schematize-archive

Todas as mudanças relevantes deste pacote, no formato [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/),
com versionamento [SemVer](https://semver.org/lang/pt-BR/).

## [0.5.0] — 2026-10-31
Ritmo de registro do archive (engineering piso 26; piso 25 = sem agents inúteis).

### Adicionado
- Planta do archive prevê `relatorios/` (relatório de andamento a cada 30 min, `AAAA-MM-DD_HHMM.md`) e `.ritmo.json` (`ultimo_relatorio`, `ultimo_handoff`, ISO-8601); `SKILL.md` e `references/archive.md` apontam para o piso 26 em vez de duplicá-lo.
- `assets/relatorio.template.md`: feito com SHAs, em andamento, bloqueios/on-hold, próximos passos, agents vivos, desvios.
- `/archive-init` cria `relatorios/` e o `.ritmo.json` inicial; `/archive-handoff` renova `ultimo_handoff`.
- `check-archive.sh` (`/archive-check`) avisa `.ritmo.json`/`relatorios/` ausentes, nome fora de convenção e carimbos vencidos (relatório >30 min, handoff >6 h), com testes. Só avisa: carimbo velho é falta de registro, não vazamento.

## [0.4.0] — 2026-10-14
Integração com as 8 skills novas (skill-dev, iam, api, payments, postgres, incident, analytics, git) e saneamento pelo gate novo.

### Alterado
- Blocos herdados `engineering/precedencia:dominio` e `engineering/orquestracao:curto` (SKILL.md e assets/CLAUDE.md), exigidos pelo gate da `schematize-skill-dev`.
- Description reduzida a ≤190 caracteres para caber no orçamento do catálogo (45 skills).
- Comandos obrigatórios `/archive-load`, `/archive-claude`, `/archive-handoff`, `/archive-cc` (e `/archive-help` atualizado).
- `postmortems/` entra na planta do archive (`references/archive.md`) e na convenção de nome do `check-archive.sh` (com teste); o rito do postmortem é de `schematize-incident`.

## [0.3.1] — 2026-10-14
Reduz a description para o orçamento de listagem.

### Alterado
- Description reduzida (≤235 chars) para caber no orçamento de listagem de skills (soma ≤8300); mesmo território, fronteiras com as irmãs preservadas.

## [0.3.0] — 2026-10-14
Saneamento: a planta do archive tinha duas verdades (handoff em `chats/` vs `context/`) e um comando ainda usava o layout irmão revogado.

### Corrigido
- `/archive-check`: caminhos `../<projeto>_archive` (layout irmão, revogado na v0.1.1) → `<projeto>_archive` dentro do projeto; o pre-commit deriva a raiz de `git rev-parse --show-toplevel`.
- Planta única: handoff sempre em `context/AAAA-MM-DD-<slug>-context.md` (`SKILL.md`, `archive.md`, `archive-init.md`); `chats/` é só o rastro bruto.
- Planta completa: acrescentadas as pastas que outras skills gravam — `orchestration/`, `scaffold/`, `context_agent/`, `overdev/AAAA-MM-DD-CONTEXTO.md` — além de `plan/ scan/ qa/ audit/ pentest/ decisoes/`; `SKILL.md`, README e `/archive-init` listam a planta inteira.
- `/archive-todos` chama `collect-history.sh` pelo caminho instalado (`.claude/skills/schematize-archive/scripts/`), não relativo.
- Removidas contagens fixas que envelhecem ("24 skills", "70 ocorrências").
- `description` reescrita (<=350 caracteres). Padrão de ADR mantido: `ADR-NNNN-<slug>.md`.
- `check-archive.sh`: a validação de convenção de nome cobre a planta inteira — `orchestration/` e `scaffold/` (AAAA-MM-DD-<slug>), `context_agent/` (`#N.txt`) e `overdev/AAAA-MM-DD-CONTEXTO.md`; antes só as pastas antigas. Casos vermelhos plantados em `check-archive.test.sh`.
- **Description** reduzida (~270 chars) para caber no orçamento de listagem (soma das 31 skills ≤ 8500; o Claude Code corta a listagem acima disso).
- `order` do `skill.toml` 13 → 23 (colidia com schematize-ai).

## [0.2.0] — 2026-08-21
Os **quatro buracos** que a vistoria de 2026-08-21 achou numa skill que declara criticidade 0 e promete rastro *"recuperável"* (4 ocorrências) em 119 linhas — e que reprovou no seu próprio primeiro teste real (B1).

### Adicionado
- **`references/archive.md` → "O que NUNCA entra no archive"** — o buraco mais grave, num repo que guarda **transcript de sessão inteiro**: segredo em qualquer forma, dado real de cliente, dump de produção, binário grande. Com **como isso entra na prática** (o `curl -v` colado com o header, o stack trace com a connection string, o `cat .env` para depurar — nenhum parece segredo na hora) e o que fazer **se entrou**: rotacionar primeiro, porque segredo commitado uma vez está **vazado para sempre** e `git rm` só esconde da última versão.
- **"Convenção de nome"** — `AAAA-MM-DD-<slug>` em tudo, `ADR-NNNN-<slug>` nas decisões, com o porquê: data na frente faz **ordem alfabética virar cronológica** sem metadado, e número de ADR **nunca se reusa** porque ADR rejeitado continua sendo citado.
- **"Retenção e rotação"** — `chats/` é o único diretório que cresce sem limite. **Nada é apagado** (criticidade 0 significa recuperável; apagar transcript quebra a única promessa da skill): rotação por ano com `git mv`, compressão só do que já saiu do ano corrente, `context/` não rotaciona, e **nada de `.gitignore` seletivo** dentro do archive — o que não pode ser guardado não pode ter entrado.
- **"Recuperação — o que 'recuperável' significa em comandos"** — os 5 passos (clonar, achar varrendo **os dois** lugares do rastro, reconstruir o estado de trabalho, recolocar o operacional em `.schematize/`, verificar) e o **ensaio**: clone num diretório limpo e responda três perguntas usando só ele. Não conseguiu, o archive reprovou — e isso é achado.
- **`scripts/check-archive.sh`** + **`/archive-check`** — o gate, instalável como `pre-commit`. Reprova header `Authorization`, bloco PEM, token de provedor, string de conexão com senha, variável de segredo com valor, CPF, cartão, binário grande, `.gitignore` interno, **número de ADR reusado** e archive que não é repo git. O relatório aponta **arquivo:linha e nunca o valor** — gate que ecoa o segredo faz a segunda cópia dele. E o verde diz de si mesmo que **não é permissão para colar `.env`**.
- **`scripts/check-archive.test.sh`** — **17 casos** com segredos sintéticos (plantar segredo real num fixture seria cometer o defeito que o gate persegue), incluindo o teste de que a saída **não ecoa** o valor encontrado.

### Corrigido
- O padrão do PEM começa com `-----`: sem `grep -e`, o grep o lia como opção e o gate ficava **silenciosamente cego justo para chave privada**. Pego pelo próprio vermelho do teste.

## [0.1.3] — 2026-08-18
Estrutura ganha `context_agent/` (contexto portável #N.txt). Comando `schematize archive` popula chats/ (transcript da sessão, 1 item/mensagem) + gera context_agent/#N.txt + commita. Disciplina executável, não manual.

## [0.1.2] — 2026-08-18
Archive é `<projeto>/<projeto>_archive/` — nome do projeto (prefixo comum dos microserviços) no dir, pra não misturar archives de projetos diferentes.

## [0.1.1] — 2026-08-18
Archive fica DENTRO do projeto (`<projeto>/<projeto>_archive/`, irmão dos microserviços) — não mais irmão do projeto.

## [0.1.0] — 2026-08-18
Skill nova: o archive como CRITICIDADE 0 (obrigatório, não opcional) + gerador de afazeres pro overdev.
### Adicionado
- Piso: `<projeto>/<projeto>_archive/` obrigatório (checklists, planos, decisões/ADRs, chats/handoffs, índice, audit/pentest). Archive ausente = bug de observabilidade.
- `/archive-init` — materializa a estrutura do archive.
- `/archive-todos` — gera `.schematize/overdev/CHECKLIST.md` a partir do histórico recuperável do archive + git (itens abertos/prometidos-e-não-provados), com disciplina red-first da schematize-audit.
- `/archive-help`.
