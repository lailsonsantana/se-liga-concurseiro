from flask import Flask
from flask_cors import CORS

from dados.banco import consultar
from dados.http import registrar_tratamento_de_erros, resposta_erro, resposta_sucesso
from dados.sql import SQL_CONCURSO

servico = Flask(__name__)
CORS(servico)
registrar_tratamento_de_erros(servico)

DESCRICAO = "serviço de gerenciamento de concursos"
VERSAO = "1.0"

@servico.get("/")
def get_info():
    return resposta_sucesso({"descricao": DESCRICAO, "versao": VERSAO})

@servico.get("/concursos")
def get_concursos():
    return resposta_sucesso(consultar(SQL_CONCURSO))

@servico.get("/concursos/<int:id_concurso>")
def get_concurso_por_id(id_concurso):
    concursos = consultar(f"{SQL_CONCURSO} WHERE id = %s", (id_concurso,))
    if not concursos:
        return resposta_erro(
            404,
            "Concurso não encontrado",
            f"Não existe concurso cadastrado com o id {id_concurso}.",
        )
    return resposta_sucesso(concursos[0])

@servico.get("/concursos/orgao/<string:orgao>")
def get_concursos_por_orgao(orgao):
    concursos = consultar(
        f"{SQL_CONCURSO} WHERE lower(orgao) LIKE %s",
        (f"%{orgao.lower()}%",)
    )
    return resposta_sucesso(concursos)

if __name__ == "__main__":
    servico.run(host="0.0.0.0", debug=True)
