# Camada Silver - Transformação e Qualidade de Dados

## 📋 Visão Geral

Esta camada Silver implementa transformações, normalizações e validações de qualidade de dados usando Lakeflow Declarative Pipelines do Databricks com [Data Quality Expectations](https://docs.databricks.com/aws/en/dlt/expectations?language=SQL).

## 🥈 Tabelas Silver Implementadas

### 1. `silver.fact_transaction_assets`
- **Fonte**: `bronze.transaction_btc` + `bronze.transaction_commodities`
- **Descrição**: União de transações Bitcoin e commodities com símbolos padronizados
- **Transformações**:
  - União de tabelas de transações
  - Casting de `data_hora` para TIMESTAMP
  - Hora aproximada com `date_trunc('hour')`
  - Mapeamento unificado de símbolos de ativos
- **Constraints de Qualidade**:
  - `quantidade > 0`
  - `data_hora IS NOT NULL`
  - `tipo_operacao IN ('COMPRA','VENDA')`
  - `asset_symbol IN ('BTC','GOLD','OIL','SILVER')`

### 2. `silver.fact_quotation_assets`
- **Fonte**: `bronze.quotation_btc` + `bronze.quotation_yfinance`
- **Descrição**: União de cotações Bitcoin e yFinance com símbolos padronizados
- **Transformações**:
  - União de tabelas de cotações
  - Casting de `horario_coleta` para TIMESTAMP
  - Hora aproximada com `date_trunc('hour')`
  - Mapeamento unificado de símbolos de ativos
- **Constraints de Qualidade**:
  - `preco > 0`
  - `horario_coleta <= current_timestamp()`
  - `ativo IS NOT NULL AND ativo != ''`
  - `moeda = 'USD'`

### 3. `silver.dim_clientes`
- **Fonte**: `bronze.customers`
- **Descrição**: Dimensão de clientes com anonimização e validações
- **Transformações**:
  - Anonimização: `SHA2(documento, 256) as documento_hash`
  - Casting de `created_at` para TIMESTAMP
  - Validação de segmentos, países e estados
- **Constraints de Qualidade**:
  - `customer_id IS NOT NULL`
  - `segmento IN ('Financeiro', 'Indústria', 'Varejo', 'Tecnologia')`
  - `pais IN ('Brasil', 'Alemanha', 'Estados Unidos')`
  - Validação de estados apenas para Brasil (Alemanha e EUA aceitam qualquer estado)

### 4. `silver.fact_transaction_revenue`
- **Fonte**: `silver.fact_transaction_assets` + `silver.fact_quotation_assets` + `silver.dim_clientes`
- **Descrição**: Join transações + cotações + clientes com cálculos financeiros
- **Transformações**:
  - Join por `asset_symbol` e `data_hora_aproximada`
  - Cálculos financeiros: `gross_value = quantidade × preço`
  - Lógica do sinal: VENDA(+) / COMPRA(-)
  - Receita de taxa: 0.25% sobre valor total
- **Constraints de Qualidade**:
  - `gross_value > 0`
  - `fee_revenue > 0`
  - `customer_sk IS NOT NULL`
  - `preco_cotacao > 0 AND timestamp_cotacao <= data_hora`

## 🔄 Mapeamento de Símbolos Padronizado

| CSV Original | Símbolo Original | Símbolo Padronizado |
|--------------|------------------|---------------------|
| **transaction_btc** | BTC | BTC |
| **transaction_commodities** | GOLD | GOLD |
| **transaction_commodities** | OIL | OIL |
| **transaction_commodities** | SILVER | SILVER |
| **quotation_btc** | BTC-USD | BTC |
| **quotation_yfinance** | GC=F | GOLD |
| **quotation_yfinance** | CL=F | OIL |
| **quotation_yfinance** | SI=F | SILVER |

## ⚙️ Configurações Técnicas

### 🔄 Streaming Tables
- **Tipo**: `CREATE OR REFRESH STREAMING TABLE`
- **Fonte**: `FROM STREAM(tabela_origem)`
- **Benefício**: Processamento incremental e evita erros de batch query

### 🛡️ Data Quality com Expectations
- **Sintaxe**: `CONSTRAINT nome_valid EXPECT (condicao) ON VIOLATION DROP ROW`
- **Ação**: `ON VIOLATION DROP ROW` - Remove registros inválidos
- **Monitoramento**: Logs automáticos de violações via UI do Databricks
- **Métricas**: Tracking de qualidade de dados em tempo real

### 🔒 Segurança e Anonimização
- **PII**: `SHA2(documento, 256)` para documentos sensíveis
- **Governança**: Unity Catalog
- **Auditoria**: Lakeflow Lineage completo

## 💰 Cálculos Financeiros Implementados

### Lógica do Sinal
```sql
CASE 
  WHEN tipo_operacao = 'VENDA' THEN (quantidade * preco)
  WHEN tipo_operacao = 'COMPRA' THEN -(quantidade * preco)
  ELSE 0
END as gross_value_sinal
```

### Receita de Taxa
```sql
(quantidade * preco * 0.0025) as fee_revenue
```

## 🚀 Próximos Passos

As tabelas Silver estão prontas para serem consumidas pela camada Gold, onde serão aplicadas:
- Agregações de métricas de negócio
- Segmentação de clientes (Top 1, 2, 3)
- Rankings por volume de transações
- Análises de frequência e rentabilidade
