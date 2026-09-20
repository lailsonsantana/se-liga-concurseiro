-- ============================================================================
-- SeLigaConcurseiro - script de carga v2 (dados fictícios, consistentes entre os 3 serviços)
--
-- Data de referência dos dados: 2026-09-19 (datas de cronograma foram geradas a partir dela).
-- Rodar em banco vazio: os ids são IDENTITY e os concurso_id abaixo assumem 1..N.
--
-- REGRAS DE CONSISTÊNCIA (situacao_atual -> DB_CRONOGRAMA / DB_CARGOS)
--   PREVISTO ............... sem linha de cronograma, sem cargos
--   SOLICITADO ............. cronograma: solicitado                        | sem cargos
--   AUTORIZADO ............. cronograma: solicitado, autorizado            | sem cargos
--   EDITAL_PUBLICADO ....... cronograma: 5 datas (isencao/inscricoes são datas FUTURAS) | com cargos
--   INSCRICOES_ABERTAS ..... cronograma: 5 datas (inscricoes_abertas <= referência)      | com cargos
--   INSCRICOES_ENCERRADAS em diante (EM_ANDAMENTO ... ENCERRADO) ... 5 datas | com cargos
--   CANCELADO / SUSPENSO ... cronograma até onde chegou (1, 2 ou 5 datas); cargos só se houve edital
--   Ordem das datas: solicitado < autorizado < edital_publicado <= isencao_taxa <= inscricoes_abertas
--   Cargos: vagas_previstas = imediatas + cadastro_reserva
--           vagas_negros = 20% das previstas (só se previstas >= 3, fração >= 0,5 sobe)
--           vagas_pcd    = 5% das previstas, fração sobe (só se previstas >= 5)
--   orgao_concurso (cronograma e cargos) = DB_CONCURSO.orgao, idêntico
-- ============================================================================

-- ============================================================================
-- SERVIÇO 1: CONCURSOS
-- ============================================================================
CREATE TABLE DB_CONCURSO (
                          id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                          orgao VARCHAR(255),
                          cidade VARCHAR(255),
                          estado VARCHAR(50) CHECK (estado IN (
                                                               'ACRE', 'ALAGOAS', 'AMAPA', 'AMAZONAS', 'BAHIA', 'CEARA',
                                                               'DISTRITO_FEDERAL', 'ESPIRITO_SANTO', 'GOIAS', 'MARANHAO',
                                                               'MATO_GROSSO', 'MATO_GROSSO_DO_SUL', 'MINAS_GERAIS', 'PARA',
                                                               'PARAIBA', 'PARANA', 'PERNAMBUCO', 'PIAUI', 'RIO_DE_JANEIRO',
                                                               'RIO_GRANDE_DO_NORTE', 'RIO_GRANDE_DO_SUL', 'RONDONIA', 'RORAIMA',
                                                               'SANTA_CATARINA', 'SAO_PAULO', 'SERGIPE', 'TOCANTINS'
                              )),
                          banca VARCHAR(255),
                          situacao_atual VARCHAR(50) CHECK (situacao_atual IN (
                                                                               'PREVISTO', 'SOLICITADO', 'AUTORIZADO', 'EDITAL_PUBLICADO',
                                                                               'INSCRICOES_ABERTAS', 'INSCRICOES_ENCERRADAS', 'EM_ANDAMENTO',
                                                                               'EM_RECURSO', 'RESULTADO_FINAL_DIVULGADO', 'HOMOLOGADO',
                                                                               'EM_CONVOCACAO', 'PRORROGADO', 'ENCERRADO', 'CANCELADO', 'SUSPENSO'
                              ))
);

