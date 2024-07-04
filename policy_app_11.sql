CREATE DATABASE IF NOT EXISTS policy_app_11;
USE policy_app_11;
-- drop database policy_app;

-- Drop existing tables if they exist for a clean slate
DROP TABLE IF EXISTS audit_log, claims, payments, rejected_policies, script_assn, cnf_object_scripts, policies, users, sessions;

-- Create Users Table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    username VARCHAR(50) NOT NULL unique,
    password VARCHAR(100) NOT NULL,
    role ENUM('admin', 'agent', 'customer') NOT NULL,
    created_by INT,
    updated_by INT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert Sample Data into Users Table
INSERT INTO users (email, username, password, role) VALUES
('admin@example.com', 'admin', 'adminpass', 'admin'),
('agent1@example.com', 'agent1', 'agentpass1', 'agent'),
('agent2@example.com', 'agent2', 'agentpass2', 'agent'),
('customer1@example.com', 'customer1', 'custpass1', 'customer'),
('customer2@example.com', 'customer2', 'custpass2', 'customer');

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
    policy_type ENUM('Auto', 'Life', 'Health', 'Liability', 'Home') NOT NULL,
    policy_start_date DATE NOT NULL,
    policy_end_date DATE NOT NULL,
    coverage DECIMAL(10, 2),
    premium DECIMAL(10, 2),
    agent_approval ENUM('yes', 'no', 'pending') DEFAULT 'pending',
    created_by INT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by INT,
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert Sample Data into Policies Table
INSERT INTO policies (customer_name, dob, medical_history, gender, address, email, phone, policy_type, policy_start_date, policy_end_date, coverage, premium, agent_approval) VALUES
('John Doe', '1980-01-01', 0, 'male', '123 Main St', 'johndoe@example.com', '123-456-7890', 'Life', '2023-01-01', '2024-01-01', 10000.00, 500.00, 'pending'),
('Jane Smith', '1975-05-15', 1, 'female', '456 Elm St', 'janesmith@example.com', '234-567-8901', 'Health', '2023-01-01', '2024-01-01', 8000.00, 700.00, 'pending');

-- Create Rejected Policies Table
CREATE TABLE rejected_policies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    dob DATE NOT NULL,
    medical_history BOOLEAN NOT NULL,
    gender ENUM('male', 'female', 'binary') NOT NULL,
    address VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    policy_type ENUM('Auto', 'Life', 'Health', 'Liability', 'Home') NOT NULL,
    policy_start_date DATE NOT NULL,
    policy_end_date DATE NOT NULL,
    coverage DECIMAL(10, 2),
    premium DECIMAL(10, 2),
    agent_approval ENUM('yes', 'no', 'pending'),
    created_by INT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by INT,
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create CNF Object Scripts Table
CREATE TABLE cnf_object_scripts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sql_text TEXT NOT NULL,
    description VARCHAR(255),
    created_by INT,
    updated_by INT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert Sample SQL Scripts into CNF Object Scripts Table
INSERT INTO cnf_object_scripts (sql_text, description, created_by, updated_by) VALUES
('SELECT * FROM policies WHERE id = ?', 'Select policy by ID', 1, 1),
('UPDATE policies SET agent_approval = ? WHERE id = ?', 'Update agent approval for policy', 1, 1);

-- Create Script Assignment Table
CREATE TABLE script_assn (
    id INT AUTO_INCREMENT PRIMARY KEY,
    role ENUM('admin', 'agent', 'customer') NOT NULL,
    script_id INT,
    created_by INT,
    updated_by INT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (script_id) REFERENCES cnf_object_scripts(id)
);

-- Insert Sample Data into Script Assignment Table
INSERT INTO script_assn (role, script_id, created_by, updated_by) VALUES
('admin', 1, 1, 1),
('agent', 2, 1, 1);

-- Create Sessions Table
CREATE TABLE sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    logout_time TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Create Payments Table
CREATE TABLE payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    policy_id INT,
    total_premium_amount DECIMAL(10, 2),
    monthly_premium DECIMAL(10, 2),
    bank_account_payer VARCHAR(50),
    bank_account_payee VARCHAR(50),
    created_by INT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by INT,
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (policy_id) REFERENCES policies(id)
);
INSERT INTO payments (policy_id, total_premium_amount, monthly_premium, bank_account_payer, bank_account_payee, created_by, updated_by)
VALUES
(1, 1200.00, 100.00, 'JohnDoe@fidelity', 'MiltonLife@okhdfc', 1, 1),
(2, 2400.00, 200.00, 'JaneSmith@SocieteGenerale', 'MiltonLife@okhdfc', 2, 2);


