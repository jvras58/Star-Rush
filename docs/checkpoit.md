# 🎯 Checkpoints de Melhorias - Share Cheese

## 🧀 Sistema de Queijos

### [] Geração Estratégica de Queijos
- **Objetivo**: Implementar geração de pares de queijos (público + privado) próximos
- **Implementação**: 
  - Modificar função `spawnCheese()` para gerar sempre duplas
  - Definir distância máxima entre queijos do mesmo par (50-80 pixels)
  - Manter proporção atual (60% público / 40% privado)
- **Prioridade**: Alta

### [] Sistema de Coleta Estratégica
- **Objetivo**: Ao coletar um queijo público, remover automaticamente o queijo privado mais próximo (e vice-versa)
- **Implementação**:
  - Modificar função `collectCheese()` para detectar queijo par mais próximo
  - Adicionar função `findNearestOppositeType()` 
  - Implementar remoção automática do queijo par
- **Prioridade**: Alta
- **Benefício**: Aumenta tensão estratégica e dilema cooperativo

## 📊 Sistema de Pontuação e Ranking

### [] Implementar Ranking em Tempo Real
- **Objetivo**: Mostrar classificação dos jogadores durante o jogo
- **Implementação**:
  - Criar função `calculatePlayerScore()` baseada em:
    - Queijos públicos coletados
    - Queijos privados em posse
    - Contribuição para o pote
  - Adicionar painel de ranking na interface
  - Atualizar ranking a cada coleta
- **Prioridade**: Média

### [] Sistema de Pontuação Final
- **Objetivo**: Calcular pontuação final considerando todos os fatores
- **Fórmula Proposta**: 
  ```
  Pontuação = (Queijos Públicos × 2) + (Queijos Privados × 1) + (Bônus Pote × Jogadores)
  ```
- **Prioridade**: Média

## 🏁 Sistema de Finalização

### [] Limite de Rodadas
- **Objetivo**: Definir número máximo de rodadas (sugestão: 10-15 rodadas)
- **Implementação**:
  - Adicionar variável `maxRounds` nas configurações
  - Modificar função `newRound()` para verificar limite
  - Criar função `endGame()` quando limite for atingido
- **Prioridade**: Alta

### [] Ceremônia de Encerramento
- **Objetivo**: Anunciar vencedor e estatísticas finais
- **Implementação**:
  - Função `announceWinner()` com ranking final
  - Mostrar estatísticas da partida:
    - Total de queijos coletados
    - Número de vezes que o pote foi atingido
    - Jogador mais cooperativo
    - Jogador mais individualista
- **Prioridade**: Média

## 📚 Sistema de Tutorial e Explicação

### [] Tutorial Interativo
- **Objetivo**: Explicar mecânicas para novos jogadores
- **Implementação**:
  - Função `showTutorial()` no início do jogo
  - Mensagens explicativas por rodada:
    - Rodada 1-2: Explicar tipos de queijo
    - Rodada 3-4: Explicar sistema de pote
    - Rodada 5+: Explicar eventos
- **Prioridade**: Média

### [] Sistema de Dicas Contextuais
- **Objetivo**: Mostrar dicas baseadas no estado atual do jogo
- **Exemplos**:
  - "Pote próximo de 20! Foque nos queijos públicos!"
  - "Evento Seca ativo - queijos públicos valem menos"
  - "Poucos queijos privados - considere ser mais individualista"
- **Prioridade**: Baixa

## 🔧 Melhorias Técnicas Adicionais

### [] Sistema de Estatísticas Avançadas
- **Tracking de métricas por jogador**:
  - Tempo médio de coleta
  - Eficiência cooperativa (% público vs privado)
  - Contribuição líquida para o pote
- **Prioridade**: Baixa

### [] Balanceamento Dinâmico
- **Ajustar dificuldade baseada no número de jogadores**:
  - Meta do pote escala com número de jogadores
  - Eventos mais/menos frequentes baseado na cooperação
- **Prioridade**: Média

## 🗺️ Sistema de Mapas e Ambientação

### [] Busca por Mapas Maiores
- **Objetivo**: Encontrar mapas com mais espaço para melhor distribuição de queijos
- **Implementação**:
  - Pesquisar mapas da comunidade com dimensões maiores (800x600 ou superior)
  - Testar mapas com plataformas mais espaçadas
  - Considerar mapas com múltiplos níveis verticais
  - Atualizar array `mapas[]` com IDs de mapas maiores
- **Prioridade**: Alta
- **Benefício**: Reduz aglomeração e melhora distribuição espacial

### [] Implementar Queijo Nativo do Transformice
- **Objetivo**: Substituir sistema atual por queijos nativos do jogo
- **Prioridade**: Alta

### [] Sistema de Física Inteligente para Spawn
- **Objetivo**: Resolver problema de queijos em locais inacessíveis
- **Implementação**:
  - Criar função `isValidSpawnLocation(x, y)` que verifica:
    - Distância mínima de paredes (20+ pixels)
    - Proximidade com plataformas acessíveis
    - Não spawnar em áreas vazias sem suporte
  - Implementar raycast para verificar acessibilidade
  - Usar `tfm.get.room.objectList` para detectar obstáculos
  - Fallback: tentar múltiplas posições antes de spawnar
- **Prioridade**: Alta
- **Benefício**: Elimina frustração de queijos impossíveis de coletar

## 📊 Sistema de Coleta de Dados e Analytics

### [] Sistema de Logging Comportamental
- **Objetivo**: Coletar dados detalhados das escolhas e comportamentos dos jogadores para análise acadêmica
- **Implementação**:
  - Criar estrutura `gameData` para armazenar todos os eventos
  - Função `logPlayerAction(player, action, data)` para registrar:
    - **Coletas**: Tipo de queijo, posição, tempo de decisão
    - **Movimento**: Trajetórias e proximidade com queijos
    - **Contexto**: Estado do pote, evento ativo, rodada atual
  - Timestamps precisos para análise temporal
  - Export de dados em formato JSON/CSV
- **Prioridade**: Alta
- **Benefício**: Permite análise científica de comportamento cooperativo

### [] Métricas de Comportamento Individual
- **Dados a coletar por jogador**:
  - **Preferência cooperativa**: Razão público/privado ao longo do tempo
  - **Sensibilidade ao contexto**: Como eventos afetam escolhas
  - **Tempo de reação**: Velocidade de coleta após spawn
  - **Padrões espaciais**: Áreas preferidas do mapa
  - **Influência social**: Correlação com ações de outros jogadores
- **Formato de saída**: 
  ```json
  {
    "player": "nome#0000",
    "round": 3,
    "action": "collect_cheese",
    "cheese_type": "public",
    "position": {"x": 150, "y": 200},
    "pot_state": 15,
    "event": "Aurora",
    "timestamp": 1643723400
  }
  ```

### [] Sistema de Análise em Tempo Real
- **Indicadores durante o jogo**:
  - **Índice de cooperação da sala**: % de queijos públicos coletados
  - **Jogador mais cooperativo/individualista** da rodada
  - **Tendência do grupo**: Se cooperação aumenta ou diminui
  - **Efetividade dos eventos**: Como cada evento influencia comportamento
- **Implementação**: Função `calculateRoomCooperation()` atualizada a cada coleta

