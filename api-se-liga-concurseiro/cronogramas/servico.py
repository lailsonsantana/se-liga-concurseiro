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
from dados.sql import SQL_CRONOGRAMA

servico = Flask("cronogramas")
CORS(servico)

DESCRICAO = "serviço para gerenciamento dos cronogramas dos concursos"
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

@servico.get("/cronogramas")
def get_cronogramas():
    conexao = get_conexao_com_bd()
    cursor = conexao.cursor()
    cursor.execute(SQL_CRONOGRAMA)
    
    cronogramas = cursor.fetchall()
    
    cronogramas = jsonify(cronogramas)

    conexao.close()

    return make_response(cronogramas, 200)

@servico.get("/cronogramas/concurso/<int:id_concurso>")
def get_cronogramas_por_id_concurso(id_concurso):
    conexao = get_conexao_com_bd()
    cursor = conexao.cursor()
    cursor.execute(
        f"{SQL_CRONOGRAMA} WHERE concurso_id = %s",
        (id_concurso,)
    )
    
    cronogramas = cursor.fetchall()
    cronogramas = jsonify(cronogramas)

    conexao.close()

    return make_response(cronogramas, 200)

@servico.get("/cronogramas/orgao/<string:orgao>")
def get_cronogramas_por_orgao(orgao):
    conexao = get_conexao_com_bd()
    cursor = conexao.cursor()
    cursor.execute(
        f"{SQL_CRONOGRAMA} WHERE lower(orgao_concurso) LIKE %s",
        (f"%{orgao.lower()}%",)
    )
    
    cronogramas = cursor.fetchall()
    cronogramas = jsonify(cronogramas)

    conexao.close()

    return make_response(cronogramas, 200)

if __name__ == "__main__":
    servico.run(host="0.0.0.0", debug=True)