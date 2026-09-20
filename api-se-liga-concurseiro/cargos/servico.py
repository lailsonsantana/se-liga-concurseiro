from flask import Flask, jsonify, make_response
import psycopg as dados
from psycopg.rows import dict_row as dicionario
from flask_cors import CORS

servico = Flask("cargos")
CORS(servico)

DESCRICAO = "serviço de gerenciamento de cargos e vagas para concursos públicos"
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

@servico.get("/cargos")
def get_cargos():
    cargos = []
    
    conexao = get_conexao_com_bd()
    cursor = conexao.cursor()
    cursor.execute(
    """
    SELECT 
        c.id AS cargo_id,
        c.nome,
        c.concurso_id,
        c.orgao_concurso,
        c.carga_horaria,
        c.salario,
        c.quantidade_vagas_previstas,
        c.quantidade_vagas_imediatas,
        c.quantidade_vagas_cadastro_reserva,
        c.quantidade_vagas_negros,
        c.quantidade_vagas_pcd
    FROM DB_CARGOS c
    """
    )

    cargos = cursor.fetchall()
    cargos = jsonify(cargos)

    conexao.close()

    return make_response(cargos, 200)

@servico.get("/cargos/concurso/<int:id_concurso>")
def get_cargos_por_id_concurso(id_concurso):
    cargos = []

    conexao = get_conexao_com_bd()
    cursor = conexao.cursor()
    cursor.execute(
    """
    SELECT 
        id AS cargo_id,
        nome,
        concurso_id,
        orgao_concurso,
        salario,
        quantidade_vagas_previstas,
        quantidade_vagas_imediatas,
        quantidade_vagas_cadastro_reserva,
        quantidade_vagas_negros,
        quantidade_vagas_pcd
    FROM DB_CARGOS
    WHERE concurso_id = %s
    """, (id_concurso,)
)
    
    cargos = cursor.fetchall()
    cargos = jsonify(cargos)

    conexao.close()

    return make_response(cargos, 200)

@servico.get("/cargos/concurso/<string:orgao>")
def get_cargos_por_orgao_concurso(orgao):
    cargos = []

    conexao = get_conexao_com_bd()
    cursor = conexao.cursor()
    cursor.execute(
    """
    SELECT 
        id AS cargo_id,
        nome,
        concurso_id,
        orgao_concurso,
        salario,
        quantidade_vagas_previstas,
        quantidade_vagas_imediatas,
        quantidade_vagas_cadastro_reserva,
        quantidade_vagas_negros,
        quantidade_vagas_pcd
    FROM DB_CARGOS
    WHERE lower(orgao_concurso) LIKE %s
    """, (f"%{orgao.lower()}%",)
    )
    
    cargos = cursor.fetchall()
    cargos = jsonify(cargos)

    conexao.close()

    return make_response(cargos, 200)

@servico.get("/cargos/nome/<string:nome>")
def get_cargos_por_nome(nome):
    cargos = []

    conexao = get_conexao_com_bd()
    cursor = conexao.cursor()
    cursor.execute(
    """
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
    WHERE lower(nome) LIKE %s
    """, (f"%{nome.lower()}%",)
)
    
    cargos = cursor.fetchall()
    cargos = jsonify(cargos)

    conexao.close()

    return make_response(cargos, 200)

if __name__ == "__main__":
    servico.run(host="0.0.0.0", debug=True)