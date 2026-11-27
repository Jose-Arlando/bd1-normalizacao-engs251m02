# Equipe 2: Oficina AutoCerto

**Nome do time:** oficinaaaaaaa 
| Nome | Usuário do GitHub |
| --- | --- |
| José | https://github.com/Jose-Arlando |
| Luiz | https://github.com/Dellosofelipe |
| Ana | https://github.com/anavitoria0401 |
| Méier | https://github.com/marcosantoniomeier-lab |
| diego | https://github.com/diego134-cmyk |
|reynaldo|https://github.com/ReyBoava|

## O cenário

O sistema da Oficina AutoCerto hoje é uma planilha. Rode o `00_planilha.sql` no MySQL: ele cria o banco `normalizacao_oficina` com 3 tabelas que reproduzem a planilha (também em `planilha.xlsx`).

| Tabela | O que guarda |
| --- | --- |
| `planilha` | Cada linha é um serviço feito em uma ordem de serviço (OS). Cada OS é de um veículo; cada veículo tem um dono. |
| `planilha_fnbc` | Regra: em cada OS, cada especialidade tem um único mecânico responsável; cada mecânico tem uma única especialidade. |
| `planilha_4fn` | Cada mecânico tem vários cursos e trabalha em vários turnos, sem relação entre curso e turno. |

> Apague as instruções entre colchetes e preencha cada seção.

## 1. Anomalias

[Usando linhas reais da `planilha`, dê um exemplo de cada anomalia.]

| Anomalia | Exemplo na planilha |
| --- | --- |
| Inserção | Não é possível cadastrar um novo serviço (ex.: S5, Balanceamento, 70.00) nem um novo cliente/veículo sem já ter uma ordem de serviço (num_os) associada; além disso, ao lançar uma nova linha para o cliente Marcos Reis (111.111.111-11), é preciso repetir seu nome (Marcos Reis) e seus telefones ((92) 98470-2110; (92) 98910-3230), como ocorre nas OSs 5001 e 5005. |
| Exclusão | Se a única linha da OS 5002 (5002, '2026-10-02', 'XYZ9K88', 'Onix LT', '222.222.222-22', 'Luana Prado', '(92) 98507-2221', 'S3', 'Troca de pastilhas', 260.0, 2.0) for removida, perdem-se os dados daquela ordem de serviço específica e a única ocorrência registrada da cliente Luana Prado e do veículo XYZ9K88 (Onix LT) nessa tabela. |
| Modificação | Para alterar o preço do serviço S1 (Troca de óleo) de 120.00 para 135.00, é preciso atualizar todas as linhas que contêm S1 (OSs 5001, 5003 e 5005); se uma delas for esquecida, o mesmo serviço aparecerá com preços diferentes na planilha. O mesmo ocorre ao alterar o nome ou telefone de Marcos Reis (111.111.111-11), presente nas linhas da OS 5001 e da OS 5005. |

## 2. Dependências funcionais da `planilha`

| Determinante | Determina | Tipo (total, parcial ou transitiva) |
| --- | --- | --- |
| `(num_os, cod_servico)` | `horas` | Total |
| `num_os` | `data_os, placa` | Parcial |
| `cod_servico` | `servico, preco_servico` | Parcial |
| `placa` | `modelo, cpf_cliente` | Transitiva |
| `cpf_cliente` | `nome_cliente` | Transitiva |

**Chave primária da `planilha`:** `(num_os, cod_servico)`

## 3. Normalização passo a passo

### 1. Primeira Forma Normal (1FN)

A tabela original não atendia completamente à Primeira Forma Normal, pois o atributo `telefones` armazenava mais de um número de telefone no mesmo campo, separados por ponto e vírgula.

Para corrigir esse problema, os telefones foram separados em registros individuais, criando a tabela `TELEFONE`, com os atributos `cpf_cliente` e `telefone`. Assim, cada campo passou a armazenar apenas um valor, tornando os dados atômicos e atendendo à 1FN.

### 2. Segunda Forma Normal (2FN)

