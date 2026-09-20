from flask import Flask, jsonify, make_response
import psycopg as dados
from psycopg.rows import dict_row as dicionario
from flask_cors import CORS

servico = Flask("cronogramas")
CORS(servico)

DESCRICAO = "serviço para gerenciamento dos cronogramas dos concursos"
VERSAO = "1.0"

SERVIDOR_BANCO = "dados"
PORTA_BANCO = 5432
USUARIO_BANCO = "admin"
SENHA_BANCO = "admin"
NOME_BANCO = "seligaconcurseiro"

def get_conexao_com_bd():
    conexao = dados.connect(
        host = SERVIDOR_BANCO,
        port = PORTA_BANCO,
        user = USUARIO_BANCO,
        password = SENHA_BANCO,
        dbname = NOME_BANCO,
        row_factory = dicionario
    )

    return conexao

@servico.get("/")
def get_info():
    return make_response(jsonify(descricao = DESCRICAO, versao = VERSAO), 200)

@servico.get("/cronogramas")
def get_cronogramas():
    cronogramas = []

    conexao = get_conexao_com_bd()
    cursor = conexao.cursor()
    cursor.execute(
    """
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
)
    
    cronogramas = cursor.fetchall()
    
    cronogramas = jsonify(cronogramas)

    conexao.close()

    return make_response(cronogramas, 200)

@servico.get("/cronogramas/concurso/<int:id_concurso>")
def get_cronogramas_por_id_concurso(id_concurso):
    cronogramas = []

    conexao = get_conexao_com_bd()
    cursor = conexao.cursor()
    cursor.execute(
    """
    SELECT 
        concurso_id,
        orgao_concurso AS orgao,
        solicitado,
        autorizado,
        edital_publicado,
        isencao_taxa,
        inscricoes_abertas AS data_inicio_inscricoes
    FROM DB_CRONOGRAMA
    WHERE concurso_id = %s
    """, (id_concurso,)
)
    
    cronogramas = cursor.fetchall()
    cronogramas = jsonify(cronogramas)

    conexao.close()

    return make_response(cronogramas, 200)

@servico.get("/cronogramas/orgao/<string:orgao>")
def get_cronogramas_por_orgao(orgao):
    cronogramas = []

    conexao = get_conexao_com_bd()
    cursor = conexao.cursor()
    cursor.execute(
    """
    SELECT 
        concurso_id,
        orgao_concurso AS orgao,
        solicitado,
        autorizado,
        edital_publicado,
        isencao_taxa,
        inscricoes_abertas AS data_inicio_inscricoes
    FROM DB_CRONOGRAMA
    WHERE lower(orgao_concurso) LIKE %s
    """, (f"%{orgao.lower()}%",)
)
    
    cronogramas = cursor.fetchall()
    cronogramas = jsonify(cronogramas)

    conexao.close()

    return make_response(cronogramas, 200)

if __name__ == "__main__":
    servico.run(host="0.0.0.0", debug=True)