# schematize-archive — sempre-on

O `<projeto>/<projeto>_archive/` é um REPOSITÓRIO git PRÓPRIO, PRIVADO e obrigatório (irmão dos microserviços, dentro do projeto) — CRITICIDADE 0: guardar o histórico (checklists, planos, decisões/ADRs,
handoffs de chat, índice) NÃO é opcional. Archive ausente = bug de observabilidade — criá-lo é o 1º
item. Toda decisão/plano/handoff relevante vira arquivo durável no archive (o operacional vivo é
`.schematize/`; o espelho durável é o archive). Pra recuperar o que faltou e montar o próximo trabalho:
`/archive-todos` (gera afazeres pro overdev do histórico recuperável).

Remote privado obrigatório; relatório a cada 30 min e handoff a cada 6 h entram no git na hora (piso 22); `custos/` guarda o custo do período/acumulado citado em cada relatório. Herda os pisos 22–29 da `schematize-engineering` (git como trava de conclusão, deploy só do git, ops é o gate da IA, sem agents inúteis, relatório 30 min/handoff 6 h, CI remoto só antes do hml, microserviço autônomo, build em dev/hml + higiene).

## Orquestração

<!-- herdado:engineering/orquestracao:curto -->**Orquestrador não desenvolve; subagent barato executa.** O agent principal só planeja, despacha e revisa; ação onerosa vira micro-tasks para o executor mais barato que resolve: `haiku` (mecânico) / `sonnet` (código; falhou → mesmo subagent corrige, até 2 rodadas) → Codex `gpt-5.6-terra` → Cursor → subagent `opus` (motivo) → `park`; **visual vai direto ao Codex**; **imagem nunca pelo Claude: detectar Codex/Gemini e perguntar ao usuário qual usar (Codex é a sugestão), nunca API de imagem paga**; papéis em `agentes.toml`. No overdev, cada item do checklist vai a um subagent e o principal revisa antes do `- [x]`. **Sem frota ociosa:** idle com pendência volta ao trabalho; dependente de outro agent → mata e enfileira com gatilho; terminou → mata (§9.6). Detalhe: `schematize-engineering` → `references/orquestracao.md` §9.<!-- /herdado -->