Após adequar a tabela à 1FN, aplicamos a Segunda Forma Normal (2FN), eliminando as dependências parciais da chave primária composta `(num_os, cod_servico)`.

Identificamos que alguns atributos dependiam apenas de `num_os`, enquanto outros dependiam somente de `cod_servico`. Por isso, separamos essas informações em tabelas específicas, mantendo na tabela `OS_SERVICO` apenas os dados que dependem da chave composta.

A decomposição resultou nas seguintes tabelas:

**OS**
```sql
OS(
  num_os PK,
  data_os,
  placa FK
)
```

**VEICULO**
```sql
VEICULO(
  placa PK,
  modelo,
  cpf_cliente FK
)
```

**CLIENTE**
```sql
CLIENTE(
  cpf_cliente PK,
  nome_cliente
)
```

**TELEFONE**
```sql
TELEFONE(
  cpf_cliente FK,
  telefone,
  PK(cpf_cliente, telefone)
)
```

**SERVICO**
```sql
SERVICO(
  cod_servico PK,
  servico,
  preco_servico
)
```

**OS_SERVICO**
```sql
OS_SERVICO(
  num_os FK,
  cod_servico FK,
  horas,
  PK(num_os, cod_servico)
)
```

### 3. Terceira Forma Normal (3FN)

Na Terceira Forma Normal (3FN), eliminamos as dependências transitivas, separando as informações que dependiam indiretamente da chave primária.

Com isso, organizamos os dados em seis tabelas principais, cada uma com sua chave primária e seus respectivos atributos.

**Estrutura final das tabelas na 3FN:**

| Tabela | Chave primária | Campos |
| --- | --- | --- |
| CLIENTE | cpf_cliente | cpf_cliente, nome_cliente |
| TELEFONE | (cpf_cliente, telefone) | cpf_cliente, telefone |
| VEICULO | placa | placa, modelo, cpf_cliente |
| OS | num_os | num_os, data_os, placa |
| SERVICO | cod_servico | cod_servico, servico, preco_servico |
| OS_SERVICO | (num_os, cod_servico) | num_os, cod_servico, horas |

### Tabelas finais na 3FN

**CLIENTE**

| cpf_cliente | nome_cliente |
| --- | --- |
| 111.111.111-11 | Marcos Reis |
| 222.222.222-22 | Luana Prado |
| 333.333.333-33 | Otávio Melo |
| 444.444.444-44 | Sara Teles |

**TELEFONE**

| cpf_cliente | telefone |
| --- | --- |
| 111.111.111-11 | (92) 98470-2110 |
| 111.111.111-11 | (92) 98910-3230 |
| 222.222.222-22 | (92) 98507-2221 |
| 333.333.333-33 | (92) 98544-2332 |
| 444.444.444-44 | (92) 98581-2443 |
| 444.444.444-44 | (92) 99033-3599 |

**VEICULO**

| placa | modelo | cpf_cliente |
| --- | --- | --- |
| ABC1D23 | Gol 1.0 | 111.111.111-11 |
| XYZ9K88 | Onix LT | 222.222.222-22 |
| QWE4R56 | HB20 | 333.333.333-33 |
| JKL7M01 | Corolla | 444.444.444-44 |
| MNO2P34 | Uno Way | 111.111.111-11 |

**OS**

| num_os | data_os | placa |
| --- | --- | --- |
| 5001 | 01/10/2026 | ABC1D23 |
| 5002 | 02/10/2026 | XYZ9K88 |
| 5003 | 03/10/2026 | QWE4R56 |
| 5004 | 06/10/2026 | JKL7M01 |
| 5005 | 07/10/2026 | MNO2P34 |

**SERVICO**

| cod_servico | servico | preco_servico |
| --- | --- | --- |
| S1 | Troca de óleo | 120,00 |
| S2 | Alinhamento | 90,00 |
| S3 | Troca de pastilhas | 260,00 |
| S4 | Revisão elétrica | 180,00 |

**OS_SERVICO**

