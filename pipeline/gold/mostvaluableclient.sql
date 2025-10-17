CREATE OR REFRESH STREAMING TABLE gold.mostvaluableclient AS
SELECT
  customer_sk,
  customer_name,
  segmento,
  pais,
  estado,
  cidade,
  
  COUNT(*) as total_transacoes,
  SUM(gross_value) as valor_total,
  AVG(gross_value) as ticket_medio,
  MIN(data_hora) as primeira_transacao,
  MAX(data_hora) as ultima_transacao,
  
  COUNT(CASE 
    WHEN data_hora >= (SELECT MAX(data_hora) FROM lakehouse.silver.fact_transaction_revenue) - INTERVAL 30 DAYS THEN 1 
  END) AS transacoes_ultimos_30_dias,
  
  SUM(fee_revenue) as comissao_total,

  current_timestamp() as calculated_at

FROM STREAM(silver.fact_transaction_revenue)
GROUP BY 
  customer_sk,
  customer_name,
  segmento,
  pais,
  estado,
  cidade
-- remove ORDER BY because streaming does not support it directly
;