from flask import Flask, jsonify, make_response
import psycopg as dados
from psycopg.rows import dict_row as dicionario
from flask_cors import CORS

from dados.configuracao import (
    NOME_BANCO,
    PORTA_BANCO,
    SENHA_BANCO,
    SERVIDOR_BANCO,
    USUARIO_BANCO,
)
from dados.sql import SQL_CONCURSO

servico = Flask("concursos")
CORS(servico)

DESCRICAO = "serviço de gerenciamento de concursos"
VERSAO = "1.0"

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
    conexao = get_conexao_com_bd()
    cursor = conexao.cursor()
    cursor.execute(SQL_CONCURSO)

    concursos = cursor.fetchall()
    concursos = jsonify(concursos)

    conexao.close()

    return make_response(concursos, 200)

@servico.get("/concursos/<int:id_concurso>")
def get_concurso_por_id(id_concurso):
    conexao = get_conexao_com_bd()
    cursor = conexao.cursor()
    cursor.execute(f"{SQL_CONCURSO} WHERE id = %s", (id_concurso,))
    
    concursos = cursor.fetchall()
    concursos = jsonify(concursos)

    conexao.close()

    return make_response(concursos, 200)

@servico.get("/concursos/orgao/<string:orgao>")
def get_concursos_por_orgao(orgao):
    conexao = get_conexao_com_bd()
    cursor = conexao.cursor()
    cursor.execute(
        f"{SQL_CONCURSO} WHERE lower(orgao) LIKE %s",
        (f"%{orgao.lower()}%",)
    )
    
    concursos = cursor.fetchall()
    concursos = jsonify(concursos)

    conexao.close()

    return make_response(concursos, 200)

if __name__ == "__main__":
    servico.run(host="0.0.0.0", debug=True)