| num_os | cod_servico | horas |
| --- | --- | --- |
| 5001 | S1 | 1,0 |
| 5001 | S2 | 1,5 |
| 5002 | S3 | 2,0 |
| 5003 | S1 | 1,0 |
| 5003 | S4 | 3,0 |
| 5004 | S2 | 1,5 |
| 5004 | S3 | 2,5 |
| 5004 | S4 | 2,0 |
| 5005 | S1 | 1,0 |

**Conclusão:** Após a aplicação das três formas normais, os dados ficaram organizados em seis tabelas principais. Essa estrutura reduz a repetição de informações, evita anomalias e garante que os atributos dependam das chaves de suas respectivas tabelas.

## 4. FNBC: `planilha_fnbc`

- **Chaves candidatas:** `(num_os, especialidade)` e `(num_os, mecanico)`.
- **Dependência que viola a FNBC:** `mecanico → especialidade`, pois cada mecânico possui uma única especialidade, mas `mecanico` não é superchave da tabela.
- **Decomposição sem perda:**
  - `mecanico_especialidade` (**mecanico**, especialidade)
  - `os_mecanico` (**num_os**, **mecanico**)

## 5. 4FN: `planilha_4fn`

- Dependências multivaloradas: `mecanico` <=> `curso` e `mecanico` <=> `turno` (cada mecânico possui vários cursos e trabalha em vários turnos de forma independente, gerando combinações redundantes na mesma tabela).
- Decomposição:
  - `mecanico_curso` (**mecanico**, **curso**) — PK composta: `(mecanico, curso)`
  - `mecanico_turno` (**mecanico**, **turno**) — PK composta: `(mecanico, turno)`
## 6. Modelagem


### 6.1 Modelo conceitual (Peter Chen)

<img width="2100" height="1450" alt="modelo_conceitual" src="https://github.com/user-attachments/assets/d433ad7a-bb8b-4b47-a23d-e4f0650406bf" />

### 6.2 Modelo lógico (James Martin, pé de galinha)

CLIENTE(

  cpf_cliente PK,
  nome_cliente
)

TELEFONE(
  cpf_cliente PK, FK → CLIENTE.cpf_cliente,
  telefone PK
)

VEICULO(
  placa PK,
  modelo,
  cpf_cliente FK → CLIENTE.cpf_cliente
)

OS(
  num_os PK,
  data_os,
  placa FK → VEICULO.placa
)

SERVICO(
  cod_servico PK,
  servico,
  preco_servico
)

OS_SERVICO(
  num_os PK, FK → OS.num_os,
  cod_servico PK, FK → SERVICO.cod_servico,
  horas
)

<img width="2200" height="1540" alt="modelo_logico" src="https://github.com/user-attachments/assets/1fa77fee-0f8f-41b3-988a-eb93afc0bd79" />

## 7. Dicionário de dados

O dicionário de dados com todas as tabelas está em [dicionario_dados.md](dicionario_dados.md).

## 8. Prova de junção sem perda

Prova de junção sem perda

Planilha          Linhas originais   Linhas reconstruídas   Faltando   Sobrando
planilha                  9                  9                 0          0
planilha_fnbc             8                  8                 0          0
planilha_4fn              8                  8                 0          0

## 9. Desafio: uma decomposição errada

- **Duas tabelas da decomposição errada de `planilha_fnbc`:**
  - `os_especialidade` (**num_os**, **especialidade**)
  - `especialidade_mecanico` (**especialidade**, **mecanico**)

- **Consulta de junção (`JOIN`):**
```sql
SELECT
  oe.num_os,
  oe.especialidade,
  em.mecanico
FROM os_especialidade oe
JOIN especialidade_mecanico em
  ON oe.especialidade = em.especialidade;

```

- **Linhas falsas (tuplas espúrias):** gera **2 linhas falsas** (retorna 10 linhas no total contra as 8 linhas originais da `planilha_fnbc`). Como a especialidade `'Freios'` possui dois mecânicos distintos em ordens de serviço diferentes (`5002` com `'Igor'` e `5004` com `'Gabriel'`), a junção apenas por `especialidade` cria as duas combinações inexistentes: `(5002, 'Freios', 'Gabriel')` e `(5004, 'Freios', 'Igor')`.
