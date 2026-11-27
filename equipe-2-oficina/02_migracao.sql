-- Migração dos dados das planilhas para as tabelas novas (INSERT ... SELECT)
USE normalizacao_oficina;

-- 1. Dados gerais e entidades principais a partir da `planilha`
INSERT INTO clientes (cpf_cliente, nome_cliente)
SELECT DISTINCT cpf_cliente, nome_cliente
FROM planilha;

-- Quebra múltiplos telefones separados por ';' em linhas individuais
INSERT INTO cliente_telefones (id_cliente, telefone)
SELECT DISTINCT
  c.id_cliente,
  TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p.telefones, ';', n.n), ';', -1)) AS telefone
FROM planilha p
JOIN clientes c ON c.cpf_cliente = p.cpf_cliente
JOIN (
  SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
) n
ON CHAR_LENGTH(p.telefones) - CHAR_LENGTH(REPLACE(p.telefones, ';', '')) >= n.n - 1
WHERE TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p.telefones, ';', n.n), ';', -1)) <> '';

INSERT INTO veiculos (placa, modelo, id_cliente)
SELECT DISTINCT p.placa, p.modelo, c.id_cliente
FROM planilha p
JOIN clientes c ON c.cpf_cliente = p.cpf_cliente;

INSERT INTO servicos (cod_servico, servico, preco_servico)
SELECT DISTINCT cod_servico, servico, preco_servico
FROM planilha;

INSERT INTO ordens_servico (num_os, data_os, placa)
SELECT DISTINCT num_os, data_os, placa
FROM planilha;

INSERT INTO os_servicos (num_os, cod_servico, horas)
SELECT DISTINCT num_os, cod_servico, horas
FROM planilha;

-- 2. Mecânicos e vínculos com OS a partir da `planilha_fnbc` (e mecânicos extras da `planilha_4fn`)
INSERT INTO mecanicos (nome_mecanico, especialidade)
SELECT DISTINCT f.mecanico, f.especialidade
FROM planilha_fnbc f
UNION
SELECT DISTINCT q.mecanico, 'Não informada'
FROM planilha_4fn q
WHERE NOT EXISTS (
  SELECT 1 FROM planilha_fnbc f2 WHERE f2.mecanico = q.mecanico
);

INSERT INTO os_mecanicos (num_os, id_mecanico)
SELECT DISTINCT f.num_os, m.id_mecanico
FROM planilha_fnbc f
JOIN mecanicos m ON m.nome_mecanico = f.mecanico;

-- 3. Decomposição em 4FN a partir da `planilha_4fn` (cursos e turnos independentes)
INSERT INTO mecanico_cursos (id_mecanico, curso)
SELECT DISTINCT m.id_mecanico, q.curso
FROM planilha_4fn q
JOIN mecanicos m ON m.nome_mecanico = q.mecanico;

INSERT INTO mecanico_turnos (id_mecanico, turno)
SELECT DISTINCT m.id_mecanico, q.turno
FROM planilha_4fn q
JOIN mecanicos m ON m.nome_mecanico = q.mecanico;
