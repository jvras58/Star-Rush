# 🧀 Share Cheese

Um jogo cooperativo multiplayer avançado desenvolvido para Transformice onde os jogadores coletam queijos públicos e privados, gerenciam recursos compartilhados, enfrentam eventos aleatórios e competem em um sistema de ranking baseado em cooperação e performance individual.

## 📖 Como Jogar

### 🎯 Objetivo
O objetivo principal é coletar queijos e maximizar os ganhos coletivos através da cooperação estratégica. O jogo funciona com um sistema de **pote compartilhado** que beneficia todos os jogadores quando atingem metas específicas, combinado com um **sistema de ranking** que recompensa tanto performance individual quanto cooperação.

### 🕹️ Controles
- **Tecla Q**: Coleta queijos próximos à sua posição atual
- **Tecla H**: Abre/fecha o sistema de ajuda com todas as informações do jogo
- **Tecla T**: Inicia o tutorial interativo (disponível para novos jogadores)

### 🧀 Tipos de Queijo

#### 🟢 Queijo Público (Verde)
- **Cor**: Verde brilhante
- **Efeito**: Vai para sua bolsa pessoal E contribui para o **pote compartilhado**
- **Partícula**: Efeito visual verde intenso
- **Probabilidade**: 60% dos queijos são públicos
- **Spawn**: Aparecem em pares estratégicos próximos um do outro

#### 🟡 Queijo Privado (Amarelo)  
- **Cor**: Amarelo dourado
- **Efeito**: Vai apenas para sua bolsa pessoal
- **Partícula**: Efeito visual amarelo brilhante
- **Probabilidade**: 40% dos queijos são privados
- **Spawn**: Posicionamento individual aleatório

### 💰 Sistema de Pote Compartilhado

O **pote** é um recurso coletivo que todos os jogadores contribuem e se beneficiam:

- **Contribuição**: Cada queijo público coletado adiciona pontos ao pote (multiplicado pela escassez atual)
- **Meta**: Quando o pote atinge **20 pontos**, todos ganham!
- **Recompensa**: O pote é multiplicado por 1.5x e dividido igualmente entre todos os jogadores
- **Falha**: Se a meta não for atingida, a escassez diminui e o pote é zerado
- **Coleta Automática**: Queijos são automaticamente removidos quando coletados

## 🏆 Sistema de Ranking

### 📊 Cálculo de Pontuação
Cada jogador tem um **score individual** calculado com base em:

- **Queijos Públicos**: +2 pontos cada (valoriza cooperação)
- **Queijos Privados**: +1 ponto cada (valor individual)
- **Bônus de Cooperação**: Multiplicador baseado na cooperação geral da sala
- **Participação**: Bonus por estar ativo no jogo

### 🎯 Fórmula de Ranking
```
Score = (publicos * 2 + privados * 1) * bonus_cooperacao * bonus_participacao
```

### 🥇 Classificações
- **1º Lugar**: Exibe coroa dourada no ranking
- **2º Lugar**: Medalha de prata
- **3º Lugar**: Medalha de bronze
- **Demais**: Listagem ordenada por performance

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

## 🎓 Sistema de Tutorial

### � Para Novos Jogadores
- **Tutorial automático** é exibido na primeira vez que um jogador entra
- **5 etapas progressivas** explicando todos os aspectos do jogo
- **Prática guiada** com instruções específicas
- **Acesso posterior** através da tecla **T**

### 📚 Etapas do Tutorial
1. **Básicos**: Movimento e controles fundamentais
2. **Coleta**: Como coletar queijos e diferenças entre tipos
3. **Cooperação**: Sistema de pote compartilhado e estratégia
4. **Eventos**: Explicação dos eventos aleatórios
5. **Ranking**: Como funciona o sistema de pontuação

## �🔄 Progressão do Jogo

### 📈 Escalabilidade por Rodada
- **Queijos por rodada**: Começa com 4 e aumenta 2 a cada rodada (máximo 12)
- **Fórmula**: `min(4 + (rodada - 1) * 2, 12)`

### ⏱️ Tempo por Rodada
- **Duração**: 30 segundos por rodada
- **Spawn**: Novos queijos aparecem a cada 0.5 segundos
- **Estratégico**: Queijos públicos spawnam em pares próximos

### 🗺️ Mapas
O jogo rotaciona entre 5 mapas diferentes:
- @5451839
- @5445849  
- @6599901
- @6682692
- @6399897

## 💡 Estratégias Avançadas

### 🤝 Cooperação Estratégica
- **Foque nos queijos públicos** quando o pote estiver próximo de 20
- **Coordene com outros jogadores** através do chat
- **Monitore o ranking** para ver quem está cooperando mais
- **Aproveite pares de queijos públicos** para maximizar eficiência

### 📊 Gerenciamento de Recursos
- **Queijos privados** são sua segurança pessoal
- **Queijos públicos** são investimento no grupo E no seu ranking
- **Balance** entre ganho pessoal e coletivo para maximizar score
- **Considere eventos** na sua estratégia de coleta