-- Create Claims Table
CREATE TABLE claims (
    id INT AUTO_INCREMENT PRIMARY KEY,
    policy_id INT,
    claim_amount DECIMAL(10, 2),
    claim_date DATE,
    resolution_date DATE,
    claim_status ENUM('Approved', 'Rejected', 'Pending') DEFAULT 'Pending',
    payment_made BOOLEAN,
    created_by INT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by INT,
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (policy_id) REFERENCES policies(id)
);

INSERT INTO claims (policy_id, claim_amount, claim_date, resolution_date, claim_status, payment_made, created_by, updated_by)
VALUES
(1, 500.00, '2022-01-01', '2022-01-15', 'Approved', 1, 1, 1),
(2, 200.00, '2022-02-01', NULL, 'Pending', 0, 2, 2);

INSERT INTO claims (policy_id, claim_amount, claim_date, resolution_date, claim_status, payment_made, created_by, updated_by) VALUES
(17, 800.00, '2022-03-01', '2022-03-20', 'Approved', 1, 3, 3),  -- Light Yagami (Death Note)
(18, 300.00, '2022-04-01', NULL, 'Pending', 0, 4, 4),  -- Lelouch vi Britannia (Code Geass)
(19, 1000.00, '2022-05-01', '2022-05-15', 'Approved', 1, 5, 5),  -- Edward Elric (Fullmetal Alchemist)
(20, 400.00, '2022-06-01', NULL, 'Pending', 0, 6, 6),  -- Naruto Uzumaki (Naruto)
(22, 600.00, '2022-07-01', '2022-07-20', 'Approved', 1, 7, 7),  -- Goku (Dragon Ball)
(24, 250.00, '2022-08-01', NULL, 'Pending', 0, 8, 8),  -- Roronoa Zoro (One Piece)
(29, 900.00, '2022-09-01', '2022-09-15', 'Approved', 1, 9, 9),  -- Kousei Arima (Your Lie in April)
(26, 700.00, '2022-10-01', NULL, 'Pending', 0, 10, 10),  -- Eren Yeager (Attack on Titan)
(27, 1200.00, '2022-11-01', '2022-11-20', 'Approved', 1, 11, 11),  -- Mikasa Ackerman (Attack on Titan)
(28, 1500.00, '2022-12-01', NULL, 'Pending', 0, 12, 12);  -- Armin Arlert (Attack on Titan)

-- Create Audit Log Table
CREATE TABLE audit_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(255),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Insert Additional Sample Data into CNF Object Scripts Table
INSERT INTO cnf_object_scripts (sql_text, description, created_by, updated_by) VALUES
('INSERT INTO policies (customer_name, dob, medical_history, gender, address, email, phone, policy_type, policy_start_date, policy_end_date, coverage, premium, agent_approval) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', 'Insert new policy', 1, 1),
('INSERT INTO rejected_policies (customer_name, dob, medical_history, gender, address, email, phone, policy_type, policy_start_date, policy_end_date, coverage, premium, agent_approval) SELECT customer_name, dob, medical_history, gender, address, email, phone, policy_type, policy_start_date, policy_end_date, coverage, premium, agent_approval FROM policies WHERE agent_approval = ?', 'Move policy to rejected', 1, 1),
('SELECT COUNT(*) AS count FROM policies', 'Count policies', 1, 1),
('UPDATE policies SET customer_name = ?, dob = ?, medical_history = ?, gender = ?, address = ?, email = ?, phone = ?, coverage = ?, premium = ?, agent_approval = ? WHERE id = ?', 'Update policy details', 1, 1);

-- Insert Additional Data for New Tables
INSERT INTO rejected_policies (customer_name, dob, medical_history, gender, address, email, phone, policy_type, policy_start_date, policy_end_date, coverage, premium, agent_approval, created_by, updated_by) SELECT customer_name, dob, medical_history, gender, address, email, phone, policy_type, policy_start_date, policy_end_date, coverage, premium, 'no', 1, 1 FROM policies WHERE agent_approval = 'no';

INSERT INTO cnf_object_scripts (sql_text, description, created_by, updated_by) VALUES
('SELECT * FROM policies', 'Select all policy', 1, 1);

-- INSERT INTO users (username, password, role,email) VALUES ('nam', 'LT', 'customer','abcmail@1');

