
-- Consultas analíticas
-- Consulta para Responde às 5 perguntas definidas.
-- ============================================================



--  1 — Análise Temporal
-- Como evoluíram os casos e mortes no Brasil mês a mês?

SELECT
    d.year                          AS ano,
    d.month                         AS mes,
    d.month_name                    AS nome_mes,
    SUM(f.new_cases)                AS total_casos_novos,
    SUM(f.new_deaths)               AS total_mortes_novas,
    SUM(f.new_vaccinations)         AS total_vacinacoes
FROM fact_covid f
JOIN dim_date     d ON d.date_key     = f.date_key
JOIN dim_location l ON l.location_key = f.location_key
WHERE l.iso_code = 'BRA'
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;

-- ------------------------------------------------------------

-- QUERY 2 — Ranking / TOP N
-- Quais foram os 10 meses com mais mortes no Brasil?

SELECT
    d.year                          AS ano,
    d.month_name                    AS mes,
    SUM(f.new_deaths)               AS total_mortes
FROM fact_covid f
JOIN dim_date     d ON d.date_key     = f.date_key
JOIN dim_location l ON l.location_key = f.location_key
WHERE l.iso_code = 'BRA'
GROUP BY d.year, d.month, d.month_name
ORDER BY total_mortes DESC
LIMIT 10;

-- ------------------------------------------------------------

-- QUERY 3 — Agregação Multidimensional
-- Vacinação vs casos e mortes no Brasil mês a mês

SELECT
    d.year                                          AS ano,
    d.month_name                                    AS mes,
    MAX(f.people_vaccinated)                        AS pessoas_vacinadas,
    SUM(f.new_cases)                                AS casos_novos,
    SUM(f.new_deaths)                               AS mortes_novas,
    p.phase_name                                    AS fase_pandemia
FROM fact_covid f
JOIN dim_date           d ON d.date_key     = f.date_key
JOIN dim_location       l ON l.location_key = f.location_key
JOIN dim_pandemic_phase p ON p.phase_key    = f.phase_key
WHERE l.iso_code = 'BRA'
GROUP BY d.year, d.month, d.month_name, p.phase_name
ORDER BY d.year, d.month;

-- ------------------------------------------------------------

-- QUERY 4 — Cohort / Comportamento ao longo do tempo
-- Taxa de mortalidade antes, durante e após a vacinação

SELECT
    p.phase_name                                        AS fase,
    p.phase_order                                       AS ordem,
    SUM(f.new_cases)                                    AS total_casos,
    SUM(f.new_deaths)                                   AS total_mortes,
    ROUND(
        SUM(f.new_deaths) / NULLIF(SUM(f.new_cases), 0) * 100
    , 4)                                                AS taxa_mortalidade_pct
FROM fact_covid f
JOIN dim_location       l ON l.location_key = f.location_key
JOIN dim_pandemic_phase p ON p.phase_key    = f.phase_key
WHERE l.iso_code = 'BRA'
GROUP BY p.phase_name, p.phase_order
ORDER BY p.phase_order;

-- ------------------------------------------------------------

-- QUERY 5 — KPI de Negócio
-- Indicadores-chave da pandemia no Brasil

SELECT
    MAX(f.new_cases)                                    AS pico_casos_diarios,
    MAX(f.new_deaths)                                   AS pico_mortes_diarias,
    MAX(f.total_cases)                                  AS total_acumulado_casos,
    MAX(f.total_deaths)                                 AS total_acumulado_mortes,
    MAX(f.people_vaccinated)                            AS total_pessoas_vacinadas,
    ROUND(
        MAX(f.people_vaccinated) / MAX(l.population) * 100
    , 2)                                                AS cobertura_vacinal_pct
FROM fact_covid f
JOIN dim_location l ON l.location_key = f.location_key
WHERE l.iso_code = 'BRA';
