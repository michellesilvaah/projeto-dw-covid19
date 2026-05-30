# Evolução da Pandemia de COVID-19 no Brasil
### Disciplina: Banco e Armazém de Dados
**Professor:** Rafael Gross  
**Grupo:** Mariana Costa de Mello, Michelle de Sales Silva, Natan Bernardo Novais de Melo, Stephan Lucca

---

## Descrição
Data Warehouse para análise da evolução da pandemia de COVID-19 no Brasil,
construído com DuckDB a partir do dataset público da Our World in Data (OWID).

## Pré-requisitos
- Python 3.x
- DuckDB: `pip install duckdb`

## Como executar
1. Clone o repositório:
git clone https://github.com/SEU_USUARIO/projeto-dw-covid19.git
cd projeto-dw-covid19

2. Coloque o arquivo `owid-covid-data.csv` dentro da pasta `data/`
3. Execute todos os scripts na ordem correta:
python run_all.py

## Estrutura do projeto

projeto-dw-covid19/
├── data/                → Dataset CSV
├── scripts/             → Scripts SQL numerados
│   ├── 00_staging.sql   → View do CSV bruto
│   ├── 01_oltp.sql      → Tabelas normalizadas
│   └── 02_dw_model.sql  → Estrutura do DW
├── visualizacoes/       → Gráficos e dashboards
├── docs/                → Diagrama e dicionário de dados
├── run_all.py           → Executa todos os scripts
└── README.md            → Este arquivo

## Dataset
- **Fonte:** Our World in Data (OWID)
- **URL:** https://github.com/owid/covid-19-data/tree/master/public/data
- **Arquivo:** owid-covid-data.csv
- **Cobertura:** Janeiro 2020 – 2024
- **Volume:** +300.000 registros
