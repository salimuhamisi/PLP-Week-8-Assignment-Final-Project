# 🛒 E-Commerce Relational Database Schema

## 📌 Overview
This project implements a **relational database schema for an E-Commerce Store** using **MySQL**.  
The schema is designed with **normalization principles** to reduce redundancy, ensure data integrity, and support real-world online shopping operations.

## 🎯 Objectives
- Design a **normalized relational schema**.
- Demonstrate **One-to-One, One-to-Many, and Many-to-Many** relationships.
- Enforce **constraints**: `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `NOT NULL`, and `CHECK`.
- Provide a clean foundation for managing **customers, products, orders, payments, and suppliers**.

---

## 🏗️ Database Structure

### Entities & Relationships
- **Categories → Products**: One-to-Many  
- **Products ↔ Suppliers**: Many-to-Many  
- **Customers → Addresses**: One-to-Many  
- **Customers → Wallets**: One-to-One  
- **Customers → Orders → Order Items**: One-to-Many + Many-to-Many  
- **Orders → Payments**: One-to-Many  
- **Products → Images**: One-to-Many  

---

## 📂 Schema Components

### Core Tables
- `categories` – Product categories (e.g., Electronics, Books).
- `suppliers` – Suppliers providing products.
- `products` – Items available for sale.
- `customers` – Registered customers.

### Relationship Tables
- `product_suppliers` – Links products with suppliers (Many-to-Many).
- `addresses` – Stores customer shipping & billing addresses.
- `customer_wallets` – One-to-One customer balance tracking.
- `orders` – Customer orders.
- `order_items` – Items within each order (Many-to-Many with products).
- `payments` – Order payment transactions.
- `product_images` – Product media gallery.

---

## ⚙️ Setup Instructions

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/ecommerce-db.git
cd ecommerce-db


EXECUTIONS
(a) Open MySQL ==> mysql -u root -p
(b) Run the Schema ==> SOURCE ecommerce_schema.sql;

EXAMPLE USAGE
(c) Insert a Category ==>
        INSERT INTO categories (name, description)
        VALUES ('Electronics', 'Devices and gadgets');

(d) Insert a Product ==>
      INSERT INTO products (sku, name, category_id, unit_price, stock_quantity)
      VALUES ('LAP123', 'Laptop Pro 15', 1, 1200.00, 10);

(e) Place an Order ==>
      INSERT INTO orders (customer_id, status, total_amount)
      VALUES (1, 'pending', 1200.00);
      
      INSERT INTO order_items (order_id, product_id, quantity, unit_price)
      VALUES (1, 1, 1, 1200.00);

(f) Record a Payment ==>
      INSERT INTO payments (order_id, amount, method, status)
      VALUES (1, 1200.00, 'card', 'completed');
