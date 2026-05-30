import duckdb
import os

# Conecta ao banco (cria o arquivo covid_dw.duckdb na raiz do projeto)
conn = duckdb.connect("covid_dw.duckdb")

scripts = [
    "scripts/00_staging.sql",
    "scripts/01_oltp.sql",
    "scripts/02_dw_model.sql",
]

for script in scripts:
    print(f"\n>>> Executando {script}...")
    with open(script, "r", encoding="utf-8") as f:
        sql = f.read()
    conn.execute(sql)
    print(f"    OK!")

conn.close()
print("\nTodos os scripts executados com sucesso!")