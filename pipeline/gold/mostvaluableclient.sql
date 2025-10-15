-- =====================================================
-- Tabela Gold: mostvaluableclient
-- Descrição: Métricas de negócio e segmentação de clientes
-- Fonte: silver.fact_transaction_revenue
-- =====================================================

CREATE OR REFRESH STREAMING TABLE gold.mostvaluableclient
AS SELECT 
  customer_sk,
  customer_name,
  segmento,
  pais,
  estado,
  cidade,
  
  -- Métricas de transações
  COUNT(*) as total_transacoes,
  SUM(gross_value) as valor_total,
  AVG(gross_value) as ticket_medio,
  MIN(data_hora) as primeira_transacao,
  MAX(data_hora) as ultima_transacao,
  
  -- Frequência nos últimos 30 dias (baseado na data máxima da tabela)
  COUNT(CASE 
    WHEN data_hora >= (SELECT MAX(data_hora) FROM lakehouse.silver.fact_transaction_revenue) - INTERVAL 30 DAYS THEN 1 
  END) AS transacoes_ultimos_30_dias,
  
  -- Receita de taxas
  SUM(fee_revenue) as comissao_total,
  
  -- Ranking por número de transações
  RANK() OVER (ORDER BY COUNT(*) DESC) as ranking_por_transacoes,
  
  -- Classificação de cliente (Top 1, 2, 3 ou Outros)
  CASE 
    WHEN RANK() OVER (ORDER BY COUNT(*) DESC) = 1 THEN 'Top 1'
    WHEN RANK() OVER (ORDER BY COUNT(*) DESC) = 2 THEN 'Top 2'
    WHEN RANK() OVER (ORDER BY COUNT(*) DESC) = 3 THEN 'Top 3'
    ELSE 'Outros'
  END AS classificacao_cliente,
  
  -- Timestamp de cálculo
  current_timestamp() as calculated_at

FROM STREAM(silver.fact_transaction_revenue)
GROUP BY 
  customer_sk,
  customer_name,
  segmento,
  pais,
  estado,
  cidade
ORDER BY total_transacoes DESC
