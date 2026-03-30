# 1. Lógica / Arquitetura / Conceitos Salesforce

## Pesquisa (Lookup) vs. Mestre-Detalhe (Master-Detail)

**Lookup:**
- Os registros são independentes.
- Deletar o pai não deleta o filho.

**Mestre-Detalhe:**
- Relacionamento forte.
- O filho herda regras de compartilhamento e proprietário do pai.
- Deletar o pai causa exclusão em cascata.
- Permite campos de Roll-up Summary no pai.

---

## Papel (Role), Perfil (Profile) e Permission Set

**Perfil (Profile):** O que o usuário pode fazer (CRUD, login, layouts).

**Papel (Role):** O que o usuário pode ver (hierarquia de visibilidade).

**Permission Set:**
- Adiciona permissões extras
- Além de ter 'Permission Set Group' que é um conjunto de permissoes para X usuario
  
---

##  Uma automação precisa chamar um sistema externo. Qual abordagem você usaria?

- De maneira geral, costumo utilizar Queueable, por poder agendar  novos jobs subsequentes, alem de lidar com alguma lógica q esse callout possa retornar, apesar de entender o uso do External Service quando tem uma API com Swagger/OpenAPI. Os queueables lidam bem com o tratamento dos dados comunicados entre as APIs, além de ser facilmente escalavel

  
---

## Um trigger precisa executar um callout HTTP para um sistema externo após a
atualização de um registro. Qual abordagem você utilizaria?

- Utilizaria Queueable Apex, por aceitar SObjects, permitir encadeamento de trabalhos, alem de ser possivel monitorar com Job ID, além de criar um Custom Object para Integracao, onde teria dados como o retorno da API, o body request, qual API chamou, horas, o SObject relacionado etc, para um melhor monitoramento 

---

## Um processo precisa ser executado todas as noites às 2h da manhã para atualizar
registros. Qual abordagem você utilizaria?

- Schedulable Apex + Batch Apex. Simples e potente. Se utilizasse callouts, utilizaria o Schedulable + Queueable

---

# 2. Apex Assíncrono

## Diferenças

**Batch Apex:** (Ideal para modificar em chunks diversos registros)
- Processa até 50 milhões de registros
- Divide em chunks

**Queueable Apex:**(Ideal para tratar dados subsequentes e fazer callouts)
- Processamento em background
- Suporta SObjects
- Permite encadeamento
- Possui Job ID p/ monitorar

**Future Methods:**(apesar de ser meio DEPRECATED, ainda é util para casos simples, ex: em uma API, usar um future para inserir/atualizar um registro no Salesforce como @future, inves de fazer a requisiçao esperar o tempo de processamento, desde que também não seja um registro complexo por ex)
- Thread separada
- Aceita apenas tipos primitivos
- Não permite encadeamento

---

# 3. Debug / Troubleshooting

## Um fluxo está falhando em produção, mas funciona no sandbox. Como você
investigaria?

**Ações:**
- Validar o erro em Settings -> Failed Flow Interviews ( geralmente pode ser problemas de callout uncommnited working pending, too many Queuables, too many SOQL se for mal otimizado, etc)
- Ativar Debug Logs
- Verificar Fault Paths
- Comparar Profiles / Permission Sets

---

## Como usar Debug Logs para encontrar um erro em um trigger?

- Settings -> Debug Logs
- Preenche os parametros de acordo com o que você deseja trackear, debuga o DevConsole Finest, além de inserir logs informativos em Apex com System.debug(), em testes abrir o Dev Console e ver os logs


---

# 4. Flows

**Screen Flow:**
- Interface com usuário
- Inputs e telas

**Record-Triggered Flow:**
- Executa automaticamente (create/update/delete)

**Autolaunched Flow:** (EX: chamar uma action em um Flow)
- Sem interface
- Chamado por Apex, APIs ou outros flows

---

## Flow vs Apex

**Flow:**
- Lógica declarativa
- Atualizações simples

**Apex:**
- Alta complexidade (tratar diversos objetos, integraçoes, fazer buscar no SOQL especificas, etc)
- Grande volume (bulk)
- Integrações complexas (ex: callouts)

---

## Before Save Flow

- Executa antes do commit no banco
- Equivalente a `before insert/update`

**Vantagem:**
- Não precisa de DML adicional e velocidade de execuçao

---

# 5. API REST / Integração

## Callouts

**Síncrono:** 
- Espera resposta (timeout até 120s). Ex: uma REST API que faz insert, ele espera terminar o insert, para retornar a resposta ao requester

**Assíncrono:**
- Libera thread
- Resposta tratada depois (Continuation/Webhook)

---

## Quando criar Custom Apex REST

- Quando APIs padrão não atendem(ex: buscas SOQL, insert, update, etc)
- Payload com múltiplos objetos
- Validações complexas
- Orquestração de lógica de negócio 

---

# 6. Experience Cloud
- Geralmente utilizado para portal de clientes, suporte, parcieros, etc. Funcionam como um front end. O mais atual, é utilizando LWC inves de Visual Force(legado). É utilizado p/ usuarios externos autenticados
