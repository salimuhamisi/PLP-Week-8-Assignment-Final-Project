/********************************************************************************
    ==> Simple Documentation

 * E-COMMERCE DATABASE SCHEMA
 * - Database: ecommerce_db
 * - Features:
 *    * Well-structured tables
 *    * PK, FK, UNIQUE, NOT NULL constraints
 *    * Example One-to-One, One-to-Many, Many-to-Many relationships
 *    * InnoDB engine for referential integrity
 *
 * Usage: Run this file in MySQL (MySQL 5.7+ / 8.0+ recommended)
 ********************************************************************************/

-- 0) Cleanup if re-running
DROP DATABASE IF EXISTS ecommerce_db;
CREATE DATABASE ecommerce_db
  CHARACTER SET = 'utf8mb4'
  COLLATE = 'utf8mb4_unicode_ci';

USE ecommerce_db;

-- 1) Core lookup tables
CREATE TABLE categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE suppliers (
  supplier_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  contact_email VARCHAR(255),
  phone VARCHAR(30),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2) Products (Many products belong to one category)
CREATE TABLE products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  sku VARCHAR(50) NOT NULL UNIQUE,
  name VARCHAR(200) NOT NULL,
  description TEXT,
  category_id INT NOT NULL,
  unit_price DECIMAL(12,2) NOT NULL CHECK (unit_price >= 0),
  stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(category_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 3) Many-to-Many: product_suppliers (a product can have many suppliers and vice versa)
CREATE TABLE product_suppliers (
  product_id INT NOT NULL,
  supplier_id INT NOT NULL,
  supplier_sku VARCHAR(100),
  lead_time_days INT DEFAULT 0 CHECK (lead_time_days >= 0),
  PRIMARY KEY (product_id, supplier_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 4) Customers (One customer can have many addresses)
CREATE TABLE customers (
  customer_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  phone VARCHAR(30),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 5) Addresses: One-to-Many (a customer can have multiple addresses)
CREATE TABLE addresses (
  address_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  address_line1 VARCHAR(255) NOT NULL,
  address_line2 VARCHAR(255),
  city VARCHAR(100) NOT NULL,
  state VARCHAR(100),
  postal_code VARCHAR(30),
  country VARCHAR(100) NOT NULL,
  is_billing BOOLEAN NOT NULL DEFAULT FALSE,
  is_shipping BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 6) One-to-One example: customer_wallet (one wallet per customer)
CREATE TABLE customer_wallets (
  customer_id INT PRIMARY KEY,        -- PK and FK: enforces 1-to-1
  balance DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (balance >= 0),
  currency CHAR(3) NOT NULL DEFAULT 'USD',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 7) Orders: One-to-Many (customer -> orders)
CREATE TABLE orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status ENUM('pending','processing','shipped','delivered','cancelled') NOT NULL DEFAULT 'pending',
  shipping_address_id INT,
  billing_address_id INT,
  total_amount DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (total_amount >= 0),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (shipping_address_id) REFERENCES addresses(address_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  FOREIGN KEY (billing_address_id) REFERENCES addresses(address_id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 8) Order items: Many-to-Many - with quantity & unit price
CREATE TABLE order_items (
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  unit_price DECIMAL(12,2) NOT NULL CHECK (unit_price >= 0),
  line_total DECIMAL(14,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
  PRIMARY KEY (order_id, product_id),
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(product_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 9) Payments (an order may have multiple payments or one-to-one)
CREATE TABLE payments (
  payment_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  amount DECIMAL(12,2) NOT NULL CHECK (amount >= 0),
  method ENUM('card','paypal','bank_transfer','wallet') NOT NULL,
  status ENUM('pending','completed','failed','refunded') NOT NULL DEFAULT 'pending',
  paid_at DATETIME,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 10) Product images (One-to-Many: product -> images)
CREATE TABLE product_images (
  image_id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  url VARCHAR(500) NOT NULL,
  alt_text VARCHAR(255),
  is_primary BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(product_id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 11) Indexes and helper constraints
-- Add index to speed lookups by SKU already unique; add index on order status & date
CREATE INDEX idx_orders_status_date ON orders(status, order_date);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_customers_email ON customers(email);

-- 12) Example views - helpful for simple reporting
CREATE OR REPLACE VIEW vw_order_summary AS
SELECT
  o.order_id,
  o.order_date,
  o.status,
  o.customer_id,
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;
