# Se Liga Concurseiro

Plataforma para consulta de informações sobre concursos públicos, composta por
serviços REST, servidores MCP e uma interface de conversa baseada no
[LibreChat](https://www.librechat.ai/).

O sistema consulta uma base PostgreSQL com dados de concursos, cargos, vagas e
cronogramas. Os servidores MCP disponibilizam essas consultas para clientes
compatíveis com o Model Context Protocol (MCP), como o LibreChat.

## Arquitetura

```text
LibreChat (http://localhost:3080)
    |
    +-- MCP Concursos    (http://localhost:9000/mcp)
    +-- MCP Cargos       (http://localhost:9001/mcp)
    +-- MCP Cronogramas  (http://localhost:9002/mcp)

MCP Concursos    ---> API Concursos    (http://localhost:8000) --\
MCP Cargos       ---> API Cargos       (http://localhost:8001) ---+--> PostgreSQL
MCP Cronogramas  ---> API Cronogramas  (http://localhost:8002) --/    (localhost:8003)
```

O fluxo de acesso aos dados é:

1. O LibreChat conversa com os servidores MCP.
2. Cada servidor MCP chama sua API REST correspondente.
3. As APIs REST consultam o PostgreSQL e devolvem os dados aos MCPs.
4. Os MCPs entregam os resultados ao LibreChat.

Os servidores MCP não acessam o banco de dados diretamente. O acesso ao
PostgreSQL é responsabilidade exclusiva das APIs REST.

Os serviços Docker usam a rede externa `rede-concursos`. Ela permite que:

- as APIs encontrem o PostgreSQL pelo hostname `dados`;
- os servidores MCP encontrem as APIs pelos hostnames `concursos`, `cargos` e
  `cronogramas`.

O LibreChat, executado no contêiner, acessa os MCPs publicados no host por
`host.docker.internal`.

## Requisitos

- Docker Engine ou Docker Desktop;
- Docker Compose v2;
- Git, caso o projeto seja clonado;
- uma chave de API do Google Gemini para o LibreChat.

Os comandos abaixo foram escritos para serem executados a partir da raiz do
projeto:

```text
SeLigaConcurseiro/
├── api-se-liga-concurseiro/
├── mcp-se-liga-concurseiro/
├── chat-se-liga-concurseiro/
└── README.md
```

## Configuração

### Banco de dados e API

Na pasta `api-se-liga-concurseiro`, crie o arquivo `.env` a partir do exemplo:

```powershell
Copy-Item .\api-se-liga-concurseiro\.env.example .\api-se-liga-concurseiro\.env
```

Edite o arquivo e configure as variáveis:

| Variável | Descrição | Valor usado no Compose |
|---|---|---|
| `DB_HOST` | Host do PostgreSQL | `dados` |
| `DB_PORT` | Porta interna do PostgreSQL | `5432` |
| `DB_USER` | Usuário do banco | `admin` |
| `DB_PASSWORD` | Senha do banco | Definida pelo operador |
| `DB_NAME` | Nome do banco | `seligaconcurseiro` |

O arquivo `.env` contém credenciais e não deve ser versionado.

### LibreChat

Na pasta `chat-se-liga-concurseiro`, crie ou edite o arquivo `.env` e informe a
chave do Google usada pelo endpoint configurado no Compose:

```dotenv
GOOGLE_KEY=sua-chave-do-google-gemini
```

Nunca publique essa chave no GitHub ou em outro repositório. O arquivo
`librechat.yaml` já está configurado para registrar os três servidores MCP:

- `concursos`;
- `cargos`;
- `cronogramas`.

O modelo disponibilizado no LibreChat é `gemini-3.5-flash-lite`, com acesso às
ferramentas dos três servidores.

## Inicialização completa com Docker

### 1. Criar a rede compartilhada

A rede é declarada como externa nos arquivos Compose e precisa existir antes da
subida dos serviços:

```powershell
docker network create rede-concursos
```

Se a rede já existir, o Docker informará isso; nesse caso, prossiga para o
próximo comando.

### 2. Iniciar a API e o PostgreSQL

```powershell
docker compose -f .\api-se-liga-concurseiro\docker-compose.yml up -d --build
```

Esse comando inicia:

- `dados`: PostgreSQL;
- `concursos`: API de concursos;
- `cargos`: API de cargos e vagas;
- `cronogramas`: API de cronogramas.

O script `seligaconcurseiro.sql` é executado automaticamente pelo PostgreSQL
quando o volume de dados é criado pela primeira vez.

### 3. Iniciar os servidores MCP

```powershell
docker compose -f .\mcp-se-liga-concurseiro\docker-compose.yml up -d --build
```

Esse comando publica:

| Servidor | Endpoint MCP | Porta no host |
|---|---|---:|
| Concursos | `http://localhost:9000/mcp` | `9000` |
| Cargos | `http://localhost:9001/mcp` | `9001` |
| Cronogramas | `http://localhost:9002/mcp` | `9002` |

### 4. Iniciar o LibreChat

```powershell
docker compose -f .\chat-se-liga-concurseiro\docker-compose.yml up -d
```

O LibreChat ficará disponível em:

```text
http://localhost:3080
```

Na primeira execução, aguarde o MongoDB e o LibreChat concluírem a
inicialização antes de acessar a página.

## Usando o LibreChat

1. Abra `http://localhost:3080` no navegador.
2. Crie uma conta caso o registro esteja habilitado.
3. Selecione o modelo `Gemini 3.5 Flash-Lite`.
4. Faça perguntas sobre concursos, cargos, vagas ou cronogramas.
5. O LibreChat selecionará as ferramentas MCP necessárias para consultar os
   dados.

Exemplos de perguntas:

```text
Quais concursos estão cadastrados?
Quais cargos existem no concurso 10?
Quais concursos estão relacionados ao órgão INSS?
Mostre o cronograma do concurso 15.
Quais são as etapas previstas para os concursos da Polícia Federal?
```

Os três servidores MCP também podem ser acessados por outros clientes
compatíveis com MCP usando os endpoints publicados nas portas `9000`, `9001` e
`9002`.

## Serviços REST disponíveis

### API de concursos — porta `8000`

Base URL:

```text
http://localhost:8000
```

| Método | Endpoint | Descrição |
|---|---|---|
| `GET` | `/` | Informações e versão do serviço |
| `GET` | `/concursos` | Lista todos os concursos |
| `GET` | `/concursos/{id}` | Busca um concurso por ID |
| `GET` | `/concursos/orgao/{orgao}` | Filtra concursos por órgão |

Exemplo:

```powershell
curl.exe http://localhost:8000/concursos
curl.exe http://localhost:8000/concursos/1
curl.exe http://localhost:8000/concursos/orgao/INSS
```

### API de cargos — porta `8001`

Base URL:

```text
http://localhost:8001
```

| Método | Endpoint | Descrição |
|---|---|---|
| `GET` | `/` | Informações e versão do serviço |
| `GET` | `/cargos` | Lista todos os cargos |
| `GET` | `/cargos/concurso/{id}` | Filtra cargos por concurso |
| `GET` | `/cargos/concurso/{orgao}` | Filtra cargos por órgão |
| `GET` | `/cargos/nome/{nome}` | Filtra cargos por nome |

Exemplo:

```powershell
curl.exe http://localhost:8001/cargos
curl.exe http://localhost:8001/cargos/concurso/1
curl.exe http://localhost:8001/cargos/nome/Analista
```

### API de cronogramas — porta `8002`

Base URL:

```text
http://localhost:8002
```

| Método | Endpoint | Descrição |
|---|---|---|
| `GET` | `/` | Informações e versão do serviço |
| `GET` | `/cronogramas` | Lista todos os cronogramas |
| `GET` | `/cronogramas/concurso/{id}` | Filtra por concurso |
| `GET` | `/cronogramas/orgao/{orgao}` | Filtra por órgão |

Exemplo:

```powershell
curl.exe http://localhost:8002/cronogramas
curl.exe http://localhost:8002/cronogramas/concurso/1
curl.exe http://localhost:8002/cronogramas/orgao/INSS
```

### Formato de erros

As APIs REST retornam erros no formato
[RFC 7807 Problem Details](https://www.rfc-editor.org/rfc/rfc7807):

```json
{
  "type": "about:blank",
  "title": "Concurso não encontrado",
  "status": 404,
  "detail": "Não existe concurso cadastrado com o id 99.",
  "instance": "/concursos/99"
}
```

Os servidores MCP repassam esse mesmo formato para os clientes MCP. Falhas de
conectividade com a API são representadas como `503 Service Unavailable`.

## Comandos Docker úteis

### Ver status dos contêineres

```powershell
docker ps
```

### Consultar logs

```powershell
docker compose -f .\api-se-liga-concurseiro\docker-compose.yml logs -f
docker compose -f .\mcp-se-liga-concurseiro\docker-compose.yml logs -f
docker compose -f .\chat-se-liga-concurseiro\docker-compose.yml logs -f
```

Para acompanhar apenas um serviço:

```powershell
docker compose -f .\api-se-liga-concurseiro\docker-compose.yml logs -f concursos
docker compose -f .\mcp-se-liga-concurseiro\docker-compose.yml logs -f concursos-mcp
docker compose -f .\chat-se-liga-concurseiro\docker-compose.yml logs -f librechat
```

### Parar os serviços

```powershell
docker compose -f .\chat-se-liga-concurseiro\docker-compose.yml down
docker compose -f .\mcp-se-liga-concurseiro\docker-compose.yml down
docker compose -f .\api-se-liga-concurseiro\docker-compose.yml down
```

### Recriar imagens e contêineres

```powershell
docker compose -f .\api-se-liga-concurseiro\docker-compose.yml up -d --build --force-recreate
docker compose -f .\mcp-se-liga-concurseiro\docker-compose.yml up -d --build --force-recreate
docker compose -f .\chat-se-liga-concurseiro\docker-compose.yml up -d --force-recreate
```

### Remover também os volumes do LibreChat

Este comando remove os dados persistidos do MongoDB do LibreChat, incluindo
contas e configurações armazenadas:

```powershell
docker compose -f .\chat-se-liga-concurseiro\docker-compose.yml down -v
```

Use `down -v` somente quando quiser realmente apagar esses dados.

## Solução de problemas

### Erro informando que `rede-concursos` não existe

Crie a rede manualmente:

```powershell
docker network create rede-concursos
```

### O LibreChat não encontra os servidores MCP

Confirme se:

1. os três contêineres MCP estão em execução com `docker ps`;
2. os endpoints respondem nas portas `9000`, `9001` e `9002`;
3. o arquivo `librechat.yaml` está montado no contêiner;
4. a API e os MCPs foram iniciados antes do LibreChat.

No Docker Desktop para Windows, `host.docker.internal` permite que o contêiner
do LibreChat alcance as portas MCP publicadas no host.

### A API não conecta ao PostgreSQL

Verifique se:

1. o contêiner `dados` está em execução;
2. o arquivo `api-se-liga-concurseiro/.env` existe;
3. `DB_HOST=dados` está configurado;
4. usuário, senha e nome do banco correspondem ao Compose;
5. os serviços estão conectados à rede `rede-concursos`.

### O banco não foi recriado com o SQL atualizado

O PostgreSQL executa scripts em `/docker-entrypoint-initdb.d` somente quando o
diretório de dados está vazio. Para recriar o banco em ambiente de
desenvolvimento:

```powershell
docker compose -f .\api-se-liga-concurseiro\docker-compose.yml down -v
docker compose -f .\api-se-liga-concurseiro\docker-compose.yml up -d --build
```

O uso de `-v` apaga os dados persistidos do PostgreSQL.

## Licença e segurança

Não armazene arquivos `.env`, chaves de API ou senhas no repositório. Antes de
publicar o projeto, revise as credenciais locais e substitua qualquer segredo
que tenha sido exposto.
