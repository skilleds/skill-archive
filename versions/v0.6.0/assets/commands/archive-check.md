---
description: schematize-archive — varre o archive antes do commit (segredo, PII, binário, convenção de nome, ADR duplicado, repo próprio) e ensaia a recuperação
argument-hint: "[caminho do <projeto>_archive]"
---

# /archive-check — a rede embaixo do trapézio

O archive guarda **transcript de sessão inteiro**: é o que o torna útil e o que o torna perigoso —
o que passou pela tela passa pelo `chats/`.

```bash
bash .claude/skills/schematize-archive/scripts/check-archive.sh <projeto>_archive
```

`0` passa · `1` reprova · `2` não é um archive.

```bash
bash .claude/skills/schematize-archive/scripts/check-archive.sh --ativo <projeto>_archive       # sessão em andamento: ritmo vencido reprova
bash .claude/skills/schematize-archive/scripts/check-archive.sh --conclusao <projeto>_archive   # fechar demanda: árvore limpa + HEAD == origin + custos/
```

**Reprova:** header `Authorization` colado · bloco PEM de chave privada · token de provedor ·
string de conexão com senha · variável de segredo com valor · CPF ou número de cartão · binário
grande (o archive é texto que conta a evolução, não bucket) · `.gitignore` com regras dentro do
archive (ignorar arquivo no repo cuja função é guardar rastro anula o repo) · **número de ADR
reusado** · archive que não é repo git · **archive sem remote `origin`** · **remote PÚBLICO** (com `gh`; o archive
guarda transcript de sessão e é privado por regra) · `custos/custos.json` inválido. Com `--conclusao`: árvore suja,
`HEAD != origin`, sem upstream e `custos/` ausente (piso 22). **Avisa:** nome fora de `AAAA-MM-DD-<slug>`,
visibilidade não confirmável (sem `gh`/rede), `custos/` ausente fora da conclusão.

**Ritmo (piso 26):** avisa `.ritmo.json` ausente ou malformado, `relatorios/` ausente, relatório com
nome fora do padrão data_hora, `ultimo_relatorio` com mais de **30 min** e `ultimo_handoff` com mais de **6 h**.
Sem flag é aviso (carimbo velho é trabalho sem registro, não vazamento; o pre-commit não pode travar por
isso). **Com `--ativo` reprova** (mesma semântica do `check-ritmo.sh` da engineering). Ao ver o aviso em
trabalho ativo, grave o relatório/handoff na hora, renove o carimbo e dê commit + push.

O relatório aponta **arquivo:linha e nunca o valor** — um gate que ecoa o segredo faz a segunda
cópia dele.

## Se reprovou

Nesta ordem: **(1) rotacione** a credencial — segredo commitado uma vez está vazado para sempre, e
`git rm` só o esconde da última versão · (2) registre em `decisoes/` (é ADR, não fofoca) · (3) só
então decida sobre reescrever histórico. Para dado pessoal, o passo (1) é **notificar quem cuida de
privacidade**: o prazo legal corre a partir do conhecimento.

**Um verde aqui não é permissão para colar `.env`.** Segredo tem infinitas formas e o script conhece
um punhado.

## Instale como pre-commit no archive

```bash
# rodar na raiz do <projeto>; o archive mora DENTRO dele (<projeto>/<projeto>_archive)
printf '#!/bin/sh\nA="$(git rev-parse --show-toplevel)"\nexec bash "${GIT_GATE_ARCHIVE:-$A/../.claude/skills/schematize-archive/scripts/check-archive.sh}" "$A"\n' \
  > <projeto>_archive/.git/hooks/pre-commit
chmod +x <projeto>_archive/.git/hooks/pre-commit
```

(`GIT_GATE_ARCHIVE` aponta o script quando a skill não está em `<projeto>/.claude/skills/`; o hook roda sem flag, então árvore suja não o trava.)

## E ensaie a recuperação

Uma vez por marco, com o archive **saudável** (não no dia do incidente): clone num diretório limpo e
responda três perguntas usando só ele — **o que estava aberto? por que a decisão X foi tomada? onde
mora o serviço Y?** Não conseguiu: o archive reprovou, e isso é achado
(`references/archive.md` → *Recuperação*).
