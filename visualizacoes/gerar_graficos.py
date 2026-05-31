
# Gerando os 4 gráficos do projeto COVID-19
# ============================================================

import duckdb
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import os

# Conecta ao banco (caminho correto para a raiz do projeto)
conn = duckdb.connect("covid_dw.duckdb")

# Cria pasta de saída se não existir
os.makedirs("visualizacoes", exist_ok=True)


# ------------------------------------------------------------
# GRÁFICO 1 — Linha: Evolução de casos e mortes no Brasil

df1 = conn.execute("""
    SELECT
        d.year || '-' || LPAD(CAST(d.month AS VARCHAR), 2, '0') AS ano_mes,
        SUM(f.new_cases)  AS casos_novos,
        SUM(f.new_deaths) AS mortes_novas
    FROM fact_covid f
    JOIN dim_date     d ON d.date_key     = f.date_key
    JOIN dim_location l ON l.location_key = f.location_key
    WHERE l.iso_code = 'BRA'
    GROUP BY d.year, d.month, ano_mes
    ORDER BY d.year, d.month
""").df()

fig1 = px.line(
    df1, x="ano_mes",
    y=["casos_novos", "mortes_novas"],
    title="Evolução Mensal de Casos e Mortes por COVID-19 no Brasil",
    labels={"ano_mes": "Mês", "value": "Quantidade", "variable": "Indicador"},
    color_discrete_map={"casos_novos": "#2E75B6", "mortes_novas": "#C00000"}
)
fig1.update_layout(xaxis_tickangle=-45)
fig1.write_image("visualizacoes/grafico1_evolucao_temporal.png")
print("Gráfico 1 gerado!")


# ------------------------------------------------------------
# GRÁFICO 2 — Barras: Top 10 meses com mais mortes no Brasil

df2 = conn.execute("""
    SELECT
        d.year || '-' || d.month_name AS periodo,
        SUM(f.new_deaths) AS total_mortes
    FROM fact_covid f
    JOIN dim_date     d ON d.date_key     = f.date_key
    JOIN dim_location l ON l.location_key = f.location_key
    WHERE l.iso_code = 'BRA'
    GROUP BY d.year, d.month, d.month_name, periodo
    ORDER BY total_mortes DESC
    LIMIT 10
""").df()

fig2 = px.bar(
    df2, x="periodo", y="total_mortes",
    title="Top 10 Meses com Maior Número de Mortes por COVID-19 no Brasil",
    labels={"periodo": "Período", "total_mortes": "Total de Mortes"},
    color="total_mortes",
    color_continuous_scale="Reds"
)
fig2.update_layout(xaxis_tickangle=-45)
fig2.write_image("visualizacoes/grafico2_top10_mortes.png")
print("Gráfico 2 gerado!")


# ------------------------------------------------------------
# GRÁFICO 3 — Mapa de Calor: Casos por mês e ano no Brasil

df3 = conn.execute("""
    SELECT
        d.year      AS ano,
        d.month     AS mes,
        SUM(f.new_cases) AS casos_novos
    FROM fact_covid f
    JOIN dim_date     d ON d.date_key     = f.date_key
    JOIN dim_location l ON l.location_key = f.location_key
    WHERE l.iso_code = 'BRA'
    GROUP BY d.year, d.month
    ORDER BY d.year, d.month
""").df()

df3_pivot = df3.pivot(index="ano", columns="mes", values="casos_novos")

fig3 = px.imshow(
    df3_pivot,
    title="Mapa de Calor — Casos Mensais por Ano no Brasil",
    labels={"x": "Mês", "y": "Ano", "color": "Casos Novos"},
    color_continuous_scale="Blues",
    aspect="auto"
)
fig3.write_image("visualizacoes/grafico3_mapa_calor.png")
print("Gráfico 3 gerado!")


# ------------------------------------------------------------
# GRÁFICO 4 — Dashboard: visão geral com múltiplos gráficos

df4 = conn.execute("""
    SELECT
        d.year || '-' || LPAD(CAST(d.month AS VARCHAR), 2, '0') AS ano_mes,
        d.year AS ano,
        d.month AS mes,
        SUM(f.new_cases)        AS casos_novos,
        SUM(f.new_deaths)       AS mortes_novas,
        MAX(f.people_vaccinated) AS pessoas_vacinadas,
        ROUND(SUM(f.new_deaths) / NULLIF(SUM(f.new_cases), 0) * 100, 4) AS taxa_mortalidade
    FROM fact_covid f
    JOIN dim_date     d ON d.date_key     = f.date_key
    JOIN dim_location l ON l.location_key = f.location_key
    WHERE l.iso_code = 'BRA'
    GROUP BY d.year, d.month, ano_mes
    ORDER BY d.year, d.month
""").df()

fig4 = make_subplots(
    rows=2, cols=2,
    subplot_titles=(
        "Casos Novos por Mês",
        "Mortes Novas por Mês",
        "Pessoas Vacinadas (acumulado)",
        "Taxa de Mortalidade (%)"
    )
)

fig4.add_trace(go.Scatter(x=df4["ano_mes"], y=df4["casos_novos"], mode="lines", name="Casos", line=dict(color="#2E75B6")), row=1, col=1)
fig4.add_trace(go.Scatter(x=df4["ano_mes"], y=df4["mortes_novas"], mode="lines", name="Mortes", line=dict(color="#C00000")), row=1, col=2)
fig4.add_trace(go.Scatter(x=df4["ano_mes"], y=df4["pessoas_vacinadas"], mode="lines", name="Vacinados", line=dict(color="#70AD47")), row=2, col=1)
fig4.add_trace(go.Scatter(x=df4["ano_mes"], y=df4["taxa_mortalidade"], mode="lines", name="Mortalidade %", line=dict(color="#ED7D31")), row=2, col=2)

fig4.update_layout(
    title_text="Dashboard COVID-19 Brasil — Visão Geral da Pandemia",
    showlegend=False,
    height=700
)

fig4.write_html("visualizacoes/dashboard_covid19.html")
fig4.write_image("visualizacoes/grafico4_dashboard.png")
print("Gráfico 4 gerado!")


conn.close()
print("\nTodos os gráficos gerados com sucesso!")