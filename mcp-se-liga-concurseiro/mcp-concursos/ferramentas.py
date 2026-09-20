from mcp.server.mcpserver import MCPServer
import urllib.request as requisicao
from urllib.parse import quote

NOME = "concursos"
mcp = MCPServer(NOME)

URL_CONCURSOS = "http://concursos:5000/concursos"

INFO = {
    "nome": NOME,
    "descricao": "Serviço MCP de concursos.",
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
    title="Informações sobre o serviço de concursos",
    description=(
        "Verifica se o serviço de concursos está acessível e respondendo. "
        "Use esta ferramenta para distinguir uma indisponibilidade do serviço de "
        "uma busca que simplesmente não encontrou nada, ou para descobrir qual "
        "serviço está respondendo.\n"
        "\n"
        "Retorna:\n"
        "    O nome e a descrição do serviço, como "
        '{"nome": "concursos", "descricao": "Serviço MCP de concursos."}.'
    )
)
def get_info():
    return INFO


@mcp.tool(
    name="concursos",
    title="Lista de concursos públicos",
    description=(
        "Lista todos os concursos públicos cadastrados no sistema.\n"
        "\n"
        "Retorna os concursos sem nenhum filtro. Use esta ferramenta para "
        "conhecer o catálogo completo ou quando o usuário não indicar nenhum "
        "critério de busca; use concursos_por_orgao quando ele citar o órgão "
        "responsável e concurso_por_id quando já souber o identificador do "
        "concurso.\n"
        "Exemplos: 'quais concursos existem?', 'liste os concursos disponíveis', "
        "'mostre todos os concursos cadastrados'.\n"
        "\n"
        "Retorna:\n"
        "    Os concursos cadastrados, cada um com seu id, órgão, e demais dados "
        "do edital. Vazio quando não há nenhum concurso cadastrado."
    )
)
def get_concursos():
    sucesso, conteudo, erro = acessar(URL_CONCURSOS)
    if sucesso:
        return conteudo
    else:
        return {"erro": "Não foi possível acessar o serviço de concursos."}


@mcp.tool(
    name="concurso_por_id",
    title="Buscar concurso por ID",
    description=(
        "Recupera um único concurso público a partir do seu identificador (ID).\n"
        "\n"
        "O id é uma correspondência exata, portanto identifica no máximo um "
        "concurso. Use esta ferramenta quando o usuário informar o número do "
        "concurso ou quando um id já tiver aparecido em uma consulta anterior; "
        "use concursos_por_orgao quando ele citar apenas o nome do órgão e "
        "concursos para listar todos.\n"
        "Exemplos: 'mostre o concurso 10', 'detalhes do concurso de ID 25', "
        "'quais são as informações do concurso 8?'.\n"
        "\n"
        "Args:\n"
        "    id_concurso: Identificador numérico do concurso, como 10.\n"
        "\n"
        "Retorna:\n"
        "    O concurso correspondente, com seu id, órgão e demais dados do "
        "edital. Vazio quando não existe concurso com esse id."
    )
)
def get_concurso_por_id(id_concurso):
    sucesso, conteudo, erro = acessar(f"{URL_CONCURSOS}/{id_concurso}")
    if sucesso:
        return conteudo
    else:
        return {"erro": "Não foi possível acessar o serviço de concursos."}


@mcp.tool(
    name="concursos_por_orgao",
    title="Buscar concursos por órgão",
    description=(
        "Busca concursos públicos pelo órgão ou instituição responsável.\n"
        "\n"
        "O filtro procura pelo nome do órgão informado, como 'INSS', 'Polícia "
        "Federal' ou 'Prefeitura de Salvador'. Use esta ferramenta quando o "
        "usuário citar a instituição promotora do concurso; use concurso_por_id "
        "quando ele informar o identificador e concursos para listar todos os "
        "concursos sem filtro.\n"
        "Exemplos: 'quais concursos do INSS estão abertos?', "
        "'mostre os concursos da Polícia Federal', "
        "'existe concurso da Prefeitura de Salvador?'.\n"
        "\n"
        "Args:\n"
        "    orgao: Nome do órgão responsável pelo concurso, como 'INSS'.\n"
        "\n"
        "Retorna:\n"
        "    Os concursos do órgão informado, cada um com seu id, órgão e demais "
        "dados do edital. Vazio quando nenhum concurso corresponde ao órgão."
    )
)
def get_concursos_por_orgao(orgao):
    sucesso, conteudo, erro = acessar(f"{URL_CONCURSOS}/orgao/{quote(orgao)}")
    if sucesso:
        return conteudo
    else:
        return {"erro": "Não foi possível acessar o serviço de concursos."}


if __name__ == "__main__":
    mcp.run(transport="streamable-http", streamable_http_path="/mcp", host="0.0.0.0")