INSERT INTO policies (customer_name, dob, medical_history, gender, address, email, phone, policy_type, policy_start_date, policy_end_date, coverage, premium, agent_approval) VALUES
('Light Yagami', '1986-02-28', 0, 'male', 'Death Note St', 'lightyagami@deathnote.com', '111-222-3333', 'Life', '2022-01-01', '2023-01-01', 15000.00, 800.00, 'yes'),
('Lelouch vi Britannia', '1995-08-05', 1, 'male', 'Code Geass St', 'lelouch@codegeass.com', '444-555-6666', 'Auto', '2022-06-01', '2023-06-01', 20000.00, 1200.00, 'no'),
('Edward Elric', '1999-02-10', 0, 'male', 'Fullmetal Alchemist St', 'edward@fma.com', '777-888-9999', 'Health', '2022-03-01', '2023-03-01', 12000.00, 900.00, 'pending'),
('Naruto Uzumaki', '1996-10-10', 1, 'male', 'Konoha Village', 'naruto@konoha.com', '999-888-7777', 'Liability', '2022-04-01', '2023-04-01', 18000.00, 1500.00, 'yes'),
('Sasuke Uchiha', '1996-07-23', 0, 'male', 'Konoha Village', 'sasuke@konoha.com', '666-555-4444', 'Home', '2022-05-01', '2023-05-01', 25000.00, 2000.00, 'no'),
('Goku', '1940-05-08', 0, 'male', 'Dragon Ball St', 'goku@dragonball.com', '333-222-1111', 'Life', '2022-02-01', '2023-02-01', 30000.00, 2500.00, 'yes'),
('Vegeta', '1955-08-29', 1, 'male', 'Dragon Ball St', 'vegeta@dragonball.com', '222-111-3333', 'Auto', '2022-07-01', '2023-07-01', 22000.00, 1800.00, 'pending'),
('Roronoa Zoro', '1992-11-11', 0, 'male', 'One Piece St', 'zoro@onepiece.com', '555-666-7777', 'Health', '2022-08-01', '2023-08-01', 15000.00, 1200.00, 'yes'),
('Usopp', '1994-04-01', 1, 'male', 'One Piece St', 'usopp@onepiece.com', '666-777-8888', 'Liability', '2022-09-01', '2023-09-01', 20000.00, 1600.00, 'no'),
('Eren Yeager', '1999-03-30', 1, 'male', 'Shiganshina District', 'eren@aot.com', '111-222-3333', 'Life', '2022-01-01', '2023-01-01', 12000.00, 900.00, 'yes'),
('Mikasa Ackerman', '1999-04-10', 0, 'female', 'Shiganshina District', 'ikasa@aot.com', '444-555-6666', 'Auto', '2022-02-01', '2023-02-01', 20000.00, 1600.00, 'pending'),
('Armin Arlert', '1999-11-15', 1, 'male', 'Shiganshina District', 'armin@aot.com', '777-888-9999', 'Health', '2022-03-01', '2023-03-01', 15000.00, 1200.00, 'no'),
('Kousei Arima', '1995-02-28', 0, 'male', 'Your Lie in April St', 'kousei@yourlieinapril.com', '999-888-7777', 'Liability', '2022-04-01', '2023-04-01', 22000.00, 1900.00, 'yes'),
('Kaori Miyazono', '1995-05-20', 1, 'female', 'Your Lie in April St', 'kaori@yourlieinapril.com', '666-555-4444', 'Home', '2022-05-01', '2023-05-01', 28000.00, 2400.00, 'pending');

-- drop table sessions;
-- Additional Queries for Validation
SELECT * FROM users;
SELECT * FROM policies;
SELECT * FROM rejected_policies;
SELECT * FROM cnf_object_scripts;
SELECT * FROM script_assn;
SELECT * FROM sessions;
SELECT * FROM payments;
SELECT * FROM claims;
SELECT * FROM audit_log;

-- Example for Executing a Script from CNF Object Scripts Table
SET @sql_query = (
    SELECT sql_text
    FROM cnf_object_scripts 
    WHERE id = 7
);

-- Inserting dummy data into sessions table

-- Assume userIds are existing user IDs from your users table

INSERT INTO sessions (user_id, login_time, logout_time)
VALUES
(1, '2024-06-15 10:00:00', '2024-06-15 12:00:00'),
(2, '2024-06-15 11:00:00', '2024-06-15 13:00:00'),
(3, '2024-06-15 12:00:00', '2024-06-15 14:00:00'),
(1, '2024-06-15 13:00:00', '2024-06-15 15:00:00'),
(2, '2024-06-15 14:00:00', '2024-06-15 16:00:00');



-- Execute the fetched SQL query
PREPARE stmt FROM @sql_query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- SET SQL_SAFE_UPDATES = 1;

UPDATE policies
SET agent_approval = 'pending'
WHERE agent_approval IS NULL;


SELECT * 
FROM policies 
WHERE email = 'goku@dragonball.com' 
  AND EXISTS (
    SELECT 1 
    FROM users 
    WHERE email = 'goku@dragonball.com' 
      AND password = 'pass' 
  );
