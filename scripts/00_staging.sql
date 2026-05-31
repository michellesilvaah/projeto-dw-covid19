
-- Lê o arquivo CSV e cria uma view de staging
-- Nenhuma transformação é feita aqui
-- ============================================================

-- View principal apontando para o CSV bruto
CREATE OR REPLACE VIEW stg_covid AS
SELECT *
FROM read_csv_auto(
    'data/owid-covid-data.csv',
    header = true,
    nullstr = ''
);

-- Verificação: mostra as primeiras 5 linhas
SELECT * FROM stg_covid LIMIT 5;

