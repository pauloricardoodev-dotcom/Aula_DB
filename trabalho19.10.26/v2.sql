CREATE DATABASE IF NOT EXISTS db_loja;
USE db_loja;

CREATE TABLE IF NOT EXISTS clientes (
    id INT PRIMARY KEY,
    nome VARCHAR(255),
    doc VARCHAR(50) NOT NULL,
    CONSTRAINT uq_cliente_doc UNIQUE (doc)
);

CREATE TABLE IF NOT EXISTS produto (
    id INT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    preco DECIMAL(16,2),
    categoria VARCHAR(255),
    referencia INT,
    CONSTRAINT uq_produto_referencia UNIQUE (referencia)
);

CREATE TABLE IF NOT EXISTS vendedor (
    id INT PRIMARY KEY,
    nome VARCHAR(255),
    comissao DECIMAL(16,2)
);

CREATE TABLE IF NOT EXISTS estoque (
    id INT PRIMARY KEY,
    produtoId INT NOT NULL,
    quantidade INT,
    CONSTRAINT fk_estoque_produto
        FOREIGN KEY (produtoId) REFERENCES produto(id)
);

CREATE TABLE IF NOT EXISTS pagamento (
    id INT PRIMARY KEY,
    metodopag VARCHAR(50),
    state VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS venda (
    id INT PRIMARY KEY,
    clienteId INT,
    vendedorId INT,
    pagamentoId INT,
    produtoId INT,
    CONSTRAINT fk_venda_cliente
        FOREIGN KEY (clienteId) REFERENCES clientes(id),
    CONSTRAINT fk_venda_vendedor
        FOREIGN KEY (vendedorId) REFERENCES vendedor(id),
    CONSTRAINT fk_venda_pagamento
        FOREIGN KEY (pagamentoId) REFERENCES pagamento(id),
    CONSTRAINT fk_venda_produto
        FOREIGN KEY (produtoId) REFERENCES produto(id)
);

CREATE TABLE IF NOT EXISTS log_venda (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vendaId INT,
    datahora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_log_venda
        FOREIGN KEY (vendaId) REFERENCES venda(id)
);

CREATE TABLE IF NOT EXISTS log_pagamento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pagamentoId INT,
    status_anterior VARCHAR(50),
    status_novo VARCHAR(50),
    datahora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_log_pag_pagamento
        FOREIGN KEY (pagamentoId) REFERENCES pagamento(id)
);

DROP PROCEDURE IF EXISTS atualizar_estoque;

DELIMITER //

CREATE PROCEDURE atualizar_estoque(IN p_pagamentoId INT)
BEGIN
    DECLARE v_produtoId INT;

    SELECT produtoId
    INTO v_produtoId
    FROM venda
    WHERE pagamentoId = p_pagamentoId
    LIMIT 1;

    IF v_produtoId IS NOT NULL THEN
        UPDATE estoque
        SET quantidade = quantidade - 1
        WHERE produtoId = v_produtoId
        AND quantidade > 0;
    END IF;
END //

DELIMITER ;

DROP TRIGGER IF EXISTS trg_pagamento_concluido;

DELIMITER //

CREATE TRIGGER trg_pagamento_concluido
AFTER UPDATE ON pagamento
FOR EACH ROW
BEGIN
    IF NEW.state = 'PAGO' AND OLD.state <> 'PAGO' THEN

        INSERT INTO log_pagamento (
            pagamentoId,
            status_anterior,
            status_novo
        )
        VALUES (
            NEW.id,
            OLD.state,
            NEW.state
        );

        CALL atualizar_estoque(NEW.id);

    END IF;
END //

DELIMITER ;

DROP TRIGGER IF EXISTS trg_venda_criada;

DELIMITER //

CREATE TRIGGER trg_venda_criada
AFTER INSERT ON venda
FOR EACH ROW
BEGIN
    INSERT INTO log_venda (
        vendaId,
        datahora
    )
    VALUES (
        NEW.id,
        NOW()
    );
END //

DELIMITER ;

INSERT IGNORE INTO clientes (id, nome, doc)
VALUES
    (1, 'MATHEUS PEREIRA', '123456'),
    (2, 'PAULO RINALDI', '696969'),
    (3, 'VITOR VENTANIA', '98754'),
    (4, 'ENZO GOMES', '147258'),
    (5, 'JOAO RAFAEL', '65978'),
    (6, 'LUCAS ALVES', '69874'),
    (7, 'DANIEL LUCAS', '963214'),
    (8, 'VITORIA MACEDO', '451208'),
    (9, 'ROSA MARIA', '698201'),
    (10, 'MARCIA CRISTINA', '325874');

