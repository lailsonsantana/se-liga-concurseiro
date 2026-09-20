import os

from dotenv import load_dotenv

load_dotenv()

SERVIDOR_BANCO = os.getenv("DB_HOST", "dados")
PORTA_BANCO = int(os.getenv("DB_PORT", "5432"))
USUARIO_BANCO = os.getenv("DB_USER", "admin")
SENHA_BANCO = os.getenv("DB_PASSWORD")
NOME_BANCO = os.getenv("DB_NAME", "seligaconcurseiro")

if not SENHA_BANCO:
    raise RuntimeError("A variável de ambiente DB_PASSWORD não foi configurada.")