### 🎯 Otimização de Ranking
- **Priorize queijos públicos** para melhor score (valem 2x)
- **Mantenha participação ativa** para bonus
- **Colabore para aumentar** o multiplicador de cooperação da sala
- **Adapte estratégia** baseada na posição atual no ranking

## 🖥️ Interface Avançada

### 📊 Informações em Tempo Real
- **Evento atual** da rodada com ícone visual
- **Número da rodada** e progresso
- **Valor atual do pote** com meta destacada
- **Ranking em tempo real** com scores e posições
- **Estatísticas individuais** de cada jogador
- **Indicadores de cooperação** da sala

### 🎨 Elementos Visuais Aprimorados
- **Queijos verdes**: Públicos com partículas verdes intensas e spawn em pares
- **Queijos amarelos**: Privados com partículas amarelas brilhantes
- **Interface responsiva**: Painel superior com informações organizadas
- **Sistema de cores**: Diferentes cores para diferentes posições no ranking
- **Feedback visual**: Efeitos especiais para coletas e eventos

### 🔧 Sistema de Ajuda Integrado
- **Tecla H** abre painel completo de ajuda
- **Explicações contextuais** sobre todos os aspectos do jogo
- **Sempre disponível** durante qualquer rodada
- **Interface limpa** e fácil navegação

## � Sistema de Analytics e Logging

### 📊 Rastreamento de Ações
O jogo monitora e registra automaticamente:

- **Coletas de queijos**: Tipo, posição, timing de cada coleta
- **Eventos aplicados**: Qual evento afetou cada jogador e quando
- **Performance por rodada**: Scores, cooperação, participação
- **Movimentação de recursos**: Transferências entre potes e jogadores
- **Sessões de jogo**: Duração, número de rodadas, participantes

### 🔍 Métricas Calculadas
- **Taxa de cooperação individual**: Percentual de queijos públicos vs privados
- **Taxa de cooperação da sala**: Média geral de colaboração
- **Eficiência de coleta**: Sucesso na coleta vs queijos disponíveis
- **Impacto de eventos**: Como cada evento afeta diferentes jogadores
- **Evolução temporal**: Mudanças de estratégia ao longo das rodadas

### 📝 Log Detalhado
Todas as ações são registradas com:
- **Timestamp**: Momento exato da ação
- **Jogador**: Quem realizou a ação
- **Contexto**: Estado do jogo no momento
- **Resultado**: Consequências da ação

## �🚀 Como Rodar

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

### 🎮 Inicialização Automática
- O jogo inicia automaticamente quando o script é executado
- Todos os jogadores presentes no cafofo são incluídos automaticamente
- **Tutorial automático** é exibido para novos jogadores
- A primeira rodada começa após o tutorial (se necessário)
- Novos jogadores que entrarem são adicionados automaticamente

### ⚠️ Observações Importantes
- **Apenas o host** precisa executar o script
- **Apenas o host** precisa ter privilégios de moderação na guilda
- **Todos os outros jogadores** podem participar normalmente sem privilégios especiais
- O jogo roda enquanto o host mantiver o script ativo
- **Sistema de ajuda sempre disponível** através da tecla H

## 🔧 Configurações Técnicas Avançadas

### ⚡ Performance Otimizada
- **Auto-shaman**: Desabilitado para melhor performance
- **Auto-nova partida**: Desabilitado, controlado pelo script
- **Morte por AFK**: Desabilitada para não interromper sessões
- **Garbage collection**: Otimizada para evitar lag
- **Spawn inteligente**: Algoritmo eficiente para posicionamento de queijos

### 🔢 Parâmetros Balanceados
- **Raio de coleta**: 30 pixels (testado e otimizado)
- **Tempo por rodada**: 30 segundos (equilibrio entre ação e estratégia)
- **Meta do pote**: 20 pontos (desafio apropriado)
- **Multiplicador de recompensa**: 1.5x (incentivo à cooperação)
- **Intervalo de spawn**: 500ms (fluidez ideal)
- **Spawn em pares**: Queijos públicos aparecem próximos para estratégia

### 📊 Balanceamento de Jogo
- **Probabilidades ajustadas**: 60% público / 40% privado após extensos testes
- **Eventos equilibrados**: Nenhum evento domina completamente a estratégia
- **Ranking justo**: Sistema de pontuação que valoriza cooperação sem punir individualismo
- **Escalabilidade testada**: Funciona bem de 2 a 10+ jogadores

## 🏆 Dicas e Estratégias Avançadas

### 🎯 Para Iniciantes
1. **Faça o tutorial completo** antes de jogar (tecla T)
2. **Use o sistema de ajuda** durante o jogo (tecla H)
3. **Observe outros jogadores** para aprender estratégias
4. **Comece focando queijos privados** para segurança
5. **Gradualmente coopere mais** conforme entende o jogo

