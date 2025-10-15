# Camada Gold - Métricas de Negócio e Segmentação

## 📋 Visão Geral

Esta camada Gold implementa métricas de negócio e segmentação de clientes usando Lakeflow Declarative Pipelines do Databricks, fornecendo insights estratégicos para tomada de decisão.

## 🥇 Tabela Gold Implementada

### `gold.mostvaluableclient`
- **Fonte**: `silver.fact_transaction_revenue`
- **Descrição**: Métricas de negócio e segmentação de clientes por volume de transações
- **Objetivo**: Identificar clientes mais valiosos (Top 1/2/3) e clientes em risco para personalização de atendimento

## 📊 Métricas Implementadas

### 🔢 **Métricas de Transações**
- `total_transacoes`: COUNT(*) - Número total de transações por cliente
- `valor_total`: SUM(gross_value) - Valor total das transações
- `ticket_medio`: AVG(gross_value) - Valor médio por transação
- `primeira_transacao`: MIN(data_hora) - Primeira transação do cliente
- `ultima_transacao`: MAX(data_hora) - Última transação do cliente

### ⏰ **Métricas de Frequência**
- `transacoes_ultimos_30_dias`: COUNT com filtro de 30 dias baseado na data máxima da tabela
- **Lógica**: Análise consistente baseada nos dados disponíveis (não `current_timestamp()`)
- **Período**: 30 dias antes da última transação registrada

### 💰 **Métricas Financeiras**
- `comissao_total`: SUM(fee_revenue) - Receita total de taxas (0.25% sobre valor total)

### 🏆 **Métricas de Segmentação**
- `ranking_por_transacoes`: RANK() baseado no número de transações (maior para menor)
- `classificacao_cliente`: Classificação Top 1/2/3 ou Outros

## 🎯 Segmentação de Clientes

### **Lógica de Classificação**
```sql
CASE 
  WHEN RANK() OVER (ORDER BY COUNT(*) DESC) = 1 THEN 'Top 1'
  WHEN RANK() OVER (ORDER BY COUNT(*) DESC) = 2 THEN 'Top 2'
  WHEN RANK() OVER (ORDER BY COUNT(*) DESC) = 3 THEN 'Top 3'
  ELSE 'Outros'
END AS classificacao_cliente
```

### **Categorias de Clientes**
- **Top 1**: Cliente com maior número de transações (RANK = 1)
- **Top 2**: Cliente com segunda maior quantidade (RANK = 2)
- **Top 3**: Cliente com terceira maior quantidade (RANK = 3)
- **Outros**: Demais clientes (RANK > 3)

## 📈 Análises Disponíveis

### 🎯 **Segmentação por Volume**
- Identificação de clientes mais ativos (Top 1, 2, 3)
- Ranking por número de transações
- Análise de distribuição de atividade

### 💼 **Análise Financeira**
- Receita total por cliente
- Ticket médio de transações
- Receita de taxas por cliente
- Análise de rentabilidade

### ⏱️ **Análise Temporal**
- Primeira e última transação por cliente
- Frequência de transações (últimos 30 dias)
- Identificação de clientes inativos

### 🌍 **Análise Geográfica**
- Segmentação por país, estado e cidade
- Análise de distribuição geográfica dos clientes

## ⚙️ Configurações Técnicas

### 🔄 **Streaming Table**
- **Tipo**: `CREATE OR REFRESH STREAMING TABLE`
- **Fonte**: `FROM STREAM(silver.fact_transaction_revenue)`
- **Benefício**: Processamento incremental e atualizações em tempo real

### 📊 **Agregações**
- **GROUP BY**: customer_sk, customer_name, segmento, pais, estado, cidade
- **ORDER BY**: total_transacoes DESC (maior para menor)

### 🕐 **Lógica dos Últimos 30 Dias**
```sql
COUNT(CASE 
  WHEN data_hora >= (SELECT MAX(data_hora) FROM lakehouse.silver.fact_transaction_revenue) - INTERVAL 30 DAYS THEN 1 
END) AS transacoes_ultimos_30_dias
```

## 🎯 Impacto de Negócio

### 📈 **Benefícios Esperados**
- **Priorização**: Identificação de clientes mais valiosos para atendimento prioritário
- **Retenção**: Ações proativas para clientes em risco de churn
- **Upsell**: Oportunidades de crescimento com clientes Top 1, 2, 3
- **Personalização**: Relacionamento customizado baseado em segmentação

### 📊 **KPIs Monitorados**
- Redução de churn (%)
- Aumento do LTV médio (R$)
- Crescimento da receita de taxa
- Maior frequência média de transações (últimos 30 dias)
- Aumento do ticket médio de transação

## 🚀 Próximos Passos

A tabela Gold está pronta para:
- Dashboards de business intelligence
- Relatórios executivos
- Alertas de clientes em risco
- Campanhas de marketing direcionadas
- Análises de tendências e padrões
