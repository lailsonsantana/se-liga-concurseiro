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
from dados.sql import SQL_CARGO

servico = Flask("cargos")
CORS(servico)

DESCRICAO = "serviço de gerenciamento de cargos e vagas para concursos públicos"
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

@servico.get("/cargos")
def get_cargos():
    conexao = get_conexao_com_bd()
    cursor = conexao.cursor()
    cursor.execute(SQL_CARGO)

    cargos = cursor.fetchall()
    cargos = jsonify(cargos)

    conexao.close()

    return make_response(cargos, 200)

@servico.get("/cargos/concurso/<int:id_concurso>")
def get_cargos_por_id_concurso(id_concurso):
    conexao = get_conexao_com_bd()
    cursor = conexao.cursor()
    cursor.execute(
        f"{SQL_CARGO} WHERE concurso_id = %s",
        (id_concurso,)
    )
    
    cargos = cursor.fetchall()
    cargos = jsonify(cargos)

    conexao.close()

    return make_response(cargos, 200)

@servico.get("/cargos/concurso/<string:orgao>")
def get_cargos_por_orgao_concurso(orgao):
    conexao = get_conexao_com_bd()
    cursor = conexao.cursor()
    cursor.execute(
        f"{SQL_CARGO} WHERE lower(orgao_concurso) LIKE %s",
        (f"%{orgao.lower()}%",)
    )
    
    cargos = cursor.fetchall()
    cargos = jsonify(cargos)

    conexao.close()

    return make_response(cargos, 200)

@servico.get("/cargos/nome/<string:nome>")
def get_cargos_por_nome(nome):
    conexao = get_conexao_com_bd()
    cursor = conexao.cursor()
    cursor.execute(
        f"{SQL_CARGO} WHERE lower(nome) LIKE %s",
        (f"%{nome.lower()}%",)
    )
    
    cargos = cursor.fetchall()
    cargos = jsonify(cargos)

    conexao.close()

    return make_response(cargos, 200)

if __name__ == "__main__":
    servico.run(host="0.0.0.0", debug=True)