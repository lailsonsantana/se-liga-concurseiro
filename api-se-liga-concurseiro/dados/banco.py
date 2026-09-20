import psycopg as dados
from psycopg.rows import dict_row as dicionario

from dados.configuracao import (
    NOME_BANCO,
    PORTA_BANCO,
    SENHA_BANCO,
    SERVIDOR_BANCO,
    USUARIO_BANCO,
)


def consultar(sql, parametros=()):
    with dados.connect(
        host=SERVIDOR_BANCO,
        port=PORTA_BANCO,
        user=USUARIO_BANCO,
        password=SENHA_BANCO,
        dbname=NOME_BANCO,
        row_factory=dicionario,
    ) as conexao:
        with conexao.cursor() as cursor:
            cursor.execute(sql, parametros)
            return cursor.fetchall()
