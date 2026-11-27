-- Modelo normalizado: CREATE TABLE de todas as tabelas, com PK e FK
USE normalizacao_oficina;

CREATE TABLE clientes (
  id_cliente INT AUTO_INCREMENT PRIMARY KEY,
  cpf_cliente CHAR(14) NOT NULL UNIQUE,
  nome_cliente VARCHAR(60) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE cliente_telefones (
  id_cliente INT NOT NULL,
  telefone VARCHAR(20) NOT NULL,
  PRIMARY KEY (id_cliente, telefone),
  CONSTRAINT fk_cli_tel_cliente
    FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE veiculos (
  placa CHAR(7) PRIMARY KEY,
  modelo VARCHAR(30) NOT NULL,
  id_cliente INT NOT NULL,
  CONSTRAINT fk_veiculos_cliente
    FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE servicos (
  cod_servico CHAR(2) PRIMARY KEY,
  servico VARCHAR(40) NOT NULL UNIQUE,
  preco_servico DECIMAL(8,2) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE mecanicos (
  id_mecanico INT AUTO_INCREMENT PRIMARY KEY,
  nome_mecanico VARCHAR(60) NOT NULL UNIQUE,
  especialidade VARCHAR(30) NOT NULL
) ENGINE=InnoDB;



CREATE TABLE ordens_servico (
  num_os INT PRIMARY KEY,
  data_os DATE NOT NULL,
  placa CHAR(7) NOT NULL,
  CONSTRAINT fk_os_veiculo
    FOREIGN KEY (placa) REFERENCES veiculos (placa)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE os_servicos (
  num_os INT NOT NULL,
  cod_servico CHAR(2) NOT NULL,
  horas DECIMAL(4,1) NOT NULL,
  PRIMARY KEY (num_os, cod_servico),
  CONSTRAINT fk_oss_os
    FOREIGN KEY (num_os) REFERENCES ordens_servico (num_os)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_oss_servico
    FOREIGN KEY (cod_servico) REFERENCES servicos (cod_servico)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;




CREATE TABLE os_mecanicos (
  num_os INT NOT NULL,
  id_mecanico INT NOT NULL,
  PRIMARY KEY (num_os, id_mecanico),
  CONSTRAINT fk_osm_os
    FOREIGN KEY (num_os) REFERENCES ordens_servico (num_os)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_osm_mecanico
    FOREIGN KEY (id_mecanico) REFERENCES mecanicos (id_mecanico)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;




CREATE TABLE mecanico_cursos (
  id_mecanico INT NOT NULL,
  curso VARCHAR(40) NOT NULL,
  PRIMARY KEY (id_mecanico, curso),
  CONSTRAINT fk_mc_mecanico
    FOREIGN KEY (id_mecanico) REFERENCES mecanicos (id_mecanico)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE mecanico_turnos (
  id_mecanico INT NOT NULL,
  turno VARCHAR(10) NOT NULL,
  PRIMARY KEY (id_mecanico, turno),
  CONSTRAINT fk_mt_mecanico
    FOREIGN KEY (id_mecanico) REFERENCES mecanicos (id_mecanico)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;




INSERT INTO clientes (cpf_cliente, nome_cliente)
SELECT DISTINCT cpf_cliente, nome_cliente
FROM planilha;



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

INSERT INTO mecanico_cursos (id_mecanico, curso)
SELECT DISTINCT m.id_mecanico, q.curso
FROM planilha_4fn q
JOIN mecanicos m ON m.nome_mecanico = q.mecanico;

INSERT INTO mecanico_turnos (id_mecanico, turno)
SELECT DISTINCT m.id_mecanico, q.turno
FROM planilha_4fn q
JOIN mecanicos m ON m.nome_mecanico = q.mecanico;
