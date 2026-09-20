from flask import jsonify, request
from werkzeug.exceptions import HTTPException

import psycopg


def resposta_sucesso(dados, status=200):
    return jsonify(dados), status


def resposta_erro(status, titulo, detalhe, tipo="about:blank"):
    resposta = jsonify(
        type=tipo,
        title=titulo,
        status=status,
        detail=detalhe,
        instance=request.path,
    )
    resposta.status_code = status
    resposta.content_type = "application/problem+json"
    return resposta


def registrar_tratamento_de_erros(servico):
    @servico.errorhandler(HTTPException)
    def tratar_erro_http(erro):
        return resposta_erro(
            erro.code or 500,
            erro.name,
            erro.description,
        )

    @servico.errorhandler(psycopg.Error)
    def tratar_erro_banco(erro):
        servico.logger.exception("Erro ao acessar o banco de dados")
        return resposta_erro(
            503,
            "Serviço indisponível",
            "Não foi possível acessar os dados no momento.",
            "https://httpstatuses.com/503",
        )

    @servico.errorhandler(Exception)
    def tratar_erro_interno(erro):
        servico.logger.exception("Erro interno não tratado")
        return resposta_erro(
            500,
            "Erro interno do servidor",
            "Ocorreu um erro inesperado ao processar a solicitação.",
            "https://httpstatuses.com/500",
        )
