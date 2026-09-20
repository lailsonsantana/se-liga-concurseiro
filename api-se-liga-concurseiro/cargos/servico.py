from flask import Flask
from flask_cors import CORS

from dados.banco import consultar
from dados.http import registrar_tratamento_de_erros, resposta_sucesso
from dados.sql import SQL_CARGO

servico = Flask(__name__)
CORS(servico)
registrar_tratamento_de_erros(servico)

DESCRICAO = "serviço de gerenciamento de cargos e vagas para concursos públicos"
VERSAO = "1.0"

@servico.get("/")
def get_info():
    return resposta_sucesso({"descricao": DESCRICAO, "versao": VERSAO})

@servico.get("/cargos")
def get_cargos():
    return resposta_sucesso(consultar(SQL_CARGO))

@servico.get("/cargos/concurso/<int:id_concurso>")
def get_cargos_por_id_concurso(id_concurso):
    cargos = consultar(
        f"{SQL_CARGO} WHERE concurso_id = %s",
        (id_concurso,)
    )
    return resposta_sucesso(cargos)

@servico.get("/cargos/concurso/<string:orgao>")
def get_cargos_por_orgao_concurso(orgao):
    cargos = consultar(
        f"{SQL_CARGO} WHERE lower(orgao_concurso) LIKE %s",
        (f"%{orgao.lower()}%",)
    )
    return resposta_sucesso(cargos)

@servico.get("/cargos/nome/<string:nome>")
def get_cargos_por_nome(nome):
    cargos = consultar(
        f"{SQL_CARGO} WHERE lower(nome) LIKE %s",
        (f"%{nome.lower()}%",)
    )
    return resposta_sucesso(cargos)

if __name__ == "__main__":
    servico.run(host="0.0.0.0", debug=True)
