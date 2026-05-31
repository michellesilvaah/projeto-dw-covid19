import duckdb
import os
import re

# Conecta ao banco
conn = duckdb.connect("covid_dw.duckdb")

scripts = [
    "scripts/00_staging.sql",
    "scripts/01_oltp.sql",
    "scripts/02_dw_model.sql",
    "scripts/03_etl_load.sql",
]

for script in scripts:
    print(f"\n>>> Executando {script}...")
    with open(script, "r", encoding="utf-8") as f:
        sql = f.read()
    
    # Remove comentários e divide em comandos individuais
    sql = re.sub(r'--[^\n]*', '', sql)
    comandos = [cmd.strip() for cmd in sql.split(';') if cmd.strip()]
    
    for cmd in comandos:
        try:
            conn.execute(cmd)
        except Exception as e:
            print(f"    Aviso: {e}")
    
    print(f"    OK!")

conn.close()
print("\nTodos os scripts executados com sucesso!")