### 🧠 Para Jogadores Experientes
1. **Monitore o ranking em tempo real** para ajustar estratégia
2. **Antecipe eventos** e adapte coleta accordingly
3. **Coordene com outros jogadores** para maximizar potes
4. **Use pares de queijos públicos** para eficiência máxima
5. **Balance individual vs cooperativo** baseado na situação

### 🤝 Para Grupos Organizados
1. **Designem roles** (coletores públicos/privados)
2. **Comuniquem no chat** sobre metas de pote
3. **Rotem estratégias** entre rodadas
4. **Analisem dados do ranking** para melhorar
5. **Experimentem diferentes composições** de jogadores

### 📈 Análise de Performance
- **Acompanhe seu score** ao longo das rodadas
- **Compare cooperação** com outros jogadores
- **Identifique padrões** nos eventos que mais te afetam
- **Ajuste timing** de coleta baseado no ranking
- **Use analytics** para melhorar estratégia a longo prazo

## 📝 Créditos e Desenvolvimento

### 🎓 Contexto Acadêmico
Desenvolvido como um experimento avançado em jogos cooperativos e teoria dos jogos para a **Cadeira de Jogos & Dilemas Sociais**. O projeto explora:

- **Dilemas de cooperação** em ambientes multiplayer
- **Sistemas de incentivos** para colaboração
- **Análise comportamental** através de data analytics
- **Balanceamento de jogos** para diferentes tipos de jogadores
- **Design de sistemas** que promovem tanto competição quanto cooperação

### 🔬 Aspectos Teóricos Implementados
- **Dilema do Prisioneiro Iterado**: Através do sistema de pote compartilhado
- **Teoria dos Jogos Evolutivos**: Sistema de ranking e adaptação de estratégias
- **Economia Comportamental**: Eventos aleatórios que afetam tomada de decisão
- **Psicologia Social**: Tutorial e sistema de ajuda para inclusão de novos jogadores
- **Game Design**: Balanceamento entre elementos cooperativos e competitivos

### 🛠️ Tecnologias e Ferramentas
- **Linguagem**: Lua para Transformice
- **Plataforma**: Transformice (Motor de física custom)
- **Analytics**: Sistema próprio de logging e métricas
- **UI/UX**: Interface responsiva adaptada às limitações da plataforma
- **Algoritmos**: Sistemas de ranking, spawn inteligente, balanceamento dinâmico

### 📊 Funcionalidades Implementadas
- ✅ **Sistema de Ranking Avançado** com múltiplas métricas
- ✅ **Analytics e Logging Detalhado** para análise comportamental
- ✅ **Tutorial Interativo** para onboarding de novos jogadores
- ✅ **Sistema de Ajuda Integrado** sempre acessível
- ✅ **Spawn Estratégico** de queijos em pares para cooperação
- ✅ **Coleta Automática** com feedback visual aprimorado
- ✅ **Balanceamento Dinâmico** baseado no número de jogadores
- ✅ **Interface Responsiva** com informações em tempo real
- ✅ **Sistema de Performance** otimizado para múltiplos jogadores

### 🎯 Objetivos de Pesquisa Alcançados
1. **Criar um ambiente controlado** para estudo de comportamento cooperativo
2. **Implementar métricas quantitativas** para análise de estratégias
3. **Desenvolver sistemas de incentivos** balanceados
4. **Testar teorias de jogos** em ambiente prático
5. **Analisar padrões emergentes** de cooperação e competição

---

## 🔍 Referências Técnicas e Acadêmicas

### 📚 Documentação Técnica
* [FAQ + Documentação Lua Transformice](https://atelier801.com/topic?f=6&t=897795&p=1#m11)
* [Editor de Mapa Transformice](https://entibo.github.io/miceditor/)
* [Scripts Exemplo Transformice](https://github.com/Nonegustavo/Transformice-Lua-Scripts/tree/master/scripts)

### 🎓 Referências Teóricas
* **Game Theory**: Aplicação prática de dilemas sociais em jogos
* **Behavioral Economics**: Sistemas de incentivos e tomada de decisão
* **Social Psychology**: Dinâmicas de grupo e cooperação
* **Game Design**: Balanceamento e engajamento de jogadores

### 🔬 Métricas e Analytics
O jogo coleta dados extensivos que podem ser utilizados para:
- **Análise de padrões comportamentais** em situações cooperativas
- **Estudo de eficácia de diferentes incentivos** à cooperação
- **Comparação de estratégias** entre diferentes tipos de jogadores
- **Avaliação do impacto de eventos aleatórios** na tomada de decisão
- **Medição de curvas de aprendizado** através do sistema de tutorial

---

**Divirta-se jogando Share Cheese e contribuindo para a pesquisa em jogos cooperativos! 🧀✨**


*"Um jogo é um sistema no qual os jogadores se envolvem em um conflito artificial, definido por regras, que resulta em um resultado quantificável."* - Katie Salen & Eric Zimmerman
