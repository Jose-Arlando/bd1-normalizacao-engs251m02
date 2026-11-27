# Dicionário de dados

## Tabela: `clientes`

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
|---|---|---|---|---|---|---|
| id_cliente | INT | Não se aplica (4 bytes) | Não | PK | Identificador do cliente | AUTO_INCREMENT |
| cpf_cliente | CHAR | 14 caracteres | Não | UNIQUE | CPF do cliente | Formato esperado: 000.000.000-00 |
| nome_cliente | VARCHAR | 60 caracteres | Não | | Nome completo do cliente | Máximo de 60 caracteres |

---

## Tabela: `cliente_telefones`

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
|---|---|---|---|---|---|---|
| id_cliente | INT | Não se aplica (4 bytes) | Não | PK / FK → clientes | Identificador do cliente | Deve existir em `clientes` |
| telefone | VARCHAR | 20 caracteres | Não | PK | Número de telefone do cliente | Um telefone por registro |

---

## Tabela: `veiculos`

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
|---|---|---|---|---|---|---|
| placa | CHAR | 7 caracteres | Não | PK | Placa do veículo | Padrão de 7 caracteres |
| modelo | VARCHAR | 30 caracteres | Não | | Modelo do veículo | Máximo de 30 caracteres |
| id_cliente | INT | Não se aplica (4 bytes) | Não | FK → clientes | Identificador do proprietário | Deve existir em `clientes` |

---

## Tabela: `servicos`

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
|---|---|---|---|---|---|---|
| cod_servico | CHAR | 2 caracteres | Não | PK | Código do serviço | Código com 2 caracteres |
| servico | VARCHAR | 40 caracteres | Não | UNIQUE | Nome ou descrição do serviço | Máximo de 40 caracteres |
| preco_servico | DECIMAL | 8,2 | Não | | Preço do serviço em reais | Valor monetário |

---

## Tabela: `mecanicos`

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
|---|---|---|---|---|---|---|
| id_mecanico | INT | Não se aplica (4 bytes) | Não | PK | Identificador do mecânico | AUTO_INCREMENT |
| nome_mecanico | VARCHAR | 60 caracteres | Não | UNIQUE | Nome do mecânico | Máximo de 60 caracteres |
| especialidade | VARCHAR | 30 caracteres | Não | | Especialidade do mecânico | Máximo de 30 caracteres |

---

## Tabela: `ordens_servico`

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
|---|---|---|---|---|---|---|
| num_os | INT | Não se aplica (4 bytes) | Não | PK | Número da ordem de serviço | Identificador único |
| data_os | DATE | Não se aplica (3 bytes) | Não | | Data da ordem de serviço | Formato AAAA-MM-DD |
| placa | CHAR | 7 caracteres | Não | FK → veiculos | Placa do veículo atendido | Deve existir em `veiculos` |

---

## Tabela: `os_servicos`

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
|---|---|---|---|---|---|---|
| num_os | INT | Não se aplica (4 bytes) | Não | PK / FK → ordens_servico | Número da ordem de serviço | Deve existir em `ordens_servico` |
| cod_servico | CHAR | 2 caracteres | Não | PK / FK → servicos | Código do serviço realizado | Deve existir em `servicos` |
| horas | DECIMAL | 4,1 | Não | | Quantidade de horas utilizadas | Uma casa decimal |

---

## Tabela: `os_mecanicos`

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
|---|---|---|---|---|---|---|
| num_os | INT | Não se aplica (4 bytes) | Não | PK / FK → ordens_servico | Número da ordem de serviço | Deve existir em `ordens_servico` |
| id_mecanico | INT | Não se aplica (4 bytes) | Não | PK / FK → mecanicos | Identificador do mecânico responsável | Deve existir em `mecanicos` |

---

## Tabela: `mecanico_cursos`

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
|---|---|---|---|---|---|---|
| id_mecanico | INT | Não se aplica (4 bytes) | Não | PK / FK → mecanicos | Identificador do mecânico | Deve existir em `mecanicos` |
| curso | VARCHAR | 40 caracteres | Não | PK | Curso realizado pelo mecânico | Máximo de 40 caracteres |

---

## Tabela: `mecanico_turnos`

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
|---|---|---|---|---|---|---|
| id_mecanico | INT | Não se aplica (4 bytes) | Não | PK / FK → mecanicos | Identificador do mecânico | Deve existir em `mecanicos` |
| turno | VARCHAR | 10 caracteres | Não | PK | Turno de trabalho do mecânico | Valores utilizados: Manhã, Tarde e Noite |
