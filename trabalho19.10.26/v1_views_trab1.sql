-- Trabalho 1 - 2º Bimestre
-- Views criadas sobre o banco db_loja (v1.sql)

USE db_loja;

-- Dados "sem par" para as views 01, 02 e 04:
-- um cliente que ainda não comprou e uma venda sem cliente cadastrado.
-- INSERT IGNORE: se o script rodar de novo, não dá erro de id repetido.
INSERT IGNORE INTO clientes (id, nome, doc)
VALUES (11, 'CARLOS EDUARDO', '852963');

INSERT IGNORE INTO pagamento (id, metodopag, state)
VALUES (11, 'DINHEIRO', 'PENDENTE');

INSERT IGNORE INTO venda (id, clienteId, vendedorId, pagamentoId, produtoId)
VALUES (11, NULL, 1, 11, 1);


-- 01: todos os clientes e o que cada um comprou
-- (quem nunca comprou aparece com a venda em NULL)
CREATE OR REPLACE VIEW vw_01_left AS
SELECT
    c.id AS cliente_id,
    c.nome AS cliente,
    v.id AS venda_id,
    p.nome AS produto
FROM clientes c
LEFT JOIN venda v
    ON v.clienteId = c.id
LEFT JOIN produto p
    ON p.id = v.produtoId;


-- 02: clientes cadastrados que nunca fizeram uma compra
CREATE OR REPLACE VIEW vw_02_sem_par AS
SELECT
    c.id AS cliente_id,
    c.nome AS cliente,
    c.doc
FROM clientes c
LEFT JOIN venda v
    ON v.clienteId = c.id
WHERE v.id IS NULL;


-- 03: produtos da mesma categoria com o mesmo preço
CREATE OR REPLACE VIEW vw_03_self AS
SELECT
    p1.categoria,
    p1.nome AS produto_1,
    p2.nome AS produto_2,
    p1.preco
FROM produto p1
INNER JOIN produto p2
    ON p1.categoria = p2.categoria
    AND p1.preco = p2.preco
    AND p1.id < p2.id;


-- 04: clientes sem compra e vendas sem cliente, juntos
CREATE OR REPLACE VIEW vw_04_full AS
SELECT
    c.id AS cliente_id,
    c.nome AS cliente,
    v.id AS venda_id
FROM clientes c
LEFT JOIN venda v
    ON v.clienteId = c.id
UNION
SELECT
    c.id AS cliente_id,
    c.nome AS cliente,
    v.id AS venda_id
FROM clientes c
RIGHT JOIN venda v
    ON v.clienteId = c.id;


-- 05: faturamento por categoria, só das que passaram de R$ 100
CREATE OR REPLACE VIEW vw_05_having AS
SELECT
    p.categoria,
    COUNT(v.id) AS qtd_vendas,
    SUM(p.preco) AS faturamento
FROM venda v
INNER JOIN produto p
    ON p.id = v.produtoId
GROUP BY p.categoria
HAVING SUM(p.preco) > 100;


-- 06: os 3 produtos mais caros da loja
CREATE OR REPLACE VIEW vw_06_top3 AS
SELECT
    nome AS produto,
    categoria,
    preco
FROM produto
ORDER BY preco DESC
LIMIT 3;


-- 07: produtos com preço acima da média
CREATE OR REPLACE VIEW vw_07_subconsulta AS
SELECT
    nome AS produto,
    preco
FROM produto
WHERE preco > (SELECT AVG(preco) FROM produto);


-- 08: comissão de cada vendedor sobre as vendas já pagas
CREATE OR REPLACE VIEW vw_08_cte AS
WITH vendas_pagas AS (
    SELECT
        v.vendedorId,
        SUM(pr.preco) AS total_vendido
    FROM venda v
    INNER JOIN pagamento pg
        ON pg.id = v.pagamentoId
    INNER JOIN produto pr
        ON pr.id = v.produtoId
    WHERE pg.state = 'PAGO'
    GROUP BY v.vendedorId
)
SELECT
    ve.nome AS vendedor,
    vp.total_vendido,
    vp.total_vendido * ve.comissao AS comissao
FROM vendas_pagas vp
INNER JOIN vendedor ve
    ON ve.id = vp.vendedorId;


-- 09: ranking de preço dentro de cada categoria
-- (CAMISA e CAMISETA têm o mesmo preço e empatam)
CREATE OR REPLACE VIEW vw_09_ranking AS
SELECT
    categoria,
    nome AS produto,
    preco,
    RANK() OVER (PARTITION BY categoria ORDER BY preco DESC) AS posicao
FROM produto;


-- 10: faturamento acumulado, venda após venda
CREATE OR REPLACE VIEW vw_10_vizinho AS
SELECT
    v.id AS venda_id,
    p.nome AS produto,
    p.preco,
    SUM(p.preco) OVER (ORDER BY v.id) AS faturamento_acumulado
FROM venda v
INNER JOIN produto p
    ON p.id = v.produtoId;