INSERT INTO DB_CONCURSO (orgao, cidade, estado, banca, situacao_atual)
VALUES
    ('Tribunal Regional do Trabalho da 2ª Região', 'São Paulo', 'SAO_PAULO', 'FGV', 'HOMOLOGADO'),  -- 1
    ('Secretaria da Saúde do Estado da Bahia', 'Salvador', 'BAHIA', 'CEBRASPE', 'EM_ANDAMENTO'),  -- 2
    ('Prefeitura Municipal de Guanambi', 'Guanambi', 'BAHIA', 'IDECAN', 'EDITAL_PUBLICADO'),  -- 3
    ('Secretaria de Estado de Educação de Minas Gerais', 'Belo Horizonte', 'MINAS_GERAIS', 'CONSULPLAN', 'INSCRICOES_ABERTAS'),  -- 4
    ('Defensoria Pública do Estado do Rio de Janeiro', 'Rio de Janeiro', 'RIO_DE_JANEIRO', 'FGV', 'RESULTADO_FINAL_DIVULGADO'),  -- 5
    ('Tribunal de Justiça do Estado de Pernambuco', 'Recife', 'PERNAMBUCO', 'CEBRASPE', 'EM_CONVOCACAO'),  -- 6
    ('Prefeitura Municipal de Fortaleza', 'Fortaleza', 'CEARA', 'VUNESP', 'AUTORIZADO'),  -- 7
    ('Câmara Municipal de Curitiba', 'Curitiba', 'PARANA', 'FAUEL', 'INSCRICOES_ENCERRADAS'),  -- 8
    ('Secretaria da Fazenda do Estado do Rio Grande do Sul', 'Porto Alegre', 'RIO_GRANDE_DO_SUL', 'FUNDATEC', 'PREVISTO'),  -- 9
    ('Ministério Público do Distrito Federal e Territórios', 'Brasília', 'DISTRITO_FEDERAL', 'CEBRASPE', 'EM_RECURSO'),  -- 10
    ('Instituto Federal do Espírito Santo', 'Vitória', 'ESPIRITO_SANTO', 'IBFC', 'PRORROGADO'),  -- 11
    ('Tribunal Regional Eleitoral de Goiás', 'Goiânia', 'GOIAS', 'FGV', 'ENCERRADO'),  -- 12
    ('Secretaria de Segurança Pública do Estado do Amazonas', 'Manaus', 'AMAZONAS', 'FUNCAB', 'SOLICITADO'),  -- 13
    ('Prefeitura Municipal de Natal', 'Natal', 'RIO_GRANDE_DO_NORTE', 'COMPERVE', 'CANCELADO'),  -- 14
    ('Corpo de Bombeiros Militar de Santa Catarina', 'Florianópolis', 'SANTA_CATARINA', 'FEPESE', 'HOMOLOGADO'),  -- 15
    ('Secretaria de Administração do Estado da Paraíba', 'João Pessoa', 'PARAIBA', 'IBFC', 'EM_ANDAMENTO'),  -- 16
    ('Tribunal de Contas do Estado do Tocantins', 'Palmas', 'TOCANTINS', 'CESGRANRIO', 'SUSPENSO'),  -- 17
    ('Assembleia Legislativa do Estado do Maranhão', 'São Luís', 'MARANHAO', 'FGV', 'EDITAL_PUBLICADO'),  -- 18
    ('Secretaria de Estado do Meio Ambiente de Mato Grosso', 'Cuiabá', 'MATO_GROSSO', 'IBADE', 'INSCRICOES_ABERTAS'),  -- 19
    ('Prefeitura Municipal de Aracaju', 'Aracaju', 'SERGIPE', 'FGV', 'PREVISTO'),  -- 20
    ('Tribunal Regional do Trabalho da 5ª Região', 'Salvador', 'BAHIA', 'IBADE', 'ENCERRADO'),  -- 21
    ('Tribunal Regional do Trabalho da 15ª Região', 'Campinas', 'SAO_PAULO', 'QUADRIX', 'HOMOLOGADO'),  -- 22
    ('Tribunal Regional do Trabalho da 3ª Região', 'Belo Horizonte', 'MINAS_GERAIS', 'IBADE', 'RESULTADO_FINAL_DIVULGADO'),  -- 23
    ('Tribunal Regional Federal da 1ª Região', 'Brasília', 'DISTRITO_FEDERAL', 'FCC', 'RESULTADO_FINAL_DIVULGADO'),  -- 24
    ('Tribunal Regional Federal da 4ª Região', 'Porto Alegre', 'RIO_GRANDE_DO_SUL', 'FCC', 'ENCERRADO'),  -- 25
    ('Tribunal de Justiça do Estado do Pará', 'Belém', 'PARA', 'IBADE', 'CANCELADO'),  -- 26
    ('Tribunal de Justiça do Estado da Bahia', 'Salvador', 'BAHIA', 'IBADE', 'SOLICITADO'),  -- 27
    ('Tribunal de Justiça do Estado de Santa Catarina', 'Florianópolis', 'SANTA_CATARINA', 'CESGRANRIO', 'EM_CONVOCACAO'),  -- 28
    ('Tribunal de Justiça do Estado do Rio Grande do Norte', 'Natal', 'RIO_GRANDE_DO_NORTE', 'FCC', 'ENCERRADO'),  -- 29
    ('Tribunal Regional Eleitoral de Minas Gerais', 'Belo Horizonte', 'MINAS_GERAIS', 'FGV', 'AUTORIZADO'),  -- 30
    ('Tribunal Regional Eleitoral de Mato Grosso do Sul', 'Campo Grande', 'MATO_GROSSO_DO_SUL', 'IADES', 'INSCRICOES_ABERTAS'),  -- 31
    ('Tribunal de Contas do Estado de Pernambuco', 'Recife', 'PERNAMBUCO', 'FCC', 'AUTORIZADO'),  -- 32
    ('Tribunal de Contas dos Municípios do Estado da Bahia', 'Salvador', 'BAHIA', 'IBFC', 'AUTORIZADO'),  -- 33
    ('Tribunal de Contas do Estado do Rio Grande do Sul', 'Porto Alegre', 'RIO_GRANDE_DO_SUL', 'CONSULPLAN', 'HOMOLOGADO'),  -- 34
    ('Ministério Público do Estado da Bahia', 'Salvador', 'BAHIA', 'VUNESP', 'HOMOLOGADO'),  -- 35
    ('Ministério Público do Estado de São Paulo', 'São Paulo', 'SAO_PAULO', 'FCC', 'EM_ANDAMENTO'),  -- 36
    ('Ministério Público do Estado do Paraná', 'Curitiba', 'PARANA', 'CONSULPLAN', 'SUSPENSO'),  -- 37
    ('Defensoria Pública do Estado da Bahia', 'Salvador', 'BAHIA', 'AOCP', 'INSCRICOES_ENCERRADAS'),  -- 38
    ('Defensoria Pública do Estado do Ceará', 'Fortaleza', 'CEARA', 'QUADRIX', 'EDITAL_PUBLICADO'),  -- 39
    ('Defensoria Pública da União', 'Brasília', 'DISTRITO_FEDERAL', 'CESGRANRIO', 'EM_CONVOCACAO'),  -- 40
    ('Procuradoria-Geral do Estado de Minas Gerais', 'Belo Horizonte', 'MINAS_GERAIS', 'IDECAN', 'CANCELADO'),  -- 41
    ('Procuradoria-Geral do Estado do Piauí', 'Teresina', 'PIAUI', 'CEBRASPE', 'EM_CONVOCACAO'),  -- 42
    ('Assembleia Legislativa do Estado da Bahia', 'Salvador', 'BAHIA', 'AOCP', 'RESULTADO_FINAL_DIVULGADO'),  -- 43
    ('Assembleia Legislativa do Estado de Minas Gerais', 'Belo Horizonte', 'MINAS_GERAIS', 'CONSULPLAN', 'AUTORIZADO'),  -- 44
    ('Assembleia Legislativa do Estado do Rio Grande do Sul', 'Porto Alegre', 'RIO_GRANDE_DO_SUL', 'CESGRANRIO', 'CANCELADO'),  -- 45
    ('Câmara Municipal de Salvador', 'Salvador', 'BAHIA', 'FGV', 'PRORROGADO'),  -- 46
    ('Câmara Municipal de Goiânia', 'Goiânia', 'GOIAS', 'FGV', 'EDITAL_PUBLICADO'),  -- 47
    ('Câmara Legislativa do Distrito Federal', 'Brasília', 'DISTRITO_FEDERAL', 'IADES', 'SUSPENSO'),  -- 48
    ('Câmara Municipal de Belém', 'Belém', 'PARA', 'AOCP', 'SUSPENSO'),  -- 49
    ('Prefeitura Municipal de Feira de Santana', 'Feira de Santana', 'BAHIA', 'IDECAN', 'EM_ANDAMENTO'),  -- 50
    ('Prefeitura Municipal de Camaçari', 'Camaçari', 'BAHIA', 'IBFC', 'EM_RECURSO'),  -- 51
    ('Prefeitura Municipal de Juazeiro', 'Juazeiro', 'BAHIA', 'IDECAN', 'EDITAL_PUBLICADO'),  -- 52
    ('Prefeitura Municipal de Ilhéus', 'Ilhéus', 'BAHIA', 'CONSULPLAN', 'EDITAL_PUBLICADO'),  -- 53
    ('Prefeitura Municipal de Teixeira de Freitas', 'Teixeira de Freitas', 'BAHIA', 'AOCP', 'INSCRICOES_ABERTAS'),  -- 54
    ('Prefeitura Municipal de Uberlândia', 'Uberlândia', 'MINAS_GERAIS', 'IBFC', 'INSCRICOES_ENCERRADAS'),  -- 55
    ('Prefeitura Municipal de Juiz de Fora', 'Juiz de Fora', 'MINAS_GERAIS', 'IBFC', 'EDITAL_PUBLICADO'),  -- 56
    ('Prefeitura Municipal de Campinas', 'Campinas', 'SAO_PAULO', 'FCC', 'ENCERRADO'),  -- 57
    ('Prefeitura Municipal de Santos', 'Santos', 'SAO_PAULO', 'QUADRIX', 'ENCERRADO'),  -- 58
    ('Prefeitura Municipal de Niterói', 'Niterói', 'RIO_DE_JANEIRO', 'VUNESP', 'EM_ANDAMENTO'),  -- 59
    ('Prefeitura Municipal de Londrina', 'Londrina', 'PARANA', 'QUADRIX', 'EM_RECURSO'),  -- 60
    ('Prefeitura Municipal de Joinville', 'Joinville', 'SANTA_CATARINA', 'IADES', 'INSCRICOES_ENCERRADAS'),  -- 61
    ('Prefeitura Municipal de Caxias do Sul', 'Caxias do Sul', 'RIO_GRANDE_DO_SUL', 'IBFC', 'PRORROGADO'),  -- 62
    ('Prefeitura Municipal de Caruaru', 'Caruaru', 'PERNAMBUCO', 'CEBRASPE', 'PREVISTO'),  -- 63
    ('Prefeitura Municipal de Mossoró', 'Mossoró', 'RIO_GRANDE_DO_NORTE', 'FUNRIO', 'SOLICITADO'),  -- 64
    ('Prefeitura Municipal de Campina Grande', 'Campina Grande', 'PARAIBA', 'IBFC', 'INSCRICOES_ABERTAS'),  -- 65
    ('Prefeitura Municipal de Maceió', 'Maceió', 'ALAGOAS', 'QUADRIX', 'INSCRICOES_ABERTAS'),  -- 66
    ('Prefeitura Municipal de Imperatriz', 'Imperatriz', 'MARANHAO', 'FGV', 'SUSPENSO'),  -- 67
    ('Prefeitura Municipal de Parnaíba', 'Parnaíba', 'PIAUI', 'IDECAN', 'ENCERRADO'),  -- 68
    ('Prefeitura Municipal de Ananindeua', 'Ananindeua', 'PARA', 'QUADRIX', 'CANCELADO'),  -- 69
    ('Prefeitura Municipal de Rio Branco', 'Rio Branco', 'ACRE', 'CEBRASPE', 'EDITAL_PUBLICADO'),  -- 70
    ('Prefeitura Municipal de Porto Velho', 'Porto Velho', 'RONDONIA', 'IADES', 'EM_ANDAMENTO'),  -- 71
    ('Secretaria de Estado da Saúde de São Paulo', 'São Paulo', 'SAO_PAULO', 'VUNESP', 'RESULTADO_FINAL_DIVULGADO'),  -- 72
    ('Secretaria de Estado de Saúde de Minas Gerais', 'Belo Horizonte', 'MINAS_GERAIS', 'FCC', 'RESULTADO_FINAL_DIVULGADO'),  -- 73
    ('Secretaria de Estado da Saúde do Ceará', 'Fortaleza', 'CEARA', 'CONSULPLAN', 'AUTORIZADO'),  -- 74
    ('Secretaria de Estado de Saúde de Goiás', 'Goiânia', 'GOIAS', 'FUNRIO', 'INSCRICOES_ABERTAS'),  -- 75
    ('Secretaria de Estado de Saúde Pública do Pará', 'Belém', 'PARA', 'FCC', 'EM_ANDAMENTO'),  -- 76
    ('Secretaria Municipal de Saúde do Recife', 'Recife', 'PERNAMBUCO', 'CONSULPLAN', 'PREVISTO'),  -- 77
    ('Hospital Universitário da Universidade Federal do Piauí', 'Teresina', 'PIAUI', 'IBFC', 'EM_RECURSO'),  -- 78
    ('Hospital Universitário da Universidade Federal de Santa Catarina', 'Florianópolis', 'SANTA_CATARINA', 'IBFC', 'SOLICITADO'),  -- 79
    ('Hospital Universitário da Universidade Federal do Amazonas', 'Manaus', 'AMAZONAS', 'CEBRASPE', 'EM_CONVOCACAO'),  -- 80
    ('Secretaria de Estado da Educação de São Paulo', 'São Paulo', 'SAO_PAULO', 'VUNESP', 'EM_RECURSO'),  -- 81
    ('Secretaria da Educação do Estado da Bahia', 'Salvador', 'BAHIA', 'VUNESP', 'SOLICITADO'),  -- 82
    ('Secretaria de Estado da Educação do Paraná', 'Curitiba', 'PARANA', 'FGV', 'EM_RECURSO'),  -- 83
    ('Secretaria Municipal de Educação de Manaus', 'Manaus', 'AMAZONAS', 'AOCP', 'PREVISTO'),  -- 84
    ('Secretaria de Estado da Educação de Alagoas', 'Maceió', 'ALAGOAS', 'CESGRANRIO', 'PRORROGADO'),  -- 85
    ('Secretaria de Estado da Educação de Goiás', 'Goiânia', 'GOIAS', 'QUADRIX', 'SOLICITADO'),  -- 86
    ('Secretaria da Fazenda do Estado da Bahia', 'Salvador', 'BAHIA', 'AOCP', 'HOMOLOGADO'),  -- 87
    ('Secretaria da Fazenda do Estado de Pernambuco', 'Recife', 'PERNAMBUCO', 'IBFC', 'SUSPENSO'),  -- 88
    ('Secretaria de Estado de Fazenda de Minas Gerais', 'Belo Horizonte', 'MINAS_GERAIS', 'FGV', 'RESULTADO_FINAL_DIVULGADO'),  -- 89
    ('Secretaria Municipal da Fazenda de São Paulo', 'São Paulo', 'SAO_PAULO', 'FGV', 'INSCRICOES_ENCERRADAS'),  -- 90
    ('Secretaria da Fazenda do Estado do Ceará', 'Fortaleza', 'CEARA', 'FUNRIO', 'AUTORIZADO'),  -- 91
    ('Polícia Militar da Bahia', 'Salvador', 'BAHIA', 'IBFC', 'AUTORIZADO'),  -- 92
    ('Polícia Civil da Bahia', 'Salvador', 'BAHIA', 'IBFC', 'EM_CONVOCACAO'),  -- 93
    ('Polícia Militar de Minas Gerais', 'Belo Horizonte', 'MINAS_GERAIS', 'VUNESP', 'HOMOLOGADO'),  -- 94
    ('Polícia Civil do Estado de São Paulo', 'São Paulo', 'SAO_PAULO', 'FCC', 'INSCRICOES_ABERTAS'),  -- 95
    ('Polícia Penal do Estado de Goiás', 'Goiânia', 'GOIAS', 'CESGRANRIO', 'PRORROGADO'),  -- 96
    ('Corpo de Bombeiros Militar do Distrito Federal', 'Brasília', 'DISTRITO_FEDERAL', 'IADES', 'ENCERRADO'),  -- 97
    ('Departamento Estadual de Trânsito do Paraná', 'Curitiba', 'PARANA', 'IBFC', 'EDITAL_PUBLICADO'),  -- 98
    ('Polícia Militar do Pará', 'Belém', 'PARA', 'IBADE', 'RESULTADO_FINAL_DIVULGADO'),  -- 99
    ('Polícia Civil de Pernambuco', 'Recife', 'PERNAMBUCO', 'FGV', 'PREVISTO'),  -- 100
    ('Instituto Federal da Bahia', 'Salvador', 'BAHIA', 'IBFC', 'PREVISTO'),  -- 101
    ('Instituto Federal de Minas Gerais', 'Belo Horizonte', 'MINAS_GERAIS', 'CEBRASPE', 'EM_ANDAMENTO'),  -- 102
    ('Universidade Federal de Pernambuco', 'Recife', 'PERNAMBUCO', 'FUNRIO', 'PREVISTO'),  -- 103
    ('Universidade Federal do Pará', 'Belém', 'PARA', 'FUNRIO', 'EM_CONVOCACAO'),  -- 104
    ('Universidade Federal de Santa Catarina', 'Florianópolis', 'SANTA_CATARINA', 'CEBRASPE', 'INSCRICOES_ENCERRADAS'),  -- 105
    ('Instituto Federal do Rio Grande do Norte', 'Natal', 'RIO_GRANDE_DO_NORTE', 'CEBRASPE', 'PREVISTO'),  -- 106
    ('Secretaria de Infraestrutura do Estado da Bahia', 'Salvador', 'BAHIA', 'FUNRIO', 'HOMOLOGADO'),  -- 107
    ('Secretaria de Estado de Infraestrutura de Mato Grosso', 'Cuiabá', 'MATO_GROSSO', 'AOCP', 'SOLICITADO'),  -- 108
    ('Secretaria de Meio Ambiente e Sustentabilidade do Pará', 'Belém', 'PARA', 'QUADRIX', 'EM_RECURSO'),  -- 109
    ('Secretaria de Estado do Meio Ambiente de Roraima', 'Boa Vista', 'RORAIMA', 'FGV', 'SOLICITADO'),  -- 110
    ('Secretaria de Estado da Agricultura do Amapá', 'Macapá', 'AMAPA', 'FGV', 'PREVISTO'),  -- 111
    ('Secretaria de Estado da Agricultura do Tocantins', 'Palmas', 'TOCANTINS', 'FCC', 'INSCRICOES_ABERTAS'),  -- 112
    ('Secretaria de Administração do Estado da Bahia', 'Salvador', 'BAHIA', 'IBFC', 'EM_CONVOCACAO'),  -- 113
    ('Secretaria de Estado de Gestão e Recursos Humanos do Espírito Santo', 'Vitória', 'ESPIRITO_SANTO', 'CESGRANRIO', 'CANCELADO'),  -- 114
    ('Secretaria de Estado da Administração do Piauí', 'Teresina', 'PIAUI', 'CESGRANRIO', 'EM_ANDAMENTO'),  -- 115
    ('Secretaria de Estado de Administração do Acre', 'Rio Branco', 'ACRE', 'FGV', 'INSCRICOES_ENCERRADAS'),  -- 116
    ('Banco do Brasil', 'Brasília', 'DISTRITO_FEDERAL', 'CEBRASPE', 'CANCELADO'),  -- 117
    ('Caixa Econômica Federal', 'Brasília', 'DISTRITO_FEDERAL', 'CEBRASPE', 'PRORROGADO'),  -- 118
    ('Empresa Brasileira de Correios e Telégrafos', 'Brasília', 'DISTRITO_FEDERAL', 'FGV', 'AUTORIZADO'),  -- 119
    ('Instituto Nacional do Seguro Social', 'Brasília', 'DISTRITO_FEDERAL', 'FGV', 'INSCRICOES_ENCERRADAS'),  -- 120
    ('Polícia Rodoviária Federal', 'Brasília', 'DISTRITO_FEDERAL', 'CEBRASPE', 'SOLICITADO'),  -- 121
    ('Instituto Brasileiro de Geografia e Estatística', 'Rio de Janeiro', 'RIO_DE_JANEIRO', 'IBFC', 'PRORROGADO');  -- 122

