from flask import Flask
from flask_cors import CORS

from dados.banco import consultar
from dados.http import registrar_tratamento_de_erros, resposta_sucesso
from dados.sql import SQL_CRONOGRAMA

servico = Flask(__name__)
CORS(servico)
registrar_tratamento_de_erros(servico)

DESCRICAO = "serviço para gerenciamento dos cronogramas dos concursos"
VERSAO = "1.0"

@servico.get("/")
def get_info():
    return resposta_sucesso({"descricao": DESCRICAO, "versao": VERSAO})

@servico.get("/cronogramas")
def get_cronogramas():
    return resposta_sucesso(consultar(SQL_CRONOGRAMA))

@servico.get("/cronogramas/concurso/<int:id_concurso>")
def get_cronogramas_por_id_concurso(id_concurso):
    cronogramas = consultar(
        f"{SQL_CRONOGRAMA} WHERE concurso_id = %s",
        (id_concurso,)
    )
    return resposta_sucesso(cronogramas)

@servico.get("/cronogramas/orgao/<string:orgao>")
def get_cronogramas_por_orgao(orgao):
    cronogramas = consultar(
        f"{SQL_CRONOGRAMA} WHERE lower(orgao_concurso) LIKE %s",
        (f"%{orgao.lower()}%",)
    )
    return resposta_sucesso(cronogramas)

if __name__ == "__main__":
    servico.run(host="0.0.0.0", debug=True)
