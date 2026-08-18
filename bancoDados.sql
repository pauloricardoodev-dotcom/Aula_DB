CREATE DATABASE IF NOT EXISTS mvpe;

USE mvpe;

CREATE TABLE IF NOT EXISTS clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255),
    doc VARCHAR(50),
    comissao DECIMAL(16,2)
);

CREATE TABLE IF NOT EXISTS produto (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255),
    preco DECIMAL(16,2),
    categoria VARCHAR(255),
    referencia INT UNIQUE
);

CREATE TABLE IF NOT EXISTS vendedor (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255),
    comissao DECIMAL(16,2)
);

CREATE TABLE IF NOT EXISTS estoque (
    id INT AUTO_INCREMENT PRIMARY KEY,
    produtoId INT NOT NULL,
    quantidade INT,
    FOREIGN KEY(produtoId) REFERENCES produto(id)
);

CREATE TABLE IF NOT EXISTS pagamento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    metodopag VARCHAR(50),
    state VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS venda (
    id INT AUTO_INCREMENT PRIMARY KEY,
    clienteId INT,FOREIGN KEY(clienteId) REFERENCES clientes(id),
    vendedorId INT, FOREIGN KEY(vendedorId) REFERENCES vendedor(id),
    pagamentoId INT, FOREIGN KEY(pagamentoId) REFERENCES pagamento(id),
    produtoId INT,FOREIGN KEY(produtoId) REFERENCES produto(id)      
    
);



