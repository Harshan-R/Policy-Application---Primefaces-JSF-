create database policy_app;
 
use policy_app;
 
-- Create Users Table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    role ENUM('admin', 'agent', 'customer') NOT NULL
);

 
-- Insert Sample Data into Users Table
INSERT INTO users (username, password, role) VALUES
('admin', 'adminpass', 'admin'),
('agent1', 'agentpass1', 'agent'),
('agent2', 'agentpass2', 'agent'),
('customer1', 'custpass1', 'customer'),
('customer2', 'custpass2', 'customer');
 
-- Create Policies Table
CREATE TABLE policies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    dob DATE NOT NULL,
    medical_history BOOLEAN NOT NULL,
    gender ENUM('male', 'female', 'binary') NOT NULL,
    address VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    coverage DECIMAL(10, 2),
    premium DECIMAL(10, 2),
    agent_approval ENUM('yes', 'no', 'pending') DEFAULT 'pending'
);
 
-- Insert Sample Data into Policies Table
INSERT INTO policies (customer_name, dob, medical_history, gender, address, email, phone, coverage, premium, agent_approval) VALUES
('John Doe', '1980-01-01', 0, 'male', '123 Main St', 'johndoe@example.com', '123-456-7890', 10000.00, 500.00, 'pending'),
('Jane Smith', '1975-05-15', 1, 'female', '456 Elm St', 'janesmith@example.com', '234-567-8901', 8000.00, 700.00, 'pending');
 
-- Create CNF Object Scripts Table
CREATE TABLE cnf_object_scripts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sql_text TEXT NOT NULL
);
 
-- Insert Sample SQL Scripts into CNF Object Scripts Table
INSERT INTO cnf_object_scripts (sql_text) VALUES
('SELECT * FROM policies WHERE id = ?'),
('UPDATE policies SET agent_approval = ? WHERE id = ?');
 
-- Create Script Assignment Table
CREATE TABLE script_assn (
    id INT AUTO_INCREMENT PRIMARY KEY,
    role ENUM('admin', 'agent', 'customer') NOT NULL,
    script_id INT,
    FOREIGN KEY (script_id) REFERENCES cnf_object_scripts(id)
);
 
-- Insert Sample Data into Script Assignment Table
INSERT INTO script_assn (role, script_id) VALUES
('admin', 1),
('agent', 2);
 
 
CREATE TABLE rejected_policies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    dob DATE NOT NULL,
    medical_history BOOLEAN NOT NULL,
    gender ENUM('male', 'female', 'binary') NOT NULL,
    address VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    coverage DECIMAL(10, 2),
    premium DECIMAL(10, 2),
    agent_approval ENUM('yes', 'no', 'pending')
);
 
INSERT INTO cnf_object_scripts (sql_text) VALUES
('INSERT INTO policies (customer_name, dob, medical_history, gender, address, email, phone, coverage, premium, agent_approval) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'),
('INSERT INTO rejected_policies (id, customer_name, dob, medical_history, gender, address, email, phone, coverage, premium, agent_approval) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'),
('SELECT COUNT(*) AS count FROM policies'),
('UPDATE policies SET customer_name = ?, dob = ?, medical_history = ?, gender = ?, address = ?, email = ?, phone = ?, coverage = ?, premium = ?, agent_approval = ? WHERE id = ?');
 
 
INSERT INTO cnf_object_scripts (sql_text) VALUES
('SELECT * FROM policies LIMIT ?, ?'),
('SELECT COUNT(*) FROM policies'),
('SELECT agent_approval, COUNT(*) FROM policies GROUP BY agent_approval'),
('UPDATE policies SET agent_approval = ? WHERE id = ?'),
('SELECT * FROM policies WHERE id = ?'),
('SELECT * FROM policies'),
('SELECT * FROM policies WHERE id = ?'),
('SELECT COUNT(*) AS count FROM policies'),
('SELECT COUNT(*) AS count FROM users'),
('SELECT SUM(coverage) AS total FROM policies'),
('SELECT SUM(premium) AS total FROM policies'),
('INSERT INTO policies (customer_name, dob, medical_history, gender, address, email, phone, coverage, premium, agent_approval) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)');
 
 
INSERT INTO cnf_object_scripts (sql_text) VALUES
('DELETE FROM rejected_policies'),
('INSERT INTO rejected_policies (customer_name, dob, medical_history, gender, address, email, phone, coverage, premium, agent_approval)
SELECT customer_name, dob, medical_history, gender, address, email, phone, coverage, premium, agent_approval
FROM policies
WHERE agent_approval = ?');
 
INSERT INTO rejected_policies (customer_name, dob, medical_history, gender, address, email, phone, coverage, premium, agent_approval)
SELECT customer_name, dob, medical_history, gender, address, email, phone, coverage, premium, agent_approval
FROM policies
WHERE agent_approval = 'no';
 
INSERT INTO cnf_object_scripts (sql_text) VALUES
('truncate rejected_policies');
 
truncate rejected_policies;
 
select * from users;
select * from policies;
select * from rejected_policies;
select * from cnf_object_scripts;
 
SET @sql_query = (
    SELECT SQL_TEXT
    FROM cnf_object_scripts 
    WHERE id = 5
);
 
-- Execute the fetched SQL query
PREPARE stmt FROM @sql_query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;