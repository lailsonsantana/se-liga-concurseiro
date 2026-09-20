SQL_CONCURSO = """
SELECT
    id,
    orgao,
    cidade,
    estado,
    banca,
    situacao_atual
FROM DB_CONCURSO
"""

SQL_CARGO = """
SELECT
    id AS cargo_id,
    nome,
    concurso_id,
    orgao_concurso,
    carga_horaria,
    salario,
    quantidade_vagas_previstas,
    quantidade_vagas_imediatas,
    quantidade_vagas_cadastro_reserva,
    quantidade_vagas_negros,
    quantidade_vagas_pcd
FROM DB_CARGOS
"""

SQL_CRONOGRAMA = """
SELECT
    concurso_id,
    orgao_concurso AS orgao,
    solicitado,
    autorizado,
    edital_publicado,
    isencao_taxa,
    inscricoes_abertas AS data_inicio_inscricoes
FROM DB_CRONOGRAMA
"""
