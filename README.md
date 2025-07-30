# 🧀 Share Cheese

Um jogo cooperativo multiplayer desenvolvido para Transformice onde os jogadores coletam queijos públicos e privados, gerenciam recursos compartilhados e enfrentam eventos aleatórios que afetam a economia do jogo.

## 📖 Como Jogar

### 🎯 Objetivo
O objetivo principal é coletar queijos e maximizar os ganhos coletivos através da cooperação. O jogo funciona com um sistema de **pote compartilhado** que beneficia todos os jogadores quando atingem metas específicas.

### 🕹️ Controles
- **Tecla Q**: Coleta queijos próximos à sua posição atual

### 🧀 Tipos de Queijo

#### 🟢 Queijo Público (Verde)
- **Cor**: Verde brilhante
- **Efeito**: Vai para sua bolsa pessoal E contribui para o **pote compartilhado**
- **Partícula**: Efeito visual verde
- **Probabilidade**: 60% dos queijos são públicos

#### 🟡 Queijo Privado (Amarelo)  
- **Cor**: Amarelo
- **Efeito**: Vai apenas para sua bolsa pessoal
- **Partícula**: Efeito visual amarelo
- **Probabilidade**: 40% dos queijos são privados

### 💰 Sistema de Pote Compartilhado

O **pote** é um recurso coletivo que todos os jogadores contribuem e se beneficiam:

- **Contribuição**: Cada queijo público coletado adiciona pontos ao pote (multiplicado pela escassez atual)
- **Meta**: Quando o pote atinge **20 pontos**, todos ganham!
- **Recompensa**: O pote é multiplicado por 1.5x e dividido igualmente entre todos os jogadores
- **Falha**: Se a meta não for atingida, a escassez diminui e o pote é zerado

## 🎲 Eventos Aleatórios

A cada rodada, um evento aleatório afeta a jogabilidade:

### 🌟 Aurora
- **Efeito**: Diminui a escassez em 0.1 (mínimo 0.5)
- **Resultado**: Queijos públicos valem mais para o pote

### 🏜️ Seca  
- **Efeito**: Aumenta a escassez em 0.2
- **Resultado**: Queijos públicos valem menos para o pote

### 👮 Fiscalização
- **Efeito**: Remove 50% dos queijos privados de todos os jogadores
- **Resultado**: Perda de recursos pessoais

### 💧 Vazamento Privado
- **Efeito**: 25% dos queijos privados de cada jogador vão para o pote
- **Resultado**: Conversão de recursos privados em públicos

### 🎁 Doação
- **Efeito**: Adiciona 2 pontos ao pote para cada jogador
- **Resultado**: Impulso gratuito no pote compartilhado

### 🌪️ Queijofuracão
- **Efeito**: Evento neutro (sem efeitos especiais)
- **Resultado**: Rodada normal

## 🔄 Progressão do Jogo

### 📈 Escalabilidade por Rodada
- **Queijos por rodada**: Começa com 4 e aumenta 2 a cada rodada (máximo 12)
- **Fórmula**: `min(4 + (rodada - 1) * 2, 12)`

### ⏱️ Tempo por Rodada
- **Duração**: 30 segundos por rodada
- **Spawn**: Novos queijos aparecem a cada 0.5 segundos

### 🗺️ Mapas
O jogo rotaciona entre 5 mapas diferentes:
- @5451839
- @5445849  
- @6599901
- @6682692
- @6399897

## 💡 Estratégias

### 🤝 Cooperação
- **Foque nos queijos públicos** quando o pote estiver próximo de 20
- **Comunique-se** com outros jogadores sobre a estratégia
- **Monitore o pote** constantemente para saber quando cooperar

### 📊 Gerenciamento de Recursos
- **Queijos privados** são sua segurança pessoal
- **Queijos públicos** são investimento no grupo
- **Balance** entre ganho pessoal e coletivo

### 🎯 Timing
- **Primeiras rodadas**: Estabeleça uma base de queijos privados
- **Rodadas intermediárias**: Foque na cooperação para metas do pote
- **Eventos específicos**: Adapte a estratégia baseada no evento ativo

## 🖥️ Interface do Jogo

### 📊 Informações Exibidas
- **Evento atual** da rodada
- **Número da rodada**
- **Valor atual do pote**
- **Valor individual** (pote ÷ número de jogadores)
- **Queijos públicos** de cada jogador
- **Queijos privados** de cada jogador

### 🎨 Elementos Visuais
- **Queijos verdes**: Públicos com partículas verdes
- **Queijos amarelos**: Privados com partículas amarelas  
- **Interface**: Painel superior com todas as informações
- **Nome do mapa**: Mostra o evento atual

## 🚀 Como Rodar

### 📋 Pré-requisitos
- **Transformice**: Jogo base instalado
- **Guilda com privilégios**: Você deve estar em uma guilda com **privilégios de moderação**
- **Acesso ao cafofo**: Deve estar no **cafofo da guilda** para executar o script

### ⚙️ Instalação e Execução

1. **Entre no cafofo da sua guilda** no Transformice
2. **Convide os jogadores** que vão participar usando o comando:
   ```
   /inv [nomejogador#0000]
   ```
   - Os jogadores **não precisam estar na guilda**
   - Apenas você (host) precisa ter os privilégios

3. **Abra o editor Lua** digitando no chat:
   ```
   /lua
   ```
   - Isso abrirá o editor de código Lua

4. **Cole o script**:
   - Copie todo o conteúdo do arquivo `script.lua`
   - Cole no editor que abriu
   - Execute o código

### 🎮 Inicialização
- O jogo inicia automaticamente quando o script é executado
- Todos os jogadores presentes no cafofo são incluídos automaticamente
- A primeira rodada começa imediatamente
- Novos jogadores que entrarem são adicionados automaticamente

### ⚠️ Observações Importantes
- **Apenas o host** precisa executar o script
- **Apenas o host** precisa ter privilégios de moderação na guilda
- **Todos os outros jogadores** podem participar normalmente sem privilégios especiais
- O jogo roda enquanto o host mantiver o script ativo

## 🔧 Configurações Técnicas

### ⚡ Performance
- **Auto-shaman**: Desabilitado
- **Auto-nova partida**: Desabilitado  
- **Morte por AFK**: Desabilitada

### 🔢 Parâmetros Ajustáveis
- **Raio de coleta**: 30 pixels
- **Tempo por rodada**: 30 segundos
- **Meta do pote**: 20 pontos
- **Multiplicador de recompensa**: 1.5x
- **Intervalo de spawn**: 500ms

## 🏆 Dicas Avançadas

1. **Observe o evento**: Cada evento muda a estratégia ideal
2. **Comunicação**: Use o chat para coordenar com outros jogadores  
3. **Timing**: Colete queijos públicos quando o pote estiver próximo da meta
4. **Gestão de risco**: Mantenha alguns queijos privados como reserva
5. **Adaptação**: Mude a estratégia baseada no número de jogadores na sala

## 📝 Créditos

Desenvolvido como um experimento cooperativa em jogos multiplayer, explorando conceitos de teoria dos jogos e dilemas de cooperação para a cadeira de Jogos & Dilemas Socias.

---

**Divirta-se jogando Share Cheese! 🧀✨**
