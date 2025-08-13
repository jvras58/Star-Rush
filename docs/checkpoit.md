# 🎯 Checkpoints de Melhorias - Share Cheese

## 🧀 Sistema de Estrelas

### [x] Geração Estratégica de Estrelas
- **Objetivo**: Implementar geração de pares de estrelas (público + privado) próximos
- **Implementação**: 
  - [x] Modificar função `spawnStar()` para gerar sempre duplas
  - [x] Definir distância máxima entre estrelas do mesmo par (50-80 pixels)
  - [x] Manter proporção atual (60% público / 40% privado)
- **Prioridade**: Alta
- **EllianRodrigues**

### [] Sistema de Coleta Estratégica
- **Objetivo**: Ao coletar um estrela público, remover automaticamente o estrela privado mais próximo (e vice-versa)
- **Implementação**:
  -[x] Modificar função `collectStar()` para detectar estrela par mais próximo
  -[x] Adicionar função `findNearestOppositeType()` 
  -[x] Implementar remoção automática do Estrela par
- **Prioridade**: Alta
- **Benefício**: Aumenta tensão estratégica e dilema cooperativo
- **EllianRodrigues**

## 📊 Sistema de Pontuação e Ranking

### [x] Implementar Ranking em Tempo Real
- **Objetivo**: Mostrar classificação dos jogadores durante o jogo
- **Implementação**:
  - [x]Criar função `calculatePlayerScore()` baseada em:
    - [x]Estrelas públicos coletados
    - [x]Estrelas privados em posse
    - [x] Contribuição para o pote
  - [x] Adicionar painel de ranking na interface
  - [x] Atualizar ranking a cada coleta
- **Prioridade**: Média
- **EllianRodrigues**

### [x] Sistema de Pontuação Final
- **Objetivo**: Calcular pontuação final considerando todos os fatores
- **Fórmula Proposta**: 
  ```
  Pontuação = (Star Públicos × 2) + (Star Privados × 1) + (Bônus Pote × Jogadores)
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
    - Total de estrelas coletados
    - Número de vezes que o pote foi atingido
    - Jogador mais cooperativo
    - Jogador mais individualista
- **Prioridade**: Média

## 📚 Sistema de Tutorial e Explicação

### [] Tutorial Interativo
- **Objetivo**: Explicar mecânicas para novos jogadores
- **Implementação**:
  - [x] Função `showTutorial()` no início do jogo
  - Mensagens explicativas por rodada:
    - Rodada 1-2: Explicar tipos de queijo
    - Rodada 3-4: Explicar sistema de pote
    - Rodada 5+: Explicar eventos
- **Prioridade**: Média
- **EllianRodrigues**

### [] Sistema de Dicas Contextuais
- **Objetivo**: Mostrar dicas baseadas no estado atual do jogo
- **Exemplos**:
  - "Pote próximo de 20! Foque nos estrelas públicos!"
  - "Evento Seca ativo - estrelas públicos valem menos"
  - "Poucos estrelas privados - considere ser mais individualista"
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
- **Objetivo**: Encontrar mapas com mais espaço para melhor distribuição de estrelas
- **Implementação**:
  - Pesquisar mapas da comunidade com dimensões maiores (800x600 ou superior)
  - Testar mapas com plataformas mais espaçadas
  - Considerar mapas com múltiplos níveis verticais
  - Atualizar array `mapas[]` com IDs de mapas maiores
- **Prioridade**: Alta
- **Benefício**: Reduz aglomeração e melhora distribuição espacial

### [] Implementar Queijo Nativo do Transformice
- **Objetivo**: Substituir sistema atual por estrelas nativos do jogo
- **Prioridade**: Alta

### [] Sistema de Física Inteligente para Spawn
- **Objetivo**: Resolver problema de estrelas em locais inacessíveis
- **Implementação**:
  - Criar função `isValidSpawnLocation(x, y)` que verifica:
    - Distância mínima de paredes (20+ pixels)
    - Proximidade com plataformas acessíveis
    - Não spawnar em áreas vazias sem suporte
  - Implementar raycast para verificar acessibilidade
  - Usar `tfm.get.room.objectList` para detectar obstáculos
  - Fallback: tentar múltiplas posições antes de spawnar
- **Prioridade**: Alta
- **Benefício**: Elimina frustração de estrelas impossíveis de coletar

## 📊 Sistema de Coleta de Dados e Analytics

### [] Sistema de Logging Comportamental
- **Objetivo**: Coletar dados detalhados das escolhas e comportamentos dos jogadores para análise acadêmica
- **Implementação**:
  - Criar estrutura `gameData` para armazenar todos os eventos
  - Função `logPlayerAction(player, action, data)` para registrar:
    - **Coletas**: Tipo de estrelas, posição, tempo de decisão
    - **Movimento**: Trajetórias e proximidade com estrelas
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
    "action": "collect_star",
    "star_type": "public",
    "position": {"x": 150, "y": 200},
    "pot_state": 15,
    "event": "Aurora",
    "timestamp": 1643723400
  }
  ```

### [x] Sistema de Análise em Tempo Real
- **Indicadores durante o jogo**:
  - **[x] Índice de cooperação da sala**: % de estrelas públicos coletados
  - **Jogador mais cooperativo/individualista** da rodada
  - **Tendência do grupo**: Se cooperação aumenta ou diminui
  - **Efetividade dos eventos**: Como cada evento influencia comportamento
- **Implementação**: Função `calculateRoomCooperation()` atualizada a cada coleta

