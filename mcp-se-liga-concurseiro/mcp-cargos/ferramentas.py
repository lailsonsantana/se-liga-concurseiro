from mcp.server.mcpserver import MCPServer
import urllib.request as requisicao
from urllib.parse import quote

NOME = "cargos"
mcp = MCPServer(NOME)

URL_CARGOS = "http://cargos:5000/cargos"

INFO = {
    "nome": NOME,
    "descricao": "Serviço MCP de cargos.",
}

def acessar(url):
    sucesso, conteudo, erro = False, None, None

    try:
        resposta = requisicao.urlopen(url)
        if resposta.code == 200:
            sucesso = True
            conteudo = resposta.read().decode("utf-8")
    except Exception as e:
        print(f"Erro ao acessar {url}: {e}")

    return sucesso, conteudo, erro


@mcp.tool(
    name="informacoes",
    title="Informações sobre o serviço de cargos",
    description=(
        "Verifica se o serviço de cargos está acessível e respondendo. "
        "Use esta ferramenta para distinguir uma indisponibilidade do serviço de "
        "uma busca que simplesmente não encontrou nada, ou para descobrir qual "
        "serviço está respondendo.\n"
        "\n"
        "Retorna:\n"
        "    O nome e a descrição do serviço, como "
        '{"nome": "cargos", "descricao": "Serviço MCP de cargos."}.'
    )
)
def get_info():
    return INFO


@mcp.tool(
    name="cargos",
    title="Lista de cargos públicos",
    description=(
        "Lista todos os cargos públicos cadastrados no sistema.\n"
        "\n"
        "Retorna os cargos sem nenhum filtro. Use esta ferramenta para conhecer "
        "o catálogo completo de cargos ou quando o usuário não indicar nenhum "
        "critério; use cargos_por_nome quando ele citar o nome do cargo e "
        "cargos_por_id_concurso quando quiser os cargos de um concurso "
        "específico.\n"
        "Exemplos: 'quais cargos existem?', 'liste os cargos disponíveis', "
        "'quais cargos públicos estão cadastrados?'.\n"
        "\n"
        "Retorna:\n"
        "    Os cargos cadastrados, cada um com seu id, nome, o id do concurso a "
        "que pertence e demais dados, como vagas e requisitos. Vazio quando não "
        "há nenhum cargo cadastrado."
    )
)
def get_cargos():
    sucesso, conteudo, erro = acessar(URL_CARGOS)

    if sucesso:
        return conteudo
    else:
        return {"erro": "Não foi possível acessar o serviço de cargos."}


@mcp.tool(
    name="cargos_por_id_concurso",
    title="Buscar cargos de um concurso por ID",
    description=(
        "Lista os cargos oferecidos por um concurso público, a partir do "
        "identificador (ID) do concurso.\n"
        "\n"
        "O id_concurso é uma correspondência exata e filtra apenas os cargos "
        "vinculados àquele concurso. Use esta ferramenta quando o usuário "
        "informar o número do concurso e quiser saber quais cargos, funções ou "
        "vagas ele oferece; quando ele citar apenas o nome do concurso ou do "
        "órgão, obtenha antes o id com a ferramenta de concursos. Use "
        "cargos_por_nome quando a busca for pelo nome do cargo.\n"
        "Exemplos: 'quais cargos existem no concurso 10?', "
        "'mostre os cargos do concurso de ID 25', "
        "'quais vagas o concurso 8 oferece?'.\n"
        "\n"
        "Args:\n"
        "    id_concurso: Identificador numérico do concurso, como 10.\n"
        "\n"
        "Retorna:\n"
        "    Os cargos do concurso informado, cada um com seu id, nome, o id do "
        "concurso e demais dados, como vagas e requisitos. Vazio quando o "
        "concurso não existe ou não possui cargos cadastrados."
    )
)
def get_cargos_por_id_concurso(id_concurso):
    sucesso, conteudo, erro = acessar(f"{URL_CARGOS}/concurso/{id_concurso}")

    if sucesso:
        return conteudo
    else:
        return {"erro": "Não foi possível acessar o serviço de cargos."}


@mcp.tool(
    name="cargos_por_nome",
    title="Buscar cargo por nome",
    description=(
        "Busca cargos públicos pelo nome do cargo, função ou carreira.\n"
        "\n"
        "O filtro procura pelo termo informado no nome do cargo, como 'Analista' "
        "ou 'Técnico', e pode retornar mais de um cargo, inclusive de concursos "
        "diferentes. Use esta ferramenta quando o usuário descrever o cargo pelo "
        "nome; use cargos_por_id_concurso quando ele indicar o concurso e cargos "
        "para listar todos sem filtro.\n"
        "Exemplos: 'encontre o cargo de Analista', "
        "'quais cargos possuem o nome Técnico?', 'existe o cargo de Professor?'.\n"
        "\n"
        "Args:\n"
        "    nome: Texto a procurar no nome do cargo, como 'Analista'.\n"
        "\n"
        "Retorna:\n"
        "    Os cargos correspondentes, cada um com seu id, nome, o id do "
        "concurso a que pertence e demais dados, como vagas e requisitos. Vazio "
        "quando nenhum cargo corresponde ao nome."
    )
)
def get_cargos_por_nome(nome):
    sucesso, conteudo, erro = acessar(f"{URL_CARGOS}/nome/{quote(nome)}")

    if sucesso:
        return conteudo
    else:
        return {"erro": "Não foi possível acessar o serviço de cargos."}


if __name__ == "__main__":
    mcp.run(transport="streamable-http", streamable_http_path="/mcp", host="0.0.0.0")
