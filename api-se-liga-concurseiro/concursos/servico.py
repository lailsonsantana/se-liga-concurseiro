from flask import Flask, jsonify, make_response
import psycopg as dados
from psycopg.rows import dict_row as dicionario
from flask_cors import CORS

servico = Flask("concursos")
CORS(servico)

DESCRICAO = "serviço de gerenciamento de concursos"
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

@servico.get("/concursos")
def get_concursos():
    concursos = []

    conexao = get_conexao_com_bd()
    cursor = conexao.cursor()
    cursor.execute(
    """
    SELECT 
        co.id AS concurso_id,
        cr.orgao_concurso AS nome,
        co.orgao,
        co.banca,
        co.situacao_atual AS situacao
    FROM DB_CONCURSO co
    LEFT JOIN DB_CRONOGRAMA cr ON cr.concurso_id = co.id
    """
)

    concursos = cursor.fetchall()
    concursos = jsonify(concursos)

    conexao.close()

    return make_response(concursos, 200)

@servico.get("/concursos/<int:id_concurso>")
def get_concurso_por_id(id_concurso):
    concursos = []

    conexao = get_conexao_com_bd()
    cursor = conexao.cursor()
    cursor.execute(
    """
    SELECT 
        co.id AS concurso_id,
        cr.orgao_concurso AS nome,
        co.orgao,
        co.banca,
        co.situacao_atual AS situacao
    FROM DB_CONCURSO co
    LEFT JOIN DB_CRONOGRAMA cr ON cr.concurso_id = co.id
    WHERE co.id = %s
    """, (id_concurso,)
    )
    
    concursos = cursor.fetchall()
    concursos = jsonify(concursos)

    conexao.close()

    return make_response(concursos, 200)

@servico.get("/concursos/orgao/<string:orgao>")
def get_concursos_por_orgao(orgao):
    concursos = []

    conexao = get_conexao_com_bd()
    cursor = conexao.cursor()
    cursor.execute(
    """
    SELECT 
        id AS concurso_id,
        orgao,
        cidade,
        estado,
        banca,
        situacao_atual
    FROM DB_CONCURSO
    WHERE lower(orgao) LIKE %s
    """, (f"%{orgao.lower()}%",)
)
    
    concursos = cursor.fetchall()
    concursos = jsonify(concursos)

    conexao.close()

    return make_response(concursos, 200)

if __name__ == "__main__":
    servico.run(host="0.0.0.0", debug=True)
