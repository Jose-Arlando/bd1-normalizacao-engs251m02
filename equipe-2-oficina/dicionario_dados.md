# Dicionário de dados

## Tabela: clientes
| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição |
|---|---|---|---|---|---|
| id_cliente | INT | 4 bytes | Não | PK, AUTO_INCREMENT | Identificador do cliente |
| cpf_cliente | CHAR | 14 caracteres | Não | UNIQUE | CPF do cliente |
| nome_cliente | VARCHAR | 60 caracteres | Não | — | Nome completo do cliente |

## Tabela: cliente_telefones
| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição |
|---|---|---|---|---|---|
| id_cliente | INT | 4 bytes | Não | PK, FK → clientes.id_cliente | Cliente dono do telefone |
| telefone | VARCHAR | 20 caracteres | Não | PK | Número de telefone |

## Tabela: veiculos
| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição |
|---|---|---|---|---|---|
| placa | CHAR | 7 caracteres | Não | PK | Placa do veículo |
| modelo | VARCHAR | 30 caracteres | Não | — | Modelo do veículo |
| id_cliente | INT | 4 bytes | Não | FK → clientes.id_cliente | Proprietário do veículo |

## Tabela: ordens_servico
| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição |
|---|---|---|---|---|---|
| num_os | INT | 4 bytes | Não | PK | Número da ordem de serviço |
| data_os | DATE | 3 bytes | Não | — | Data da ordem de serviço |
| placa | CHAR | 7 caracteres | Não | FK → veiculos.placa | Veículo atendido |

## Tabela: servicos
| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição |
|---|---|---|---|---|---|
| cod_servico | CHAR | 2 caracteres | Não | PK | Código do serviço |
| servico | VARCHAR | 40 caracteres | Não | UNIQUE | Nome do serviço |
| preco_servico | DECIMAL | 8,2 | Não | — | Preço do serviço |

## Tabela: os_servicos
| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição |
|---|---|---|---|---|---|
| num_os | INT | 4 bytes | Não | PK, FK → ordens_servico.num_os | Ordem de serviço |
| cod_servico | CHAR | 2 caracteres | Não | PK, FK → servicos.cod_servico | Serviço realizado |
| horas | DECIMAL | 4,1 | Não | — | Horas utilizadas no serviço |

## Tabela: mecanicos
| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição |
|---|---|---|---|---|---|
| id_mecanico | INT | 4 bytes | Não | PK, AUTO_INCREMENT | Identificador do mecânico |
| nome_mecanico | VARCHAR | 60 caracteres | Não | UNIQUE | Nome do mecânico |
| especialidade | VARCHAR | 30 caracteres | Não | — | Especialidade do mecânico |

## Tabela: os_mecanicos
| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição |
|---|---|---|---|---|---|
| num_os | INT | 4 bytes | Não | PK, FK → ordens_servico.num_os | Ordem de serviço |
| id_mecanico | INT | 4 bytes | Não | PK, FK → mecanicos.id_mecanico | Mecânico associado à ordem |

## Tabela: mecanico_cursos
| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição |
|---|---|---|---|---|---|
| id_mecanico | INT | 4 bytes | Não | PK, FK → mecanicos.id_mecanico | Mecânico |
| curso | VARCHAR | 40 caracteres | Não | PK | Curso do mecânico |

## Tabela: mecanico_turnos
| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição |
|---|---|---|---|---|---|
| id_mecanico | INT | 4 bytes | Não | PK, FK → mecanicos.id_mecanico | Mecânico |
| turno | VARCHAR | 10 caracteres | Não | PK | Turno de trabalho |
