
-- Criando a estrutura vazia do Data Warehouse (modelo estrela)
-- As tabelas são criadas aqui mas preenchidas no script 03
-- ============================================================

-- Dimensão de tempo
CREATE OR REPLACE TABLE dim_date (
    date_key        INTEGER PRIMARY KEY,
    date            DATE,
    year            INTEGER,
    month           INTEGER,
    month_name      VARCHAR,
    quarter         INTEGER,
    week            INTEGER,
    day             INTEGER,
    day_of_week     VARCHAR,
    is_weekend      BOOLEAN
);

-- Dimensão de localização (com SCD Type 2)
CREATE OR REPLACE TABLE dim_location (
    location_key                INTEGER PRIMARY KEY,
    iso_code                    VARCHAR,
    location                    VARCHAR,
    continent                   VARCHAR,
    population                  BIGINT,
    human_development_index     DOUBLE,
    start_date                  DATE,
    end_date                    DATE,
    is_current                  BOOLEAN
);

-- Dimensão de fase da pandemia
CREATE OR REPLACE TABLE dim_pandemic_phase (
    phase_key       INTEGER PRIMARY KEY,
    phase_name      VARCHAR,
    phase_order     INTEGER,
    description     VARCHAR
);

-- Tabela fato
CREATE OR REPLACE TABLE fact_covid (
    fact_key            INTEGER PRIMARY KEY,
    date_key            INTEGER REFERENCES dim_date(date_key),
    location_key        INTEGER REFERENCES dim_location(location_key),
    phase_key           INTEGER REFERENCES dim_pandemic_phase(phase_key),
    new_cases           DOUBLE,
    new_deaths          DOUBLE,
    total_cases         DOUBLE,
    total_deaths        DOUBLE,
    new_vaccinations    DOUBLE,
    total_vaccinations  DOUBLE,
    people_vaccinated   DOUBLE,
    reproduction_rate   DOUBLE,
    hosp_patients       DOUBLE
);

-- Verificação: lista as tabelas criadas
SHOW TABLES;