-- ============================================================================
-- SERVIÇO 2: CRONOGRAMA
-- ============================================================================
CREATE TABLE DB_CRONOGRAMA (
                            id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                            concurso_id BIGINT,
                            orgao_concurso VARCHAR(255),
                            solicitado DATE,
                            autorizado DATE,
                            edital_publicado DATE,
                            isencao_taxa DATE,
                            inscricoes_abertas DATE
);

INSERT INTO DB_CRONOGRAMA (concurso_id, orgao_concurso, solicitado, autorizado, edital_publicado, isencao_taxa, inscricoes_abertas)
VALUES
    (1, 'Tribunal Regional do Trabalho da 2ª Região', '2026-01-10', '2026-02-15', '2026-04-01', '2026-04-05', '2026-04-10'),  -- HOMOLOGADO
    (2, 'Secretaria da Saúde do Estado da Bahia', '2026-02-01', '2026-03-20', '2026-05-10', '2026-05-12', '2026-05-20'),  -- EM_ANDAMENTO
    (3, 'Prefeitura Municipal de Guanambi', '2026-05-04', '2026-07-02', '2026-09-10', '2026-10-01', '2026-10-05'),  -- EDITAL_PUBLICADO
    (4, 'Secretaria de Estado de Educação de Minas Gerais', '2026-05-10', '2026-07-04', '2026-09-01', '2026-09-10', '2026-09-12'),  -- INSCRICOES_ABERTAS
    (5, 'Defensoria Pública do Estado do Rio de Janeiro', '2025-10-24', '2026-01-01', '2026-03-21', '2026-03-27', '2026-03-27'),  -- RESULTADO_FINAL_DIVULGADO
    (6, 'Tribunal de Justiça do Estado de Pernambuco', '2025-10-10', '2025-12-03', '2026-03-06', '2026-03-12', '2026-03-12'),  -- EM_CONVOCACAO
    (7, 'Prefeitura Municipal de Fortaleza', '2026-06-19', '2026-07-09', NULL, NULL, NULL),  -- AUTORIZADO
    (8, 'Câmara Municipal de Curitiba', '2026-04-30', '2026-05-30', '2026-07-17', '2026-07-25', '2026-07-29'),  -- INSCRICOES_ENCERRADAS
    (10, 'Ministério Público do Distrito Federal e Territórios', '2026-01-25', '2026-04-08', '2026-06-30', '2026-07-06', '2026-07-09'),  -- EM_RECURSO
    (11, 'Instituto Federal do Espírito Santo', '2024-11-04', '2024-11-26', '2025-02-20', '2025-02-24', '2025-02-26'),  -- PRORROGADO
    (12, 'Tribunal Regional Eleitoral de Goiás', '2024-08-12', '2024-09-24', '2024-11-05', '2024-11-06', '2024-11-10'),  -- ENCERRADO
    (13, 'Secretaria de Segurança Pública do Estado do Amazonas', '2026-05-07', NULL, NULL, NULL, NULL),  -- SOLICITADO
    (14, 'Prefeitura Municipal de Natal', '2026-01-16', '2026-03-01', NULL, NULL, NULL),  -- CANCELADO
    (15, 'Corpo de Bombeiros Militar de Santa Catarina', '2025-11-24', '2026-01-08', '2026-02-12', '2026-02-20', '2026-02-24'),  -- HOMOLOGADO
    (16, 'Secretaria de Administração do Estado da Paraíba', '2026-02-06', '2026-02-23', '2026-05-17', '2026-05-22', '2026-05-28'),  -- EM_ANDAMENTO
    (17, 'Tribunal de Contas do Estado do Tocantins', '2025-11-07', '2026-01-13', '2026-04-16', '2026-04-20', '2026-05-10'),  -- SUSPENSO
    (18, 'Assembleia Legislativa do Estado do Maranhão', '2026-06-23', '2026-08-16', '2026-09-10', '2026-09-26', '2026-09-29'),  -- EDITAL_PUBLICADO
    (19, 'Secretaria de Estado do Meio Ambiente de Mato Grosso', '2026-03-30', '2026-05-26', '2026-08-30', '2026-09-07', '2026-09-13'),  -- INSCRICOES_ABERTAS
    (21, 'Tribunal Regional do Trabalho da 5ª Região', '2024-10-30', '2024-11-24', '2025-01-11', '2025-01-19', '2025-01-24'),  -- ENCERRADO
    (22, 'Tribunal Regional do Trabalho da 15ª Região', '2026-02-12', '2026-02-28', '2026-05-02', '2026-05-10', '2026-05-10'),  -- HOMOLOGADO
    (23, 'Tribunal Regional do Trabalho da 3ª Região', '2025-12-11', '2026-01-19', '2026-03-02', '2026-03-05', '2026-03-06'),  -- RESULTADO_FINAL_DIVULGADO
    (24, 'Tribunal Regional Federal da 1ª Região', '2026-02-04', '2026-03-02', '2026-05-14', '2026-05-24', '2026-05-29'),  -- RESULTADO_FINAL_DIVULGADO
    (25, 'Tribunal Regional Federal da 4ª Região', '2025-01-09', '2025-01-29', '2025-02-28', '2025-03-04', '2025-03-04'),  -- ENCERRADO
    (26, 'Tribunal de Justiça do Estado do Pará', '2026-03-19', '2026-05-24', '2026-08-02', '2026-08-09', '2026-08-16'),  -- CANCELADO
    (27, 'Tribunal de Justiça do Estado da Bahia', '2026-05-05', NULL, NULL, NULL, NULL),  -- SOLICITADO
    (28, 'Tribunal de Justiça do Estado de Santa Catarina', '2025-10-30', '2026-01-05', '2026-02-07', '2026-02-11', '2026-02-12'),  -- EM_CONVOCACAO
    (29, 'Tribunal de Justiça do Estado do Rio Grande do Norte', '2024-07-22', '2024-09-14', '2024-12-12', '2024-12-18', '2024-12-21'),  -- ENCERRADO
    (30, 'Tribunal Regional Eleitoral de Minas Gerais', '2026-05-14', '2026-05-29', NULL, NULL, NULL),  -- AUTORIZADO
    (31, 'Tribunal Regional Eleitoral de Mato Grosso do Sul', '2026-03-23', '2026-05-30', '2026-08-22', '2026-09-01', '2026-09-05'),  -- INSCRICOES_ABERTAS
    (32, 'Tribunal de Contas do Estado de Pernambuco', '2026-07-26', '2026-08-26', NULL, NULL, NULL),  -- AUTORIZADO
    (33, 'Tribunal de Contas dos Municípios do Estado da Bahia', '2026-05-25', '2026-07-20', NULL, NULL, NULL),  -- AUTORIZADO
    (34, 'Tribunal de Contas do Estado do Rio Grande do Sul', '2025-07-27', '2025-09-07', '2025-12-09', '2025-12-13', '2025-12-18'),  -- HOMOLOGADO
    (35, 'Ministério Público do Estado da Bahia', '2025-11-03', '2025-12-31', '2026-04-02', '2026-04-12', '2026-04-16'),  -- HOMOLOGADO
    (36, 'Ministério Público do Estado de São Paulo', '2026-02-15', '2026-04-21', '2026-05-19', '2026-05-26', '2026-05-30'),  -- EM_ANDAMENTO
    (37, 'Ministério Público do Estado do Paraná', '2026-05-30', '2026-06-22', NULL, NULL, NULL),  -- SUSPENSO
    (38, 'Defensoria Pública do Estado da Bahia', '2026-03-31', '2026-05-14', '2026-06-22', '2026-06-28', '2026-06-29'),  -- INSCRICOES_ENCERRADAS
    (39, 'Defensoria Pública do Estado do Ceará', '2026-04-30', '2026-06-01', '2026-09-02', '2026-09-23', '2026-09-26'),  -- EDITAL_PUBLICADO
    (40, 'Defensoria Pública da União', '2025-08-10', '2025-09-16', '2025-12-12', '2025-12-17', '2025-12-21'),  -- EM_CONVOCACAO
    (41, 'Procuradoria-Geral do Estado de Minas Gerais', '2026-01-09', NULL, NULL, NULL, NULL),  -- CANCELADO
    (42, 'Procuradoria-Geral do Estado do Piauí', '2025-07-30', '2025-08-26', '2025-11-02', '2025-11-04', '2025-11-08'),  -- EM_CONVOCACAO
    (43, 'Assembleia Legislativa do Estado da Bahia', '2026-02-20', '2026-04-11', '2026-05-07', '2026-05-17', '2026-05-17'),  -- RESULTADO_FINAL_DIVULGADO
    (44, 'Assembleia Legislativa do Estado de Minas Gerais', '2026-07-09', '2026-08-09', NULL, NULL, NULL),  -- AUTORIZADO
    (45, 'Assembleia Legislativa do Estado do Rio Grande do Sul', '2026-01-15', '2026-03-17', '2026-06-03', '2026-06-07', '2026-06-20'),  -- CANCELADO
    (46, 'Câmara Municipal de Salvador', '2025-04-10', '2025-05-11', '2025-06-11', '2025-06-16', '2025-06-21'),  -- PRORROGADO
    (47, 'Câmara Municipal de Goiânia', '2026-06-30', '2026-07-28', '2026-09-11', '2026-09-15', '2026-09-22'),  -- EDITAL_PUBLICADO
    (48, 'Câmara Legislativa do Distrito Federal', '2026-04-16', NULL, NULL, NULL, NULL),  -- SUSPENSO
    (49, 'Câmara Municipal de Belém', '2026-03-09', '2026-05-18', NULL, NULL, NULL),  -- SUSPENSO
    (50, 'Prefeitura Municipal de Feira de Santana', '2026-02-13', '2026-04-21', '2026-05-28', '2026-06-04', '2026-06-04'),  -- EM_ANDAMENTO
    (51, 'Prefeitura Municipal de Camaçari', '2026-03-22', '2026-05-23', '2026-06-19', '2026-06-20', '2026-06-23'),  -- EM_RECURSO
    (52, 'Prefeitura Municipal de Juazeiro', '2026-04-19', '2026-06-09', '2026-09-03', '2026-10-07', '2026-10-14'),  -- EDITAL_PUBLICADO
    (53, 'Prefeitura Municipal de Ilhéus', '2026-06-28', '2026-08-01', '2026-09-11', '2026-10-15', '2026-10-19'),  -- EDITAL_PUBLICADO
    (54, 'Prefeitura Municipal de Teixeira de Freitas', '2026-05-22', '2026-06-14', '2026-08-25', '2026-09-02', '2026-09-04'),  -- INSCRICOES_ABERTAS
    (55, 'Prefeitura Municipal de Uberlândia', '2026-04-10', '2026-05-01', '2026-07-04', '2026-07-12', '2026-07-14'),  -- INSCRICOES_ENCERRADAS
    (56, 'Prefeitura Municipal de Juiz de Fora', '2026-05-11', '2026-06-29', '2026-09-09', '2026-09-23', '2026-09-24'),  -- EDITAL_PUBLICADO
    (57, 'Prefeitura Municipal de Campinas', '2024-01-12', '2024-03-08', '2024-04-26', '2024-04-28', '2024-05-04'),  -- ENCERRADO
    (58, 'Prefeitura Municipal de Santos', '2024-01-18', '2024-03-29', '2024-05-07', '2024-05-16', '2024-05-17'),  -- ENCERRADO
    (59, 'Prefeitura Municipal de Niterói', '2025-12-31', '2026-03-04', '2026-05-28', '2026-06-05', '2026-06-11'),  -- EM_ANDAMENTO
    (60, 'Prefeitura Municipal de Londrina', '2025-11-25', '2026-01-26', '2026-04-24', '2026-05-04', '2026-05-09'),  -- EM_RECURSO
    (61, 'Prefeitura Municipal de Joinville', '2026-02-23', '2026-03-25', '2026-06-27', '2026-07-05', '2026-07-11'),  -- INSCRICOES_ENCERRADAS
    (62, 'Prefeitura Municipal de Caxias do Sul', '2024-11-16', '2025-01-14', '2025-03-04', '2025-03-09', '2025-03-12'),  -- PRORROGADO
    (64, 'Prefeitura Municipal de Mossoró', '2026-04-18', NULL, NULL, NULL, NULL),  -- SOLICITADO
    (65, 'Prefeitura Municipal de Campina Grande', '2026-04-12', '2026-06-05', '2026-08-28', '2026-08-29', '2026-08-30'),  -- INSCRICOES_ABERTAS
    (66, 'Prefeitura Municipal de Maceió', '2026-05-13', '2026-07-18', '2026-08-28', '2026-09-03', '2026-09-04'),  -- INSCRICOES_ABERTAS
    (67, 'Prefeitura Municipal de Imperatriz', '2026-02-27', '2026-05-07', '2026-06-17', '2026-06-21', '2026-07-14'),  -- SUSPENSO
    (68, 'Prefeitura Municipal de Parnaíba', '2024-11-18', '2024-12-03', '2025-02-16', '2025-02-25', '2025-02-27'),  -- ENCERRADO
    (69, 'Prefeitura Municipal de Ananindeua', '2025-11-22', '2025-12-22', NULL, NULL, NULL),  -- CANCELADO
    (70, 'Prefeitura Municipal de Rio Branco', '2026-06-04', '2026-06-20', '2026-09-07', '2026-10-14', '2026-10-15'),  -- EDITAL_PUBLICADO
    (71, 'Prefeitura Municipal de Porto Velho', '2026-03-07', '2026-03-27', '2026-05-31', '2026-06-07', '2026-06-07'),  -- EM_ANDAMENTO
    (72, 'Secretaria de Estado da Saúde de São Paulo', '2025-12-06', '2026-02-19', '2026-04-23', '2026-05-02', '2026-05-07'),  -- RESULTADO_FINAL_DIVULGADO
    (73, 'Secretaria de Estado de Saúde de Minas Gerais', '2026-01-11', '2026-01-27', '2026-03-12', '2026-03-20', '2026-03-21'),  -- RESULTADO_FINAL_DIVULGADO
    (74, 'Secretaria de Estado da Saúde do Ceará', '2026-08-14', '2026-09-05', NULL, NULL, NULL),  -- AUTORIZADO
    (75, 'Secretaria de Estado de Saúde de Goiás', '2026-05-30', '2026-07-01', '2026-07-31', '2026-08-10', '2026-08-16'),  -- INSCRICOES_ABERTAS
    (76, 'Secretaria de Estado de Saúde Pública do Pará', '2026-02-19', '2026-03-20', '2026-04-26', '2026-04-28', '2026-05-04'),  -- EM_ANDAMENTO
    (78, 'Hospital Universitário da Universidade Federal do Piauí', '2026-02-22', '2026-04-22', '2026-06-15', '2026-06-24', '2026-06-27'),  -- EM_RECURSO
    (79, 'Hospital Universitário da Universidade Federal de Santa Catarina', '2026-05-21', NULL, NULL, NULL, NULL),  -- SOLICITADO
    (80, 'Hospital Universitário da Universidade Federal do Amazonas', '2025-04-19', '2025-06-16', '2025-07-27', '2025-08-02', '2025-08-05'),  -- EM_CONVOCACAO
    (81, 'Secretaria de Estado da Educação de São Paulo', '2025-12-24', '2026-02-12', '2026-04-13', '2026-04-21', '2026-04-26'),  -- EM_RECURSO
    (82, 'Secretaria da Educação do Estado da Bahia', '2026-07-16', NULL, NULL, NULL, NULL),  -- SOLICITADO
    (83, 'Secretaria de Estado da Educação do Paraná', '2026-03-29', '2026-05-03', '2026-07-04', '2026-07-13', '2026-07-19'),  -- EM_RECURSO
    (85, 'Secretaria de Estado da Educação de Alagoas', '2025-02-25', '2025-04-29', '2025-08-03', '2025-08-07', '2025-08-08'),  -- PRORROGADO
    (86, 'Secretaria de Estado da Educação de Goiás', '2026-08-03', NULL, NULL, NULL, NULL),  -- SOLICITADO
    (87, 'Secretaria da Fazenda do Estado da Bahia', '2025-12-12', '2026-01-09', '2026-03-16', '2026-03-19', '2026-03-24'),  -- HOMOLOGADO
    (88, 'Secretaria da Fazenda do Estado de Pernambuco', '2026-03-09', '2026-04-02', '2026-06-03', '2026-06-06', '2026-06-22'),  -- SUSPENSO
    (89, 'Secretaria de Estado de Fazenda de Minas Gerais', '2025-09-08', '2025-10-21', '2026-01-14', '2026-01-20', '2026-01-23'),  -- RESULTADO_FINAL_DIVULGADO
    (90, 'Secretaria Municipal da Fazenda de São Paulo', '2026-02-24', '2026-05-05', '2026-07-09', '2026-07-19', '2026-07-22'),  -- INSCRICOES_ENCERRADAS
    (91, 'Secretaria da Fazenda do Estado do Ceará', '2026-07-18', '2026-08-17', NULL, NULL, NULL),  -- AUTORIZADO
    (92, 'Polícia Militar da Bahia', '2026-06-12', '2026-07-30', NULL, NULL, NULL),  -- AUTORIZADO
    (93, 'Polícia Civil da Bahia', '2025-07-06', '2025-08-02', '2025-08-31', '2025-09-07', '2025-09-08'),  -- EM_CONVOCACAO
    (94, 'Polícia Militar de Minas Gerais', '2025-07-31', '2025-08-27', '2025-11-27', '2025-12-03', '2025-12-07'),  -- HOMOLOGADO
    (95, 'Polícia Civil do Estado de São Paulo', '2026-04-04', '2026-05-11', '2026-08-13', '2026-08-23', '2026-08-25'),  -- INSCRICOES_ABERTAS
    (96, 'Polícia Penal do Estado de Goiás', '2025-01-30', '2025-03-12', '2025-04-22', '2025-04-23', '2025-04-27'),  -- PRORROGADO
    (97, 'Corpo de Bombeiros Militar do Distrito Federal', '2024-11-21', '2025-02-02', '2025-04-09', '2025-04-16', '2025-04-20'),  -- ENCERRADO
    (98, 'Departamento Estadual de Trânsito do Paraná', '2026-07-16', '2026-08-10', '2026-09-04', '2026-10-14', '2026-10-21'),  -- EDITAL_PUBLICADO
    (99, 'Polícia Militar do Pará', '2025-12-24', '2026-02-19', '2026-04-30', '2026-05-02', '2026-05-03'),  -- RESULTADO_FINAL_DIVULGADO
    (102, 'Instituto Federal de Minas Gerais', '2026-05-27', '2026-06-24', '2026-07-26', '2026-07-29', '2026-08-03'),  -- EM_ANDAMENTO
    (104, 'Universidade Federal do Pará', '2025-07-31', '2025-09-02', '2025-10-25', '2025-10-29', '2025-11-02'),  -- EM_CONVOCACAO
    (105, 'Universidade Federal de Santa Catarina', '2026-01-25', '2026-04-09', '2026-06-13', '2026-06-19', '2026-06-20'),  -- INSCRICOES_ENCERRADAS
    (107, 'Secretaria de Infraestrutura do Estado da Bahia', '2025-10-21', '2025-12-25', '2026-03-23', '2026-03-26', '2026-03-27'),  -- HOMOLOGADO
    (108, 'Secretaria de Estado de Infraestrutura de Mato Grosso', '2026-07-22', NULL, NULL, NULL, NULL),  -- SOLICITADO
    (109, 'Secretaria de Meio Ambiente e Sustentabilidade do Pará', '2026-03-25', '2026-04-25', '2026-06-26', '2026-07-06', '2026-07-10'),  -- EM_RECURSO
    (110, 'Secretaria de Estado do Meio Ambiente de Roraima', '2026-07-17', NULL, NULL, NULL, NULL),  -- SOLICITADO
    (112, 'Secretaria de Estado da Agricultura do Tocantins', '2026-06-09', '2026-07-11', '2026-08-12', '2026-08-20', '2026-08-24'),  -- INSCRICOES_ABERTAS
    (113, 'Secretaria de Administração do Estado da Bahia', '2025-04-24', '2025-07-08', '2025-09-07', '2025-09-15', '2025-09-18'),  -- EM_CONVOCACAO
    (114, 'Secretaria de Estado de Gestão e Recursos Humanos do Espírito Santo', '2026-04-09', '2026-04-25', '2026-07-02', '2026-07-08', '2026-07-08'),  -- CANCELADO
    (115, 'Secretaria de Estado da Administração do Piauí', '2026-02-11', '2026-04-07', '2026-06-14', '2026-06-19', '2026-06-21'),  -- EM_ANDAMENTO
    (116, 'Secretaria de Estado de Administração do Acre', '2026-03-02', '2026-04-21', '2026-07-11', '2026-07-16', '2026-07-18'),  -- INSCRICOES_ENCERRADAS
    (117, 'Banco do Brasil', '2026-07-08', '2026-08-07', NULL, NULL, NULL),  -- CANCELADO
    (118, 'Caixa Econômica Federal', '2024-07-01', '2024-08-19', '2024-10-24', '2024-10-31', '2024-11-03'),  -- PRORROGADO
    (119, 'Empresa Brasileira de Correios e Telégrafos', '2026-05-15', '2026-07-21', NULL, NULL, NULL),  -- AUTORIZADO
    (120, 'Instituto Nacional do Seguro Social', '2026-03-10', '2026-04-19', '2026-07-24', '2026-07-28', '2026-07-28'),  -- INSCRICOES_ENCERRADAS
    (121, 'Polícia Rodoviária Federal', '2026-06-01', NULL, NULL, NULL, NULL),  -- SOLICITADO
    (122, 'Instituto Brasileiro de Geografia e Estatística', '2024-11-28', '2025-01-04', '2025-02-02', '2025-02-07', '2025-02-13');  -- PRORROGADO

