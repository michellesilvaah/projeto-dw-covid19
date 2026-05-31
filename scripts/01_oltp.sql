
-- Criando tabelas normalizadas a partir do staging
-- Remove duplicatas e trata valores nulos
-- ============================================================

-- Tabela de países (normalizada)
CREATE OR REPLACE TABLE oltp_countries AS
SELECT DISTINCT
    iso_code,
    location,
    continent,
    CAST(population AS BIGINT)                  AS population,
    CAST(human_development_index AS DOUBLE)      AS human_development_index
FROM stg_covid
WHERE iso_code IS NOT NULL
  AND iso_code NOT LIKE 'OWID_%'  -- remove agregados como OWID_WRL (mundo inteiro)
  AND location IS NOT NULL;

-- Tabela de registros diários (normalizada)
CREATE OR REPLACE TABLE oltp_daily AS
SELECT
    iso_code,
    CAST(date AS DATE)                          AS date,
    COALESCE(CAST(new_cases AS DOUBLE), 0)      AS new_cases,
    COALESCE(CAST(new_deaths AS DOUBLE), 0)     AS new_deaths,
    COALESCE(CAST(total_cases AS DOUBLE), 0)    AS total_cases,
    COALESCE(CAST(total_deaths AS DOUBLE), 0)   AS total_deaths,
    COALESCE(CAST(new_vaccinations AS DOUBLE), 0)       AS new_vaccinations,
    COALESCE(CAST(total_vaccinations AS DOUBLE), 0)     AS total_vaccinations,
    COALESCE(CAST(people_vaccinated AS DOUBLE), 0)      AS people_vaccinated,
    COALESCE(CAST(reproduction_rate AS DOUBLE), 0)      AS reproduction_rate,
    COALESCE(CAST(hosp_patients AS DOUBLE), 0)          AS hosp_patients
FROM stg_covid
WHERE iso_code IS NOT NULL
  AND iso_code NOT LIKE 'OWID_%'
  AND date IS NOT NULL;

-- Verificações
SELECT COUNT(*) AS total_paises  FROM oltp_countries;
SELECT COUNT(*) AS total_registros FROM oltp_daily;