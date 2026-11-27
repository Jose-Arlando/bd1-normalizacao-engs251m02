-- Reconstrução das planilhas originais a partir das tabelas normalizadas
USE normalizacao_oficina;

-- =====================================================
-- 1. Reconstrução da planilha original
-- =====================================================

DROP TEMPORARY TABLE IF EXISTS recon_planilha;

CREATE TEMPORARY TABLE recon_planilha AS
SELECT
    os.num_os,
    os.data_os,
    v.placa,
    v.modelo,
    c.cpf_cliente,
    c.nome_cliente,
    (
        SELECT GROUP_CONCAT(
            DISTINCT ct.telefone
            ORDER BY ct.telefone
            SEPARATOR '; '
        )
        FROM cliente_telefones ct
        WHERE ct.id_cliente = c.id_cliente
    ) AS telefones,
    s.cod_servico,
    s.servico,
    s.preco_servico,
    oss.horas
FROM ordens_servico os
JOIN veiculos v
    ON v.placa = os.placa
JOIN clientes c
    ON c.id_cliente = v.id_cliente
JOIN os_servicos oss
    ON oss.num_os = os.num_os
JOIN servicos s
    ON s.cod_servico = oss.cod_servico;

-- =====================================================
-- 2. Reconstrução da planilha_fnbc
-- =====================================================

DROP TEMPORARY TABLE IF EXISTS recon_planilha_fnbc;

CREATE TEMPORARY TABLE recon_planilha_fnbc AS
SELECT DISTINCT
    om.num_os,
    m.especialidade,
    m.nome_mecanico AS mecanico
FROM os_mecanicos om
JOIN mecanicos m
    ON m.id_mecanico = om.id_mecanico;

-- =====================================================
-- 3. Reconstrução da planilha_4fn
-- =====================================================

DROP TEMPORARY TABLE IF EXISTS recon_planilha_4fn;

CREATE TEMPORARY TABLE recon_planilha_4fn AS
SELECT DISTINCT
    m.nome_mecanico AS mecanico,
    mc.curso,
    mt.turno
FROM mecanicos m
JOIN mecanico_cursos mc
    ON mc.id_mecanico = m.id_mecanico
JOIN mecanico_turnos mt
    ON mt.id_mecanico = m.id_mecanico;

-- =====================================================
-- 4. Comparação da planilha original
-- =====================================================

SELECT
    'planilha: reconstruída que não existe na original' AS verificacao,
    COUNT(*) AS divergencias
FROM recon_planilha r
WHERE NOT EXISTS (
    SELECT 1
    FROM planilha p
    WHERE p.num_os <=> r.num_os
      AND p.data_os <=> r.data_os
      AND p.placa <=> r.placa
      AND p.modelo <=> r.modelo
      AND p.cpf_cliente <=> r.cpf_cliente
      AND p.nome_cliente <=> r.nome_cliente
      AND p.telefones <=> r.telefones
      AND p.cod_servico <=> r.cod_servico
      AND p.servico <=> r.servico
      AND p.preco_servico <=> r.preco_servico
      AND p.horas <=> r.horas
)

UNION ALL

SELECT
    'planilha: original que não foi reconstruída',
    COUNT(*)
FROM planilha p
WHERE NOT EXISTS (
    SELECT 1
    FROM recon_planilha r
    WHERE p.num_os <=> r.num_os
      AND p.data_os <=> r.data_os
      AND p.placa <=> r.placa
      AND p.modelo <=> r.modelo
      AND p.cpf_cliente <=> r.cpf_cliente
      AND p.nome_cliente <=> r.nome_cliente
      AND p.telefones <=> r.telefones
      AND p.cod_servico <=> r.cod_servico
      AND p.servico <=> r.servico
      AND p.preco_servico <=> r.preco_servico
      AND p.horas <=> r.horas
);

-- =====================================================
-- 5. Comparação da planilha_fnbc
-- =====================================================

SELECT
    'planilha_fnbc: reconstruída que não existe na original' AS verificacao,
    COUNT(*) AS divergencias
FROM recon_planilha_fnbc r
WHERE NOT EXISTS (
    SELECT 1
    FROM planilha_fnbc p
    WHERE p.num_os <=> r.num_os
      AND p.especialidade <=> r.especialidade
      AND p.mecanico <=> r.mecanico
)

UNION ALL

SELECT
    'planilha_fnbc: original que não foi reconstruída',
    COUNT(*)
FROM planilha_fnbc p
WHERE NOT EXISTS (
    SELECT 1
    FROM recon_planilha_fnbc r
    WHERE p.num_os <=> r.num_os
      AND p.especialidade <=> r.especialidade
      AND p.mecanico <=> r.mecanico
);

-- =====================================================
-- 6. Comparação da planilha_4fn
-- =====================================================

SELECT
    'planilha_4fn: reconstruída que não existe na original' AS verificacao,
    COUNT(*) AS divergencias
FROM recon_planilha_4fn r
WHERE NOT EXISTS (
    SELECT 1
    FROM planilha_4fn p
    WHERE p.mecanico <=> r.mecanico
      AND p.curso <=> r.curso
      AND p.turno <=> r.turno
)

UNION ALL

SELECT
    'planilha_4fn: original que não foi reconstruída',
    COUNT(*)
FROM planilha_4fn p
WHERE NOT EXISTS (
    SELECT 1
    FROM recon_planilha_4fn r
    WHERE p.mecanico <=> r.mecanico
      AND p.curso <=> r.curso
      AND p.turno <=> r.turno
);

-- =====================================================
-- 7. Conferência da quantidade de registros
-- =====================================================

SELECT 'planilha original' AS tabela, COUNT(*) AS quantidade
FROM planilha
UNION ALL
SELECT 'planilha reconstruída', COUNT(*)
FROM recon_planilha
UNION ALL
SELECT 'planilha_fnbc original', COUNT(*)
FROM planilha_fnbc
UNION ALL
SELECT 'planilha_fnbc reconstruída', COUNT(*)
FROM recon_planilha_fnbc
UNION ALL
SELECT 'planilha_4fn original', COUNT(*)
FROM planilha_4fn
UNION ALL
SELECT 'planilha_4fn reconstruída', COUNT(*)
FROM recon_planilha_4fn;