INSERT IGNORE INTO produto (id, nome, preco, categoria, referencia)
VALUES
    (1, 'CAMISA', 50.00, 'ROUPA', 123),
    (2, 'CALÇA', 100.00, 'ROUPA', 456),
    (3, 'CAMISETA', 50.00, 'ROUPA', 789),
    (4, 'MOLETON', 80.00, 'ROUPA', 101112),
    (5, 'BLUSA', 110.00, 'ROUPA', 102030),
    (6, 'SHORTS', 59.00, 'ROUPA', 405060),
    (7, 'BERMUDA', 79.00, 'ROUPA', 708090),
    (8, 'MEIA', 12.00, 'ROUPA', 111213),
    (9, 'CUECA', 10.00, 'ROUPA', 141516),
    (10, 'SOUTIEN', 69.00, 'LANGERIE', 171819);

INSERT IGNORE INTO vendedor (id, nome, comissao)
VALUES
    (1, 'MATHEUS', 0.10),
    (2, 'PAULO', 0.10),
    (3, 'VITOR', 0.10),
    (4, 'ENZO', 0.10),
    (5, 'JOAO', 0.10),
    (6, 'LUCAS', 0.10),
    (7, 'DANIEL', 0.10),
    (8, 'VITORIA', 0.10),
    (9, 'ROSA', 0.10),
    (10, 'MARCIA', 0.10);

INSERT IGNORE INTO estoque (id, produtoId, quantidade)
VALUES
    (1, 1, 10),
    (2, 2, 20),
    (3, 3, 30),
    (4, 4, 40),
    (5, 5, 50),
    (6, 6, 60),
    (7, 7, 70),
    (8, 8, 80),
    (9, 9, 90),
    (10, 10, 100);

INSERT IGNORE INTO pagamento (id, metodopag, state)
VALUES
    (1, 'CARTÃO', 'PENDENTE'),
    (2, 'DINHEIRO', 'PENDENTE'),
    (3, 'PIX', 'PENDENTE'),
    (4, 'CARTÃO', 'PENDENTE'),
    (5, 'DINHEIRO', 'PENDENTE'),
    (6, 'PIX', 'PENDENTE'),
    (7, 'CARTÃO', 'CANCELADO'),
    (8, 'DINHEIRO', 'CANCELADO'),
    (9, 'PIX', 'CANCELADO'),
    (10, 'CARTÃO', 'PAGO');

INSERT IGNORE INTO venda (id, clienteId, vendedorId, pagamentoId, produtoId)
VALUES
    (1, 1, 1, 1, 1),
    (2, 2, 2, 2, 2),
    (3, 3, 3, 3, 3),
    (4, 4, 4, 4, 4),
    (5, 5, 5, 5, 5),
    (6, 6, 6, 6, 6),
    (7, 7, 7, 7, 7),
    (8, 8, 8, 8, 8),
    (9, 9, 9, 9, 9),
    (10, 10, 10, 10, 10);

UPDATE produto SET preco = 52.50 WHERE id = 1;
UPDATE produto SET preco = 105.00 WHERE id = 2;
UPDATE produto SET preco = 52.50 WHERE id = 3;
UPDATE produto SET preco = 84.00 WHERE id = 4;
UPDATE produto SET preco = 115.50 WHERE id = 5;
UPDATE produto SET preco = 61.95 WHERE id = 6;
UPDATE produto SET preco = 82.95 WHERE id = 7;
UPDATE produto SET preco = 12.60 WHERE id = 8;
UPDATE produto SET preco = 10.50 WHERE id = 9;
UPDATE produto SET preco = 72.45 WHERE id = 10;

INSERT IGNORE INTO clientes (id, nome, doc)
VALUES
    (11, 'TMP', '991'),
    (12, 'TMP', '992'),
    (13, 'TMP', '993'),
    (14, 'TMP', '994'),
    (15, 'TMP', '995'),
    (16, 'TMP', '996'),
    (17, 'TMP', '997'),
    (18, 'TMP', '998'),
    (19, 'TMP', '999'),
    (20, 'TMP', '990');

DELETE FROM clientes WHERE id = 11;
DELETE FROM clientes WHERE id = 12;
DELETE FROM clientes WHERE id = 13;
DELETE FROM clientes WHERE id = 14;
DELETE FROM clientes WHERE id = 15;
DELETE FROM clientes WHERE id = 16;
DELETE FROM clientes WHERE id = 17;
DELETE FROM clientes WHERE id = 18;
DELETE FROM clientes WHERE id = 19;
DELETE FROM clientes WHERE id = 20;

SELECT * FROM clientes;
SELECT * FROM produto;
SELECT * FROM vendedor;
SELECT * FROM estoque;
SELECT * FROM pagamento;
SELECT * FROM venda;
SELECT * FROM log_venda;
SELECT * FROM log_pagamento;

SELECT
    pr.categoria AS Categoria,
    pr.nome AS Produto,
    pr.referencia AS Codigo_Referencia,
    e.quantidade AS Saldo_Estoque,
    (e.quantidade * pr.preco) AS Valor_Financeiro_Paralisado
FROM estoque e
INNER JOIN produto pr
    ON e.produtoId = pr.id
WHERE e.quantidade < 50
ORDER BY e.quantidade ASC;

