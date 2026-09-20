from mcp.server.mcpserver import MCPServer
import urllib.request as requisicao
from urllib.parse import quote

NOME = "cronogramas"
mcp = MCPServer(NOME)

URL_CRONOGRAMAS = "http://cronogramas:5000/cronogramas"

INFO = {
    "nome": NOME,
    "descricao": "Serviço MCP para os cronogramas dos concursos públicos.",
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
    title="Informações sobre o serviço de cronogramas",
    description=(
        "Verifica se o serviço de cronogramas está acessível e respondendo. "
        "Use esta ferramenta para distinguir uma indisponibilidade do serviço de "
        "uma busca que simplesmente não encontrou nada, ou para descobrir qual "
        "serviço está respondendo.\n"
        "\n"
        "Retorna:\n"
        "    O nome e a descrição do serviço, como "
        '{"nome": "cronogramas", "descricao": "Serviço MCP para os cronogramas '
        'dos concursos públicos."}.'
    )
)
def get_info():
    return INFO


@mcp.tool(
    name="cronogramas",
    title="Lista de cronogramas",
    description=(
        "Lista todos os cronogramas de concursos cadastrados no sistema.\n"
        "\n"
        "Retorna os cronogramas sem nenhum filtro, com as etapas e datas de "
        "todos os concursos. Use esta ferramenta para uma visão geral do "
        "calendário ou quando o usuário não indicar nenhum concurso; use "
        "cronogramas_por_id_concurso quando ele informar o id do concurso e "
        "cronogramas_por_orgao quando citar a instituição.\n"
        "Exemplos: 'liste os cronogramas', 'quais cronogramas estão "
        "disponíveis?', 'mostre todos os cronogramas'.\n"
        "\n"
        "Retorna:\n"
        "    Os cronogramas cadastrados, cada um com seu id, o id do concurso a "
        "que pertence e as etapas previstas com suas datas, como inscrição, "
        "prova, recursos e resultado. Vazio quando não há nenhum cronograma "
        "cadastrado."
    )
)
def get_cronogramas():
    sucesso, conteudo, erro = acessar(URL_CRONOGRAMAS)

    if sucesso:
        return conteudo
    else:
        return {"erro": "Não foi possível acessar o serviço de cronogramas."}


@mcp.tool(
    name="cronogramas_por_id_concurso",
    title="Buscar cronograma por ID do concurso",
    description=(
        "Recupera o cronograma de um concurso público a partir do identificador "
        "(ID) do concurso.\n"
        "\n"
        "O id_concurso é uma correspondência exata e devolve as etapas apenas "
        "daquele concurso. Use esta ferramenta quando o usuário informar o "
        "número do concurso e quiser saber datas de inscrição, prova, recursos "
        "ou resultado; quando ele citar apenas o nome do concurso, obtenha antes "
        "o id com a ferramenta de concursos. Use cronogramas_por_orgao quando a "
        "busca for pela instituição.\n"
        "Exemplos: 'mostre o cronograma do concurso 15', "
        "'qual é o cronograma do concurso de ID 8?', "
        "'quando será a prova do concurso 3?'.\n"
        "\n"
        "Args:\n"
        "    id_concurso: Identificador numérico do concurso, como 15.\n"
        "\n"
        "Retorna:\n"
        "    O cronograma do concurso informado, com seu id, o id do concurso e "
        "as etapas previstas com suas datas. Vazio quando o concurso não existe "
        "ou não possui cronograma cadastrado."
    )
)
def get_cronogramas_por_id_concurso(id_concurso):
    sucesso, conteudo, erro = acessar(f"{URL_CRONOGRAMAS}/concurso/{id_concurso}")

    if sucesso:
        return conteudo
    else:
        return {"erro": "Não foi possível acessar o serviço de cronogramas."}


@mcp.tool(
    name="cronogramas_por_orgao",
    title="Buscar cronogramas por órgão",
    description=(
        "Busca os cronogramas dos concursos vinculados a um órgão ou "
        "instituição.\n"
        "\n"
        "O filtro procura pelo nome do órgão informado, como 'INSS' ou "
        "'Prefeitura de Salvador', e pode devolver os cronogramas de vários "
        "concursos do mesmo órgão. Use esta ferramenta quando o usuário citar a "
        "instituição promotora; use cronogramas_por_id_concurso quando ele "
        "informar o id do concurso e cronogramas para listar todos sem filtro.\n"
        "Exemplos: 'mostre os cronogramas dos concursos do INSS', "
        "'quais são os cronogramas dos concursos da Polícia Federal?', "
        "'consulte os cronogramas dos concursos da Prefeitura de Salvador'.\n"
        "\n"
        "Args:\n"
        "    orgao: Nome do órgão responsável pelos concursos, como 'INSS'.\n"
        "\n"
        "Retorna:\n"
        "    Os cronogramas dos concursos do órgão informado, cada um com seu "
        "id, o id do concurso e as etapas previstas com suas datas. Vazio quando "
        "nenhum concurso do órgão possui cronograma cadastrado."
    )
)
def get_cronogramas_por_orgao(orgao):
    sucesso, conteudo, erro = acessar(f"{URL_CRONOGRAMAS}/orgao/{quote(orgao)}")

    if sucesso:
        return conteudo
    else:
        return {"erro": "Não foi possível acessar o serviço de cronogramas."}


if __name__ == "__main__":
    mcp.run(transport="streamable-http", streamable_http_path="/mcp", host="0.0.0.0")
