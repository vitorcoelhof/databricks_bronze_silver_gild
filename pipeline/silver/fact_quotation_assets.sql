-- =====================================================
-- Tabela Silver: fact_quotation_assets
-- Descrição: União de cotações Bitcoin e yFinance com símbolos padronizados
-- Fonte: bronze.quotation_btc + bronze.quotation_yfinance
-- =====================================================

CREATE OR REFRESH STREAMING TABLE silver.fact_quotation_assets
(
  CONSTRAINT preco_positivo EXPECT (preco > 0) ON VIOLATION DROP ROW,
  CONSTRAINT horario_coleta_valido EXPECT (horario_coleta <= current_timestamp()) ON VIOLATION DROP ROW,
  CONSTRAINT ativo_nao_vazio EXPECT (ativo IS NOT NULL AND ativo != '') ON VIOLATION DROP ROW,
  CONSTRAINT moeda_usd EXPECT (moeda = 'USD') ON VIOLATION DROP ROW
)
AS SELECT 
  -- Mapeamento de símbolos padronizado
  CASE 
    WHEN UPPER(ativo) IN ('BTC','BTC-USD') THEN 'BTC'
    WHEN UPPER(ativo) IN ('GOLD','GC=F')   THEN 'GOLD'
    WHEN UPPER(ativo) IN ('OIL','CL=F')    THEN 'OIL'
    WHEN UPPER(ativo) IN ('SILVER','SI=F') THEN 'SILVER'
    ELSE 'UNKNOWN'
  END AS asset_symbol,
  ativo as ativo_original,
  preco,
  moeda,
  CAST(horario_coleta AS TIMESTAMP) as timestamp_cotacao,
  date_trunc('hour', CAST(horario_coleta AS TIMESTAMP)) as data_hora_aproximada,
  current_timestamp() as processed_at
FROM (
  -- Cotações Bitcoin
  SELECT 
    ativo,
    preco,
    moeda,
    horario_coleta
  FROM STREAM(bronze.quotation_btc)
  
  UNION ALL
  
  -- Cotações yFinance
  SELECT 
    ativo,
    preco,
    moeda,
    horario_coleta
  FROM STREAM(bronze.quotation_yfinance)
)