-- ============================================================================
-- SERVIÇO 3: CARGOS E VAGAS
-- ============================================================================
CREATE TABLE DB_CARGOS (
                       id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                       nome VARCHAR(255),
                       carga_horaria INTEGER,
                       salario REAL,
                       quantidade_vagas_previstas INTEGER,
                       quantidade_vagas_imediatas INTEGER,
                       quantidade_vagas_cadastro_reserva INTEGER,
                       quantidade_vagas_negros INTEGER,
                       quantidade_vagas_pcd INTEGER,
                       concurso_id BIGINT,
                       orgao_concurso VARCHAR(255)
);

INSERT INTO DB_CARGOS (nome, carga_horaria, salario, quantidade_vagas_previstas, quantidade_vagas_imediatas,
                       quantidade_vagas_cadastro_reserva, quantidade_vagas_negros, quantidade_vagas_pcd,
                       concurso_id, orgao_concurso)
VALUES
    ('Analista de Sistemas', 40, 4500.00, 10, 5, 5, 2, 1, 1, 'Tribunal Regional do Trabalho da 2ª Região'),
    ('Técnico em Enfermagem', 30, 2200.50, 15, 8, 7, 3, 1, 2, 'Secretaria da Saúde do Estado da Bahia'),
    ('Assistente Administrativo', 40, 2100.00, 20, 10, 10, 4, 1, 1, 'Tribunal Regional do Trabalho da 2ª Região'),
    ('Engenheiro Civil', 40, 6800.00, 5, 2, 3, 1, 1, 3, 'Prefeitura Municipal de Guanambi'),
    ('Professor de Matemática', 20, 3200.00, 12, 6, 6, 2, 1, 4, 'Secretaria de Estado de Educação de Minas Gerais'),
    ('Motorista', 40, 1900.00, 8, 4, 4, 2, 1, 3, 'Prefeitura Municipal de Guanambi'),
    ('Contador', 40, 5200.00, 6, 3, 3, 1, 1, 1, 'Tribunal Regional do Trabalho da 2ª Região'),
    ('Recepcionista', 30, 1750.00, 10, 5, 5, 2, 1, 2, 'Secretaria da Saúde do Estado da Bahia'),
    ('Analista Jurídico', 40, 7500.00, 4, 2, 2, 1, 0, 5, 'Defensoria Pública do Estado do Rio de Janeiro'),
    ('Auxiliar de Serviços Gerais', 40, 1650.00, 25, 12, 13, 5, 2, 4, 'Secretaria de Estado de Educação de Minas Gerais'),
    ('Técnico da Defensoria - Administrativo', 40, 5600.00, 15, 8, 7, 3, 1, 5, 'Defensoria Pública do Estado do Rio de Janeiro'),
    ('Analista da Defensoria - Serviço Social', 30, 8950.00, 6, 3, 3, 1, 1, 5, 'Defensoria Pública do Estado do Rio de Janeiro'),
    ('Técnico Judiciário - Segurança e Transporte', 40, 7549.58, 7, 5, 2, 1, 1, 6, 'Tribunal de Justiça do Estado de Pernambuco'),
    ('Analista Judiciário - Engenharia Civil', 40, 11200.00, 4, 3, 1, 1, 0, 6, 'Tribunal de Justiça do Estado de Pernambuco'),
    ('Técnico Judiciário - Área Administrativa', 40, 8400.00, 21, 14, 7, 4, 2, 6, 'Tribunal de Justiça do Estado de Pernambuco'),
    ('Analista Judiciário - Tecnologia da Informação', 40, 14402.99, 8, 4, 4, 2, 1, 6, 'Tribunal de Justiça do Estado de Pernambuco'),
    ('Analista Judiciário - Área Judiciária', 40, 12150.00, 22, 0, 22, 4, 2, 6, 'Tribunal de Justiça do Estado de Pernambuco'),
    ('Assistente Legislativo', 40, 3700.00, 29, 0, 29, 6, 2, 8, 'Câmara Municipal de Curitiba'),
    ('Técnico Legislativo - Administrativo', 40, 5650.00, 39, 19, 20, 8, 2, 8, 'Câmara Municipal de Curitiba'),
    ('Analista Legislativo - Processo Legislativo', 40, 11103.83, 16, 8, 8, 3, 1, 8, 'Câmara Municipal de Curitiba'),
    ('Analista do Ministério Público - Direito', 40, 11500.00, 17, 17, 0, 3, 1, 10, 'Ministério Público do Distrito Federal e Territórios'),
    ('Analista do Ministério Público - Tecnologia da Informação', 40, 10731.75, 5, 0, 5, 1, 1, 10, 'Ministério Público do Distrito Federal e Territórios'),
    ('Técnico do Ministério Público - Informática', 40, 6400.00, 2, 1, 1, 0, 0, 10, 'Ministério Público do Distrito Federal e Territórios'),
    ('Técnico em Tecnologia da Informação', 40, 4006.43, 5, 5, 0, 1, 1, 11, 'Instituto Federal do Espírito Santo'),
    ('Tradutor e Intérprete de Linguagem de Sinais', 40, 3600.00, 5, 2, 3, 1, 1, 11, 'Instituto Federal do Espírito Santo'),
    ('Professor EBTT - Área: Matemática', 40, 10250.00, 7, 5, 2, 1, 1, 11, 'Instituto Federal do Espírito Santo'),
    ('Analista Judiciário - Área Judiciária', 40, 14035.72, 14, 10, 4, 3, 1, 12, 'Tribunal Regional Eleitoral de Goiás'),
    ('Analista Judiciário - Tecnologia da Informação', 40, 11500.00, 17, 10, 7, 3, 1, 12, 'Tribunal Regional Eleitoral de Goiás'),
    ('Analista Judiciário - Oficial de Justiça Avaliador', 40, 13600.00, 18, 10, 8, 4, 1, 12, 'Tribunal Regional Eleitoral de Goiás'),
    ('Soldado Bombeiro Militar', 40, 3550.00, 267, 150, 117, 53, 14, 15, 'Corpo de Bombeiros Militar de Santa Catarina'),
    ('Cadete Oficial Bombeiro Militar', 40, 7344.69, 61, 61, 0, 12, 4, 15, 'Corpo de Bombeiros Militar de Santa Catarina'),
    ('Oficial Bombeiro Militar - Engenheiro Civil', 40, 8950.00, 8, 6, 2, 2, 1, 15, 'Corpo de Bombeiros Militar de Santa Catarina'),
    ('Oficial de Saúde Bombeiro Militar - Médico', 40, 10400.00, 7, 0, 7, 1, 1, 15, 'Corpo de Bombeiros Militar de Santa Catarina'),
    ('Assistente Administrativo', 40, 3800.00, 57, 0, 57, 11, 3, 16, 'Secretaria de Administração do Estado da Paraíba'),
    ('Analista de Gestão Administrativa', 40, 8100.00, 43, 29, 14, 9, 3, 16, 'Secretaria de Administração do Estado da Paraíba'),
    ('Analista de Planejamento e Orçamento', 40, 7571.60, 10, 10, 0, 2, 1, 16, 'Secretaria de Administração do Estado da Paraíba'),
    ('Técnico Administrativo', 40, 5000.00, 66, 41, 25, 13, 4, 16, 'Secretaria de Administração do Estado da Paraíba'),
    ('Analista de Tecnologia da Informação', 40, 8800.00, 14, 7, 7, 3, 1, 16, 'Secretaria de Administração do Estado da Paraíba'),
    ('Auditor de Controle Externo - Contabilidade', 40, 15207.43, 5, 0, 5, 1, 1, 17, 'Tribunal de Contas do Estado do Tocantins'),
    ('Auditor de Controle Externo - Tecnologia da Informação', 40, 18300.00, 4, 0, 4, 1, 0, 17, 'Tribunal de Contas do Estado do Tocantins'),
    ('Auditor de Controle Externo - Direito', 40, 15950.00, 4, 3, 1, 1, 0, 17, 'Tribunal de Contas do Estado do Tocantins'),
    ('Analista de Controle Externo', 40, 8334.74, 18, 0, 18, 4, 1, 17, 'Tribunal de Contas do Estado do Tocantins'),
    ('Analista Legislativo - Tecnologia da Informação', 40, 13042.12, 10, 5, 5, 2, 1, 18, 'Assembleia Legislativa do Estado do Maranhão'),
    ('Técnico Legislativo - Administrativo', 40, 6350.00, 29, 21, 8, 6, 2, 18, 'Assembleia Legislativa do Estado do Maranhão'),
    ('Agente de Polícia Legislativa', 40, 6050.00, 30, 23, 7, 6, 2, 18, 'Assembleia Legislativa do Estado do Maranhão'),
    ('Analista Legislativo - Contabilidade', 40, 12250.00, 4, 2, 2, 1, 0, 18, 'Assembleia Legislativa do Estado do Maranhão'),
    ('Analista Ambiental - Geologia', 40, 8050.00, 8, 0, 8, 2, 1, 19, 'Secretaria de Estado do Meio Ambiente de Mato Grosso'),
    ('Técnico Ambiental', 40, 3850.00, 14, 14, 0, 3, 1, 19, 'Secretaria de Estado do Meio Ambiente de Mato Grosso'),
    ('Fiscal Ambiental', 40, 5700.00, 21, 21, 0, 4, 2, 19, 'Secretaria de Estado do Meio Ambiente de Mato Grosso'),
    ('Motorista', 40, 2301.10, 5, 3, 2, 1, 1, 19, 'Secretaria de Estado do Meio Ambiente de Mato Grosso'),
    ('Analista Judiciário - Oficial de Justiça Avaliador', 40, 12150.00, 21, 16, 5, 4, 2, 21, 'Tribunal Regional do Trabalho da 5ª Região'),
    ('Técnico Judiciário - Área Administrativa', 40, 8136.65, 23, 10, 13, 5, 2, 21, 'Tribunal Regional do Trabalho da 5ª Região'),
    ('Técnico Judiciário - Tecnologia da Informação', 40, 7288.56, 16, 9, 7, 3, 1, 21, 'Tribunal Regional do Trabalho da 5ª Região'),
    ('Técnico Judiciário - Segurança e Transporte', 40, 6900.00, 9, 9, 0, 2, 1, 21, 'Tribunal Regional do Trabalho da 5ª Região'),
    ('Analista Judiciário - Tecnologia da Informação', 40, 14186.06, 23, 23, 0, 5, 2, 21, 'Tribunal Regional do Trabalho da 5ª Região'),
    ('Técnico Judiciário - Tecnologia da Informação', 40, 6702.91, 14, 10, 4, 3, 1, 22, 'Tribunal Regional do Trabalho da 15ª Região'),
    ('Analista Judiciário - Tecnologia da Informação', 40, 12500.00, 12, 0, 12, 2, 1, 22, 'Tribunal Regional do Trabalho da 15ª Região'),
    ('Analista Judiciário - Engenharia Civil', 40, 12400.00, 3, 2, 1, 1, 0, 22, 'Tribunal Regional do Trabalho da 15ª Região'),
    ('Analista Judiciário - Oficial de Justiça Avaliador', 40, 13232.74, 50, 0, 50, 10, 3, 22, 'Tribunal Regional do Trabalho da 15ª Região'),
    ('Analista Judiciário - Oficial de Justiça Avaliador', 40, 14150.00, 18, 13, 5, 4, 1, 23, 'Tribunal Regional do Trabalho da 3ª Região'),
    ('Técnico Judiciário - Área Administrativa', 40, 8093.77, 82, 54, 28, 16, 5, 23, 'Tribunal Regional do Trabalho da 3ª Região'),
    ('Analista Judiciário - Tecnologia da Informação', 40, 12859.76, 13, 13, 0, 3, 1, 23, 'Tribunal Regional do Trabalho da 3ª Região'),
    ('Analista Judiciário - Área Judiciária', 40, 12559.43, 21, 16, 5, 4, 2, 23, 'Tribunal Regional do Trabalho da 3ª Região'),
    ('Analista Judiciário - Área Judiciária', 40, 11900.00, 48, 34, 14, 10, 3, 24, 'Tribunal Regional Federal da 1ª Região'),
    ('Técnico Judiciário - Área Administrativa', 40, 7671.62, 30, 0, 30, 6, 2, 24, 'Tribunal Regional Federal da 1ª Região'),
    ('Analista Judiciário - Tecnologia da Informação', 40, 13200.00, 22, 15, 7, 4, 2, 24, 'Tribunal Regional Federal da 1ª Região'),
    ('Analista Judiciário - Contadoria', 40, 13100.00, 2, 2, 0, 0, 0, 24, 'Tribunal Regional Federal da 1ª Região'),
    ('Técnico Judiciário - Tecnologia da Informação', 40, 7250.00, 19, 19, 0, 4, 1, 25, 'Tribunal Regional Federal da 4ª Região'),
    ('Analista Judiciário - Tecnologia da Informação', 40, 11723.79, 10, 10, 0, 2, 1, 25, 'Tribunal Regional Federal da 4ª Região'),
    ('Técnico Judiciário - Segurança e Transporte', 40, 6900.00, 6, 4, 2, 1, 1, 25, 'Tribunal Regional Federal da 4ª Região'),
    ('Técnico Judiciário - Tecnologia da Informação', 40, 7800.00, 10, 7, 3, 2, 1, 26, 'Tribunal de Justiça do Estado do Pará'),
    ('Técnico Judiciário - Área Administrativa', 40, 6400.00, 38, 23, 15, 8, 2, 26, 'Tribunal de Justiça do Estado do Pará'),
    ('Analista Judiciário - Oficial de Justiça Avaliador', 40, 11330.78, 10, 6, 4, 2, 1, 26, 'Tribunal de Justiça do Estado do Pará'),
    ('Analista Judiciário - Oficial de Justiça Avaliador', 40, 12650.00, 12, 0, 12, 2, 1, 28, 'Tribunal de Justiça do Estado de Santa Catarina'),
    ('Analista Judiciário - Área Judiciária', 40, 13500.00, 47, 0, 47, 9, 3, 28, 'Tribunal de Justiça do Estado de Santa Catarina'),
    ('Analista Judiciário - Contadoria', 40, 10850.00, 2, 1, 1, 0, 0, 29, 'Tribunal de Justiça do Estado do Rio Grande do Norte'),
    ('Analista Judiciário - Área Judiciária', 40, 9850.00, 22, 12, 10, 4, 2, 29, 'Tribunal de Justiça do Estado do Rio Grande do Norte'),
    ('Analista Judiciário - Tecnologia da Informação', 40, 9963.20, 8, 4, 4, 2, 1, 29, 'Tribunal de Justiça do Estado do Rio Grande do Norte'),
    ('Técnico Judiciário - Segurança e Transporte', 40, 8019.48, 3, 3, 0, 1, 0, 31, 'Tribunal Regional Eleitoral de Mato Grosso do Sul'),
    ('Analista Judiciário - Engenharia Civil', 40, 14015.34, 1, 1, 0, 0, 0, 31, 'Tribunal Regional Eleitoral de Mato Grosso do Sul'),
    ('Técnico Judiciário - Área Administrativa', 40, 7200.00, 12, 5, 7, 2, 1, 31, 'Tribunal Regional Eleitoral de Mato Grosso do Sul'),
    ('Auditor de Controle Externo - Direito', 40, 14478.11, 5, 5, 0, 1, 1, 34, 'Tribunal de Contas do Estado do Rio Grande do Sul'),
    ('Analista de Controle Externo', 40, 8720.57, 9, 5, 4, 2, 1, 34, 'Tribunal de Contas do Estado do Rio Grande do Sul'),
    ('Técnico de Controle Externo', 40, 6850.00, 15, 15, 0, 3, 1, 34, 'Tribunal de Contas do Estado do Rio Grande do Sul'),
    ('Analista do Ministério Público - Tecnologia da Informação', 40, 9721.20, 14, 10, 4, 3, 1, 35, 'Ministério Público do Estado da Bahia'),
    ('Analista do Ministério Público - Contabilidade', 40, 11696.42, 1, 1, 0, 0, 0, 35, 'Ministério Público do Estado da Bahia'),
    ('Analista do Ministério Público - Direito', 40, 11619.80, 37, 22, 15, 7, 2, 35, 'Ministério Público do Estado da Bahia'),
    ('Analista do Ministério Público - Contabilidade', 40, 12820.83, 3, 1, 2, 1, 0, 36, 'Ministério Público do Estado de São Paulo'),
    ('Analista do Ministério Público - Tecnologia da Informação', 40, 11900.00, 6, 3, 3, 1, 1, 36, 'Ministério Público do Estado de São Paulo'),
    ('Defensor Público Substituto', 40, 29150.00, 28, 11, 17, 6, 2, 38, 'Defensoria Pública do Estado da Bahia'),
    ('Analista da Defensoria - Psicologia', 40, 7700.00, 7, 5, 2, 1, 1, 38, 'Defensoria Pública do Estado da Bahia'),
    ('Técnico da Defensoria - Administrativo', 40, 6417.13, 11, 11, 0, 2, 1, 39, 'Defensoria Pública do Estado do Ceará'),
    ('Defensor Público Substituto', 40, 27450.00, 23, 10, 13, 5, 2, 39, 'Defensoria Pública do Estado do Ceará'),
    ('Analista da Defensoria - Direito', 40, 7862.67, 15, 8, 7, 3, 1, 39, 'Defensoria Pública do Estado do Ceará'),
    ('Analista da Defensoria - Psicologia', 40, 8950.00, 7, 5, 2, 1, 1, 40, 'Defensoria Pública da União'),
    ('Técnico da Defensoria - Administrativo', 40, 5850.00, 23, 15, 8, 5, 2, 40, 'Defensoria Pública da União'),
    ('Defensor Público Substituto', 40, 35000.00, 10, 4, 6, 2, 1, 40, 'Defensoria Pública da União'),
    ('Técnico da Procuradoria - Administrativo', 40, 5699.45, 22, 15, 7, 4, 2, 42, 'Procuradoria-Geral do Estado do Piauí'),
    ('Procurador do Estado', 40, 24136.53, 22, 9, 13, 4, 2, 42, 'Procuradoria-Geral do Estado do Piauí'),
    ('Analista da Procuradoria - Direito', 40, 7516.05, 5, 3, 2, 1, 1, 42, 'Procuradoria-Geral do Estado do Piauí'),
    ('Consultor Legislativo - Direito', 40, 18250.00, 3, 2, 1, 1, 0, 43, 'Assembleia Legislativa do Estado da Bahia'),
    ('Assistente Legislativo', 40, 4050.00, 8, 0, 8, 2, 1, 43, 'Assembleia Legislativa do Estado da Bahia'),
    ('Técnico Legislativo - Administrativo', 40, 6240.29, 40, 28, 12, 8, 2, 43, 'Assembleia Legislativa do Estado da Bahia'),
    ('Assistente Legislativo', 40, 4050.00, 8, 5, 3, 2, 1, 45, 'Assembleia Legislativa do Estado do Rio Grande do Sul'),
    ('Analista Legislativo - Processo Legislativo', 40, 11750.00, 17, 17, 0, 3, 1, 45, 'Assembleia Legislativa do Estado do Rio Grande do Sul'),
    ('Analista Legislativo - Tecnologia da Informação', 40, 9797.36, 4, 3, 1, 1, 0, 45, 'Assembleia Legislativa do Estado do Rio Grande do Sul'),
    ('Agente de Polícia Legislativa', 40, 6500.00, 7, 5, 2, 1, 1, 45, 'Assembleia Legislativa do Estado do Rio Grande do Sul'),
    ('Assistente Legislativo', 40, 2256.60, 9, 0, 9, 2, 1, 46, 'Câmara Municipal de Salvador'),
    ('Analista Legislativo - Tecnologia da Informação', 40, 6600.00, 1, 1, 0, 0, 0, 46, 'Câmara Municipal de Salvador'),
    ('Analista Legislativo - Processo Legislativo', 40, 5896.17, 4, 3, 1, 1, 0, 46, 'Câmara Municipal de Salvador'),
    ('Analista Legislativo - Contabilidade', 40, 6430.00, 3, 3, 0, 1, 0, 46, 'Câmara Municipal de Salvador'),
    ('Assistente Legislativo', 40, 2100.00, 16, 11, 5, 3, 1, 47, 'Câmara Municipal de Goiânia'),
    ('Analista Legislativo - Tecnologia da Informação', 40, 5200.00, 1, 1, 0, 0, 0, 47, 'Câmara Municipal de Goiânia'),
    ('Agente de Combate às Endemias', 40, 2450.00, 42, 24, 18, 8, 3, 50, 'Prefeitura Municipal de Feira de Santana'),
    ('Fisioterapeuta', 30, 4008.27, 2, 2, 0, 0, 0, 50, 'Prefeitura Municipal de Feira de Santana'),
    ('Auxiliar de Serviços Gerais', 40, 1651.00, 72, 57, 15, 14, 4, 50, 'Prefeitura Municipal de Feira de Santana'),
    ('Guarda Civil Municipal', 40, 3700.00, 128, 101, 27, 26, 7, 50, 'Prefeitura Municipal de Feira de Santana'),
    ('Operador de Máquinas Pesadas', 40, 3076.24, 12, 9, 3, 2, 1, 50, 'Prefeitura Municipal de Feira de Santana'),
    ('Operador de Máquinas Pesadas', 40, 2114.30, 11, 11, 0, 2, 1, 51, 'Prefeitura Municipal de Camaçari'),
    ('Técnico em Enfermagem', 40, 2600.00, 10, 4, 6, 2, 1, 51, 'Prefeitura Municipal de Camaçari'),
    ('Assistente Social', 30, 4250.00, 3, 2, 1, 1, 0, 51, 'Prefeitura Municipal de Camaçari'),
    ('Guarda Civil Municipal', 40, 4050.00, 69, 39, 30, 14, 4, 51, 'Prefeitura Municipal de Camaçari'),
    ('Auxiliar de Serviços Gerais', 40, 1700.00, 27, 0, 27, 5, 2, 51, 'Prefeitura Municipal de Camaçari'),
    ('Médico (Estratégia Saúde da Família)', 40, 12418.34, 7, 5, 2, 1, 1, 51, 'Prefeitura Municipal de Camaçari'),
    ('Arquiteto e Urbanista', 40, 7050.00, 1, 1, 0, 0, 0, 52, 'Prefeitura Municipal de Juazeiro'),
    ('Técnico em Informática', 40, 3969.96, 2, 1, 1, 0, 0, 52, 'Prefeitura Municipal de Juazeiro'),
    ('Arquiteto e Urbanista', 40, 5850.00, 2, 1, 1, 0, 0, 53, 'Prefeitura Municipal de Ilhéus'),
    ('Vigia', 40, 1651.00, 10, 5, 5, 2, 1, 53, 'Prefeitura Municipal de Ilhéus'),
    ('Assistente Social', 30, 4710.85, 6, 4, 2, 1, 1, 53, 'Prefeitura Municipal de Ilhéus'),
    ('Merendeira', 40, 1672.16, 13, 0, 13, 3, 1, 53, 'Prefeitura Municipal de Ilhéus'),
    ('Auxiliar de Serviços Gerais', 40, 1651.00, 44, 32, 12, 9, 3, 53, 'Prefeitura Municipal de Ilhéus'),
    ('Motorista', 40, 2400.00, 9, 9, 0, 2, 1, 53, 'Prefeitura Municipal de Ilhéus'),
    ('Agente Comunitário de Saúde', 40, 2733.80, 64, 0, 64, 13, 4, 54, 'Prefeitura Municipal de Teixeira de Freitas'),
    ('Nutricionista', 30, 4050.00, 1, 1, 0, 0, 0, 54, 'Prefeitura Municipal de Teixeira de Freitas'),
    ('Fisioterapeuta', 30, 3500.00, 4, 2, 2, 1, 0, 54, 'Prefeitura Municipal de Teixeira de Freitas'),
    ('Professor de Matemática', 40, 3953.42, 9, 7, 2, 2, 1, 54, 'Prefeitura Municipal de Teixeira de Freitas'),
    ('Médico (Estratégia Saúde da Família)', 40, 14750.00, 10, 5, 5, 2, 1, 55, 'Prefeitura Municipal de Uberlândia'),
    ('Vigia', 40, 2131.05, 20, 20, 0, 4, 1, 55, 'Prefeitura Municipal de Uberlândia'),
    ('Enfermeiro (Estratégia Saúde da Família)', 40, 4700.00, 11, 0, 11, 2, 1, 55, 'Prefeitura Municipal de Uberlândia'),
    ('Procurador Municipal', 40, 15447.91, 6, 3, 3, 1, 1, 55, 'Prefeitura Municipal de Uberlândia'),
    ('Médico Veterinário', 40, 4502.61, 1, 1, 0, 0, 0, 56, 'Prefeitura Municipal de Juiz de Fora'),
    ('Arquiteto e Urbanista', 40, 7892.09, 3, 3, 0, 1, 0, 56, 'Prefeitura Municipal de Juiz de Fora'),
    ('Merendeira', 40, 1800.00, 24, 24, 0, 5, 2, 56, 'Prefeitura Municipal de Juiz de Fora'),
    ('Contador', 40, 6782.92, 4, 3, 1, 1, 0, 56, 'Prefeitura Municipal de Juiz de Fora'),
    ('Operador de Máquinas Pesadas', 40, 3045.71, 6, 5, 1, 1, 1, 57, 'Prefeitura Municipal de Campinas'),
    ('Engenheiro Civil', 40, 9848.15, 4, 2, 2, 1, 0, 57, 'Prefeitura Municipal de Campinas'),
    ('Professor de Educação Física', 40, 3745.53, 17, 17, 0, 3, 1, 57, 'Prefeitura Municipal de Campinas'),
    ('Guarda Civil Municipal', 40, 3293.77, 179, 89, 90, 36, 9, 57, 'Prefeitura Municipal de Campinas'),
    ('Professor de Língua Portuguesa', 40, 4200.00, 25, 18, 7, 5, 2, 58, 'Prefeitura Municipal de Santos'),
    ('Cirurgião-Dentista', 40, 7482.89, 8, 6, 2, 2, 1, 58, 'Prefeitura Municipal de Santos'),
    ('Operador de Máquinas Pesadas', 40, 3229.88, 7, 3, 4, 1, 1, 58, 'Prefeitura Municipal de Santos'),
    ('Arquiteto e Urbanista', 40, 6133.08, 1, 1, 0, 0, 0, 58, 'Prefeitura Municipal de Santos'),
    ('Engenheiro Civil', 40, 8797.89, 2, 2, 0, 0, 0, 59, 'Prefeitura Municipal de Niterói'),
    ('Guarda Civil Municipal', 40, 3792.35, 37, 27, 10, 7, 2, 59, 'Prefeitura Municipal de Niterói'),
    ('Técnico em Enfermagem', 40, 3013.41, 9, 9, 0, 2, 1, 59, 'Prefeitura Municipal de Niterói'),
    ('Professor de Educação Física', 40, 4550.00, 20, 0, 20, 4, 1, 60, 'Prefeitura Municipal de Londrina'),
    ('Fisioterapeuta', 30, 3650.00, 3, 2, 1, 1, 0, 60, 'Prefeitura Municipal de Londrina'),
    ('Agente de Combate às Endemias', 40, 3050.00, 40, 28, 12, 8, 2, 60, 'Prefeitura Municipal de Londrina'),
    ('Médico Veterinário', 40, 6150.00, 1, 1, 0, 0, 0, 60, 'Prefeitura Municipal de Londrina'),
    ('Engenheiro Civil', 40, 8634.93, 4, 3, 1, 1, 0, 61, 'Prefeitura Municipal de Joinville'),
    ('Professor de Matemática', 40, 5200.00, 27, 12, 15, 5, 2, 61, 'Prefeitura Municipal de Joinville'),
    ('Cirurgião-Dentista', 40, 5900.00, 4, 2, 2, 1, 0, 62, 'Prefeitura Municipal de Caxias do Sul'),
    ('Agente Comunitário de Saúde', 40, 2862.24, 105, 105, 0, 21, 6, 62, 'Prefeitura Municipal de Caxias do Sul'),
    ('Agente Administrativo', 40, 2500.00, 38, 28, 10, 8, 2, 62, 'Prefeitura Municipal de Caxias do Sul'),
    ('Fisioterapeuta', 30, 3650.00, 2, 1, 1, 0, 0, 62, 'Prefeitura Municipal de Caxias do Sul'),
    ('Guarda Civil Municipal', 40, 3250.93, 126, 0, 126, 25, 7, 62, 'Prefeitura Municipal de Caxias do Sul'),
    ('Procurador Municipal', 40, 10072.25, 4, 4, 0, 1, 0, 62, 'Prefeitura Municipal de Caxias do Sul'),
    ('Professor de Educação Básica - Anos Iniciais', 40, 3550.00, 66, 48, 18, 13, 4, 65, 'Prefeitura Municipal de Campina Grande'),
    ('Motorista', 40, 2363.95, 15, 7, 8, 3, 1, 65, 'Prefeitura Municipal de Campina Grande'),
    ('Nutricionista', 30, 3450.00, 4, 2, 2, 1, 0, 65, 'Prefeitura Municipal de Campina Grande'),
    ('Fiscal de Tributos', 40, 4300.00, 6, 3, 3, 1, 1, 65, 'Prefeitura Municipal de Campina Grande'),
    ('Arquiteto e Urbanista', 40, 5518.90, 2, 1, 1, 0, 0, 66, 'Prefeitura Municipal de Maceió'),
    ('Fiscal de Tributos', 40, 7400.00, 13, 9, 4, 3, 1, 66, 'Prefeitura Municipal de Maceió'),
    ('Cirurgião-Dentista', 40, 4006.95, 4, 2, 2, 1, 0, 66, 'Prefeitura Municipal de Maceió'),
    ('Engenheiro Civil', 40, 6950.00, 3, 1, 2, 1, 0, 67, 'Prefeitura Municipal de Imperatriz'),
    ('Guarda Civil Municipal', 40, 3150.00, 96, 68, 28, 19, 5, 67, 'Prefeitura Municipal de Imperatriz'),
    ('Cirurgião-Dentista', 40, 4123.71, 3, 0, 3, 1, 0, 68, 'Prefeitura Municipal de Parnaíba'),
    ('Enfermeiro (Estratégia Saúde da Família)', 40, 4500.00, 6, 4, 2, 1, 1, 68, 'Prefeitura Municipal de Parnaíba'),
    ('Técnico em Enfermagem', 40, 1800.00, 11, 0, 11, 2, 1, 68, 'Prefeitura Municipal de Parnaíba'),
    ('Psicólogo', 40, 3724.40, 4, 4, 0, 1, 0, 70, 'Prefeitura Municipal de Rio Branco'),
    ('Professor de Educação Física', 40, 4550.00, 4, 3, 1, 1, 0, 70, 'Prefeitura Municipal de Rio Branco'),
    ('Nutricionista', 40, 3259.45, 4, 2, 2, 1, 0, 70, 'Prefeitura Municipal de Rio Branco'),
    ('Procurador Municipal', 40, 10350.00, 4, 3, 1, 1, 0, 70, 'Prefeitura Municipal de Rio Branco'),
    ('Professor de Educação Básica - Anos Iniciais', 20, 3950.00, 53, 27, 26, 11, 3, 71, 'Prefeitura Municipal de Porto Velho'),
    ('Agente Comunitário de Saúde', 40, 2535.08, 26, 12, 14, 5, 2, 71, 'Prefeitura Municipal de Porto Velho'),
    ('Cirurgião-Dentista', 20, 6473.87, 2, 0, 2, 0, 0, 71, 'Prefeitura Municipal de Porto Velho'),
    ('Procurador Municipal', 40, 9040.88, 3, 0, 3, 1, 0, 71, 'Prefeitura Municipal de Porto Velho'),
    ('Assistente Social', 30, 5051.80, 15, 15, 0, 3, 1, 72, 'Secretaria de Estado da Saúde de São Paulo'),
    ('Enfermeiro', 40, 5788.25, 60, 60, 0, 12, 3, 72, 'Secretaria de Estado da Saúde de São Paulo'),
    ('Recepcionista', 40, 2504.83, 22, 14, 8, 4, 2, 72, 'Secretaria de Estado da Saúde de São Paulo'),
    ('Recepcionista', 30, 1904.33, 12, 6, 6, 2, 1, 73, 'Secretaria de Estado de Saúde de Minas Gerais'),
    ('Assistente Social', 30, 4000.00, 20, 8, 12, 4, 1, 73, 'Secretaria de Estado de Saúde de Minas Gerais'),
    ('Assistente Administrativo', 40, 2600.00, 12, 7, 5, 2, 1, 73, 'Secretaria de Estado de Saúde de Minas Gerais'),
    ('Farmacêutico', 40, 5607.66, 26, 0, 26, 5, 2, 73, 'Secretaria de Estado de Saúde de Minas Gerais'),
    ('Farmacêutico', 40, 6600.00, 14, 11, 3, 3, 1, 75, 'Secretaria de Estado de Saúde de Goiás'),
    ('Médico - Clínico Geral', 24, 13581.10, 27, 27, 0, 5, 2, 75, 'Secretaria de Estado de Saúde de Goiás'),
    ('Assistente Administrativo', 40, 2646.09, 76, 41, 35, 15, 4, 75, 'Secretaria de Estado de Saúde de Goiás'),
    ('Recepcionista', 40, 1950.00, 15, 7, 8, 3, 1, 75, 'Secretaria de Estado de Saúde de Goiás'),
    ('Fisioterapeuta', 30, 4450.00, 19, 19, 0, 4, 1, 75, 'Secretaria de Estado de Saúde de Goiás'),
    ('Assistente Social', 30, 3615.85, 8, 0, 8, 2, 1, 76, 'Secretaria de Estado de Saúde Pública do Pará'),
    ('Fisioterapeuta', 30, 3950.00, 15, 10, 5, 3, 1, 76, 'Secretaria de Estado de Saúde Pública do Pará'),
    ('Técnico em Enfermagem', 30, 2812.89, 175, 0, 175, 35, 9, 76, 'Secretaria de Estado de Saúde Pública do Pará'),
    ('Enfermeiro', 30, 4200.00, 78, 42, 36, 16, 4, 76, 'Secretaria de Estado de Saúde Pública do Pará'),
    ('Condutor de Ambulância', 40, 2189.81, 22, 9, 13, 4, 2, 76, 'Secretaria de Estado de Saúde Pública do Pará'),
    ('Farmacêutico', 40, 7000.00, 7, 0, 7, 1, 1, 78, 'Hospital Universitário da Universidade Federal do Piauí'),
    ('Nutricionista', 40, 6213.90, 3, 2, 1, 1, 0, 78, 'Hospital Universitário da Universidade Federal do Piauí'),
    ('Médico', 20, 13196.85, 19, 8, 11, 4, 1, 78, 'Hospital Universitário da Universidade Federal do Piauí'),
    ('Assistente Administrativo', 40, 3747.37, 19, 15, 4, 4, 1, 78, 'Hospital Universitário da Universidade Federal do Piauí'),
    ('Técnico em Enfermagem', 36, 4273.94, 26, 11, 15, 5, 2, 78, 'Hospital Universitário da Universidade Federal do Piauí'),
    ('Técnico em Análises Clínicas', 40, 3313.68, 3, 1, 2, 1, 0, 78, 'Hospital Universitário da Universidade Federal do Piauí'),
    ('Nutricionista', 40, 5500.00, 3, 2, 1, 1, 0, 80, 'Hospital Universitário da Universidade Federal do Amazonas'),
    ('Técnico em Enfermagem', 36, 3315.16, 65, 43, 22, 13, 4, 80, 'Hospital Universitário da Universidade Federal do Amazonas'),
    ('Farmacêutico', 40, 7400.00, 8, 4, 4, 2, 1, 80, 'Hospital Universitário da Universidade Federal do Amazonas'),
    ('Enfermeiro', 36, 7318.81, 21, 11, 10, 4, 2, 80, 'Hospital Universitário da Universidade Federal do Amazonas'),
    ('Técnico em Análises Clínicas', 40, 4350.00, 12, 8, 4, 2, 1, 80, 'Hospital Universitário da Universidade Federal do Amazonas'),
    ('Professor de Língua Inglesa', 20, 5550.00, 154, 113, 41, 31, 8, 81, 'Secretaria de Estado da Educação de São Paulo'),
    ('Secretário Escolar', 40, 2850.00, 48, 37, 11, 10, 3, 81, 'Secretaria de Estado da Educação de São Paulo'),
    ('Professor de Química', 20, 4584.01, 38, 27, 11, 8, 2, 81, 'Secretaria de Estado da Educação de São Paulo'),
    ('Técnico em Multimeios Didáticos', 40, 3516.64, 4, 2, 2, 1, 0, 81, 'Secretaria de Estado da Educação de São Paulo'),
    ('Professor de Língua Portuguesa', 40, 6750.00, 204, 82, 122, 41, 11, 81, 'Secretaria de Estado da Educação de São Paulo'),
    ('Coordenador Pedagógico', 40, 5600.00, 40, 0, 40, 8, 2, 81, 'Secretaria de Estado da Educação de São Paulo'),
    ('Secretário Escolar', 40, 4195.16, 47, 0, 47, 9, 3, 83, 'Secretaria de Estado da Educação do Paraná'),
    ('Técnico em Multimeios Didáticos', 40, 4104.35, 7, 5, 2, 1, 1, 83, 'Secretaria de Estado da Educação do Paraná'),
    ('Professor de História', 20, 5603.71, 161, 88, 73, 32, 9, 83, 'Secretaria de Estado da Educação do Paraná'),
    ('Analista Educacional', 40, 5250.00, 23, 16, 7, 5, 2, 83, 'Secretaria de Estado da Educação do Paraná'),
    ('Professor de Língua Portuguesa', 20, 6050.00, 117, 72, 45, 23, 6, 83, 'Secretaria de Estado da Educação do Paraná'),
    ('Professor de Matemática', 20, 5400.00, 26, 18, 8, 5, 2, 83, 'Secretaria de Estado da Educação do Paraná'),
    ('Professor de Língua Portuguesa', 40, 3650.00, 103, 0, 103, 21, 6, 85, 'Secretaria de Estado da Educação de Alagoas'),
    ('Professor de Língua Inglesa', 40, 3500.00, 24, 18, 6, 5, 2, 85, 'Secretaria de Estado da Educação de Alagoas'),
    ('Analista Educacional', 40, 5301.04, 4, 0, 4, 1, 0, 85, 'Secretaria de Estado da Educação de Alagoas'),
    ('Professor de Geografia', 40, 3850.00, 31, 21, 10, 6, 2, 85, 'Secretaria de Estado da Educação de Alagoas'),
    ('Analista Tributário', 40, 9675.49, 53, 32, 21, 11, 3, 87, 'Secretaria da Fazenda do Estado da Bahia'),
    ('Técnico Tributário', 40, 7172.58, 27, 0, 27, 5, 2, 87, 'Secretaria da Fazenda do Estado da Bahia'),
    ('Analista de Tecnologia da Informação', 40, 10400.00, 15, 11, 4, 3, 1, 88, 'Secretaria da Fazenda do Estado de Pernambuco'),
    ('Contador', 40, 7050.00, 6, 4, 2, 1, 1, 88, 'Secretaria da Fazenda do Estado de Pernambuco'),
    ('Assistente Fazendário', 40, 5602.86, 35, 25, 10, 7, 2, 89, 'Secretaria de Estado de Fazenda de Minas Gerais'),
    ('Analista Tributário', 40, 11875.60, 34, 34, 0, 7, 2, 89, 'Secretaria de Estado de Fazenda de Minas Gerais'),
    ('Técnico Tributário', 40, 8300.00, 11, 11, 0, 2, 1, 90, 'Secretaria Municipal da Fazenda de São Paulo'),
    ('Contador', 40, 9900.00, 6, 6, 0, 1, 1, 90, 'Secretaria Municipal da Fazenda de São Paulo'),
    ('Assistente Fazendário', 40, 5099.51, 37, 25, 12, 7, 2, 90, 'Secretaria Municipal da Fazenda de São Paulo'),
    ('Analista de Tecnologia da Informação', 40, 12682.58, 18, 0, 18, 4, 1, 90, 'Secretaria Municipal da Fazenda de São Paulo'),
    ('Perito Criminal', 40, 15650.00, 55, 24, 31, 11, 3, 93, 'Polícia Civil da Bahia'),
    ('Médico Legista', 40, 12700.00, 29, 0, 29, 6, 2, 93, 'Polícia Civil da Bahia'),
    ('Papiloscopista Policial', 40, 7159.77, 11, 6, 5, 2, 1, 93, 'Polícia Civil da Bahia'),
    ('Investigador de Polícia', 40, 8000.00, 92, 73, 19, 18, 5, 93, 'Polícia Civil da Bahia'),
    ('Oficial de Saúde da Polícia Militar - Médico', 40, 12000.00, 7, 7, 0, 1, 1, 94, 'Polícia Militar de Minas Gerais'),
    ('Cadete Oficial da Polícia Militar', 40, 8819.46, 114, 85, 29, 23, 6, 94, 'Polícia Militar de Minas Gerais'),
    ('Perito Criminal', 40, 17550.00, 42, 0, 42, 8, 3, 95, 'Polícia Civil do Estado de São Paulo'),
    ('Papiloscopista Policial', 40, 10807.71, 36, 19, 17, 7, 2, 95, 'Polícia Civil do Estado de São Paulo'),
    ('Analista de Execução Penal - Serviço Social', 40, 7300.00, 5, 4, 1, 1, 1, 96, 'Polícia Penal do Estado de Goiás'),
    ('Cadete Oficial Bombeiro Militar', 40, 10300.00, 74, 46, 28, 15, 4, 97, 'Corpo de Bombeiros Militar do Distrito Federal'),
    ('Oficial de Saúde Bombeiro Militar - Médico', 40, 13890.88, 3, 2, 1, 1, 0, 97, 'Corpo de Bombeiros Militar do Distrito Federal'),
    ('Oficial Bombeiro Militar - Engenheiro Civil', 40, 13701.34, 9, 9, 0, 2, 1, 97, 'Corpo de Bombeiros Militar do Distrito Federal'),
    ('Soldado Bombeiro Militar', 40, 5891.11, 456, 226, 230, 91, 23, 97, 'Corpo de Bombeiros Militar do Distrito Federal'),
    ('Técnico de Trânsito', 40, 3839.61, 36, 17, 19, 7, 2, 98, 'Departamento Estadual de Trânsito do Paraná'),
    ('Vistoriador Veicular', 40, 4046.47, 8, 8, 0, 2, 1, 98, 'Departamento Estadual de Trânsito do Paraná'),
    ('Soldado da Polícia Militar', 40, 4244.76, 1104, 1104, 0, 221, 56, 99, 'Polícia Militar do Pará'),
    ('Cadete Oficial da Polícia Militar', 40, 6100.00, 102, 81, 21, 20, 6, 99, 'Polícia Militar do Pará'),
    ('Professor EBTT - Área: Física', 40, 10450.00, 7, 7, 0, 1, 1, 102, 'Instituto Federal de Minas Gerais'),
    ('Assistente em Administração', 40, 3328.72, 19, 12, 7, 4, 1, 102, 'Instituto Federal de Minas Gerais'),
    ('Pedagogo', 40, 6554.47, 4, 3, 1, 1, 0, 102, 'Instituto Federal de Minas Gerais'),
    ('Professor EBTT - Área: Língua Portuguesa', 40, 7800.00, 5, 0, 5, 1, 1, 102, 'Instituto Federal de Minas Gerais'),
    ('Professor EBTT - Área: Química', 40, 7800.00, 1, 1, 0, 0, 0, 102, 'Instituto Federal de Minas Gerais'),
    ('Técnico em Tecnologia da Informação', 40, 3850.00, 10, 7, 3, 2, 1, 104, 'Universidade Federal do Pará'),
    ('Professor do Magistério Superior - Medicina', 40, 12914.75, 9, 5, 4, 2, 1, 104, 'Universidade Federal do Pará'),
    ('Professor do Magistério Superior - Direito', 40, 12949.83, 3, 2, 1, 1, 0, 104, 'Universidade Federal do Pará'),
    ('Técnico em Tecnologia da Informação', 40, 3533.14, 10, 7, 3, 2, 1, 105, 'Universidade Federal de Santa Catarina'),
    ('Assistente em Administração', 40, 3966.91, 29, 0, 29, 6, 2, 105, 'Universidade Federal de Santa Catarina'),
    ('Professor do Magistério Superior - Ciência da Computação', 40, 10000.00, 7, 4, 3, 1, 1, 105, 'Universidade Federal de Santa Catarina'),
    ('Técnico de Laboratório', 40, 4184.11, 14, 0, 14, 3, 1, 105, 'Universidade Federal de Santa Catarina'),
    ('Arquiteto e Urbanista', 40, 9550.00, 2, 1, 1, 0, 0, 107, 'Secretaria de Infraestrutura do Estado da Bahia'),
    ('Topógrafo', 40, 3450.00, 6, 6, 0, 1, 1, 107, 'Secretaria de Infraestrutura do Estado da Bahia'),
    ('Fiscal Ambiental', 40, 5639.65, 26, 0, 26, 5, 2, 109, 'Secretaria de Meio Ambiente e Sustentabilidade do Pará'),
    ('Assistente Administrativo', 40, 2650.00, 9, 6, 3, 2, 1, 109, 'Secretaria de Meio Ambiente e Sustentabilidade do Pará'),
    ('Analista Ambiental - Direito', 40, 7150.00, 2, 1, 1, 0, 0, 109, 'Secretaria de Meio Ambiente e Sustentabilidade do Pará'),
    ('Motorista', 40, 2950.00, 6, 4, 2, 1, 1, 109, 'Secretaria de Meio Ambiente e Sustentabilidade do Pará'),
    ('Analista Ambiental - Engenharia Florestal', 40, 10074.44, 16, 8, 8, 3, 1, 109, 'Secretaria de Meio Ambiente e Sustentabilidade do Pará'),
    ('Zootecnista', 40, 6429.04, 2, 1, 1, 0, 0, 112, 'Secretaria de Estado da Agricultura do Tocantins'),
    ('Motorista', 40, 2807.46, 7, 7, 0, 1, 1, 112, 'Secretaria de Estado da Agricultura do Tocantins'),
    ('Estatístico', 40, 8306.26, 2, 2, 0, 0, 0, 113, 'Secretaria de Administração do Estado da Bahia'),
    ('Contador', 40, 8350.00, 6, 4, 2, 1, 1, 113, 'Secretaria de Administração do Estado da Bahia'),
    ('Assistente Administrativo', 40, 2900.00, 52, 36, 16, 10, 3, 113, 'Secretaria de Administração do Estado da Bahia'),
    ('Técnico Administrativo', 40, 4500.00, 18, 14, 4, 4, 1, 113, 'Secretaria de Administração do Estado da Bahia'),
    ('Técnico Administrativo', 40, 4646.15, 66, 44, 22, 13, 4, 114, 'Secretaria de Estado de Gestão e Recursos Humanos do Espírito Santo'),
    ('Analista de Planejamento e Orçamento', 40, 7726.80, 5, 0, 5, 1, 1, 114, 'Secretaria de Estado de Gestão e Recursos Humanos do Espírito Santo'),
    ('Assistente Administrativo', 40, 2470.40, 11, 11, 0, 2, 1, 115, 'Secretaria de Estado da Administração do Piauí'),
    ('Contador', 40, 7395.23, 6, 0, 6, 1, 1, 115, 'Secretaria de Estado da Administração do Piauí'),
    ('Economista', 40, 8300.00, 4, 2, 2, 1, 0, 115, 'Secretaria de Estado da Administração do Piauí'),
    ('Analista de Planejamento e Orçamento', 40, 7386.57, 14, 11, 3, 3, 1, 115, 'Secretaria de Estado da Administração do Piauí'),
    ('Estatístico', 40, 8308.34, 1, 1, 0, 0, 0, 116, 'Secretaria de Estado de Administração do Acre'),
    ('Analista de Planejamento e Orçamento', 40, 7270.95, 10, 7, 3, 2, 1, 116, 'Secretaria de Estado de Administração do Acre'),
    ('Técnico Administrativo', 40, 4300.00, 49, 24, 25, 10, 3, 116, 'Secretaria de Estado de Administração do Acre'),
    ('Técnico Bancário Novo - Carreira Administrativa', 30, 3622.73, 872, 872, 0, 174, 44, 118, 'Caixa Econômica Federal'),
    ('Técnico Bancário Novo - Tecnologia da Informação', 30, 5150.00, 175, 124, 51, 35, 9, 118, 'Caixa Econômica Federal'),
    ('Médico do Trabalho', 20, 10350.00, 9, 9, 0, 2, 1, 118, 'Caixa Econômica Federal'),
    ('Técnico do Seguro Social', 40, 6550.00, 2321, 949, 1372, 464, 117, 120, 'Instituto Nacional do Seguro Social'),
    ('Analista do Seguro Social', 40, 8700.00, 256, 161, 95, 51, 13, 120, 'Instituto Nacional do Seguro Social'),
    ('Perito Médico Federal', 40, 15722.03, 845, 642, 203, 169, 43, 120, 'Instituto Nacional do Seguro Social'),
    ('Agente Censitário Supervisor', 40, 2039.11, 568, 255, 313, 114, 29, 122, 'Instituto Brasileiro de Geografia e Estatística'),
    ('Analista Censitário - Análise de Sistemas', 40, 8280.09, 77, 0, 77, 15, 4, 122, 'Instituto Brasileiro de Geografia e Estatística'),
    ('Agente Censitário Municipal', 40, 1850.00, 4454, 0, 4454, 891, 223, 122, 'Instituto Brasileiro de Geografia e Estatística');


