
-- Carga completa do Data Warehouse
-- dim_date, dim_pandemic_phase, dim_location e fact_covid
-- ============================================================


-- PASSO 1: Carregar dim_date
-- Gera um registro para cada dia entre 2020-01-01 e 2024-12-31

INSERT OR IGNORE INTO dim_date
SELECT
    CAST(strftime(range_date, '%Y%m%d') AS INTEGER)  AS date_key,
    range_date::DATE                                  AS date,
    YEAR(range_date)                                  AS year,
    MONTH(range_date)                                 AS month,
    strftime(range_date, '%B')                        AS month_name,
    QUARTER(range_date)                               AS quarter,
    WEEKOFYEAR(range_date)                            AS week,
    DAY(range_date)                                   AS day,
    dayname(range_date)                               AS day_of_week,
    CASE WHEN dayofweek(range_date) IN (0, 6)
         THEN true ELSE false END                     AS is_weekend
FROM (
    SELECT unnest(
        generate_series(
            DATE '2020-01-01',
            DATE '2024-12-31',
            INTERVAL '1 day'
        )
    ) AS range_date
);

-- Verificação
SELECT COUNT(*) AS total_dias FROM dim_date;


-- ------------------------------------------------------------

-- ETAPA 2: Carregar dim_pandemic_phase
-- Insere manualmente as 5 fases da pandemia

INSERT OR IGNORE INTO dim_pandemic_phase VALUES
    (1, 'Pre-pandemia',       1, 'Periodo anterior ao primeiro caso confirmado no Brasil'),
    (2, 'Primeira onda',      2, 'Primeiro pico de casos e mortes — março a setembro de 2020'),
    (3, 'Segunda onda',       3, 'Segundo pico severo com variante Gama — outubro 2020 a junho 2021'),
    (4, 'Vacinacao em massa', 4, 'Inicio da vacinacao em massa e queda dos indicadores — julho 2021 a 2022'),
    (5, 'Endemia',            5, 'Estabilizacao dos casos e transicao para endemia — 2023 em diante');

-- Verificação
SELECT * FROM dim_pandemic_phase;


-- ------------------------------------------------------------

-- ETAPA 3: Carregar dim_location (com SCD Type 2)
-- Insere cada país com is_current = true

INSERT OR IGNORE INTO dim_location
SELECT
    ROW_NUMBER() OVER (ORDER BY iso_code)   AS location_key,
    iso_code,
    location,
    continent,
    population,
    human_development_index,
    DATE '2020-01-01'                       AS start_date,
    NULL                                    AS end_date,
    true                                    AS is_current
FROM oltp_countries
ORDER BY iso_code;

-- Verificação
SELECT COUNT(*) AS total_paises FROM dim_location;


-- ------------------------------------------------------------

-- ETAPA 4: Carregar fact_covid
-- Cruza os registros diários com as chaves das dimensões

INSERT OR IGNORE INTO fact_covid
SELECT
    ROW_NUMBER() OVER (ORDER BY d.date_key, l.location_key)  AS fact_key,
    d.date_key,
    l.location_key,
    -- Define a fase com base na data
    CASE
        WHEN o.date < '2020-03-01' THEN 1
        WHEN o.date < '2020-10-01' THEN 2
        WHEN o.date < '2021-07-01' THEN 3
        WHEN o.date < '2023-01-01' THEN 4
        ELSE 5
    END                                                       AS phase_key,
    o.new_cases,
    o.new_deaths,
    o.total_cases,
    o.total_deaths,
    o.new_vaccinations,
    o.total_vaccinations,
    o.people_vaccinated,
    o.reproduction_rate,
    o.hosp_patients
FROM oltp_daily o
JOIN dim_date     d ON d.date     = o.date
JOIN dim_location l ON l.iso_code = o.iso_code
                    AND l.is_current = true;

-- Verificação final
SELECT COUNT(*) AS total_registros_fato FROM fact_covid; 