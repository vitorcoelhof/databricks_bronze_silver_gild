# Camada Bronze - Ingestão de Dados

## 📋 Visão Geral

Esta camada Bronze implementa a ingestão de dados brutos dos volumes CSV para o Lakehouse usando Lakeflow Declarative Pipelines do Databricks.

## 🥉 Tabelas Bronze Implementadas

### 1. `bronze.customers`
- **Fonte**: `/Volumes/lakehouse/raw_public/customers`
- **Descrição**: Dados de clientes com informações demográficas e segmentação
- **Campos**: customer_id, customer_name, documento, segmento, pais, estado, cidade, created_at
- **Registros**: ~12 clientes

### 2. `bronze.transaction_btc`
- **Fonte**: `/Volumes/lakehouse/raw_public/transacation_btc`
- **Descrição**: Transações de Bitcoin
- **Campos**: transaction_id, data_hora, ativo, quantidade, tipo_operacao, moeda, cliente_id, canal, mercado, arquivo_origem, importado_em
- **Registros**: ~5.901 transações

### 3. `bronze.transaction_commodities`
- **Fonte**: `/Volumes/lakehouse/raw_public/transaction_commodities`
- **Descrição**: Transações de commodities (GOLD, OIL, SILVER)
- **Campos**: transaction_id, data_hora, commodity_code, quantidade, tipo_operacao, unidade, moeda, cliente_id, canal, mercado, arquivo_origem, importado_em
- **Registros**: ~8.819 transações

### 4. `bronze.quotation_btc`
- **Fonte**: `/Volumes/lakehouse/raw_public/quotation_btc`
- **Descrição**: Cotações de Bitcoin (BTC-USD)
- **Campos**: ativo, preco, moeda, horario_coleta
- **Registros**: ~14.182 cotações

### 5. `bronze.quotation_yfinance`
- **Fonte**: `/Volumes/lakehouse/raw_public/quotation_yfinance`
- **Descrição**: Cotações de commodities via yFinance (GC=F, CL=F, SI=F)
- **Campos**: ativo, preco, moeda, horario_coleta
- **Registros**: ~27.698 cotações

## ⚙️ Configurações Técnicas

### 🔄 Streaming Tables
- **Tipo**: `CREATE OR REFRESH STREAMING TABLE`
- **Benefício**: Processamento incremental e evita erros de batch query
- **Timestamp**: `current_timestamp() as ingested_at` para auditoria

### 📊 Ingestão com cloud_files
```sql
FROM cloud_files(
  "/Volumes/lakehouse/raw_public/[arquivo]",
  "csv",
  map("header", "true", "inferSchema", "true")
)
```

### 🛡️ Características
- **Schema**: Inferência automática de tipos
- **Incremental**: Processamento automático de novos arquivos
- **Versionamento**: Controle automático de versões dos dados
- **Auditoria**: Timestamp de ingestão em todas as tabelas

## 🚀 Próximos Passos

As tabelas Bronze estão prontas para serem consumidas pela camada Silver, onde serão aplicadas:
- Transformações e normalizações
- Validações de qualidade de dados
- Joins entre tabelas
- Cálculos de métricas de negócio
