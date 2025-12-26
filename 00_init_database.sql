-- Active: 1764674974722@@127.0.0.1@3306@DataWarehouseAnalytics
/*
=============================================================
Create Database and Schemas (MySQL Version)
=============================================================
WARNING:
    This will DROP the database if it exists.
*/

-- Drop and recreate database
DROP DATABASE IF EXISTS DataWarehouseAnalytics;
CREATE DATABASE DataWarehouseAnalytics;

USE DataWarehouseAnalytics;

-- Create schema equivalent
-- MySQL doesn’t really "use" schemas like SQL Server
-- So we simulate it by prefixing table names or using a database
CREATE TABLE gold_dim_customers (
    customer_key INT,
    customer_id INT,
    customer_number VARCHAR(50),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    country VARCHAR(50),
    marital_status VARCHAR(50),
    gender VARCHAR(50),
    birthdate DATE,
    create_date DATE
);

CREATE TABLE gold_dim_products (
    product_key INT,
    product_id INT,
    product_number VARCHAR(50),
    product_name VARCHAR(50),
    category_id VARCHAR(50),
    category VARCHAR(50),
    subcategory VARCHAR(50),
    maintenance VARCHAR(50),
    cost INT,
    product_line VARCHAR(50),
    start_date DATE
);

CREATE TABLE gold_fact_sales (
    order_number VARCHAR(50),
    product_key INT,
    customer_key INT,
    order_date DATE,
    shipping_date DATE,
    due_date DATE,
    sales_amount INT,
    quantity TINYINT,
    price INT
);

select * from order
