
-- Otimização de performance com tabela agregada
-- Comparando velocidade da query original vs tabela pré-calculada
-- ============================================================


-- ------------------------------------------------------------
-- ETAPA 1: Criar tabela agregada pré-calculada
-- Evita recalcular SUM e JOIN toda vez que a query rodar

CREATE OR REPLACE TABLE agg_brasil_mensal AS
SELECT
    d.year                                                      AS ano,
    d.month                                                     AS mes,
    d.month_name                                                AS nome_mes,
    p.phase_name                                                AS fase,
    SUM(f.new_cases)                                            AS total_casos,
    SUM(f.new_deaths)                                           AS total_mortes,
    SUM(f.new_vaccinations)                                     AS total_vacinacoes,
    MAX(f.people_vaccinated)                                    AS pessoas_vacinadas,
    ROUND(
        SUM(f.new_deaths) / NULLIF(SUM(f.new_cases), 0) * 100
    , 4)                                                        AS taxa_mortalidade_pct
FROM fact_covid f
JOIN dim_date           d ON d.date_key     = f.date_key
JOIN dim_location       l ON l.location_key = f.location_key
JOIN dim_pandemic_phase p ON p.phase_key    = f.phase_key
WHERE l.iso_code = 'BRA'
GROUP BY d.year, d.month, d.month_name, p.phase_name
ORDER BY d.year, d.month;

-- Verificação
SELECT COUNT(*) AS total_linhas FROM agg_brasil_mensal;


-- ------------------------------------------------------------
-- ETAPA 2: Query ANTES da otimização (com JOINs e agregações)
-- Medindo o tempo de execução da query original

.timer on

SELECT
    d.year, d.month_name,
    SUM(f.new_cases)  AS total_casos,
    SUM(f.new_deaths) AS total_mortes
FROM fact_covid f
JOIN dim_date     d ON d.date_key     = f.date_key
JOIN dim_location l ON l.location_key = f.location_key
WHERE l.iso_code = 'BRA'
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;


-- ------------------------------------------------------------
-- ETAPA 3: Query DEPOIS da otimização (usando tabela agregada)
-- Medindo o tempo de execução da query otimizada

SELECT
    ano, nome_mes,
    total_casos,
    total_mortes
FROM agg_brasil_mensal
ORDER BY ano, mes;

.timer off


-- ------------------------------------------------------------
-- ETAPA 4: Documentação do ganho de performance

SELECT
    'Query original (com JOINs)'    AS abordagem,
    'fact_covid + dim_date + dim_location (3 JOINs, agregacao completa)' AS descricao
UNION ALL
SELECT
    'Query otimizada (tabela agregada)' AS abordagem,
    'agg_brasil_mensal (SELECT simples, sem JOINs, sem agregacao)'       AS descricao;