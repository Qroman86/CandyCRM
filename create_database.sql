CREATE DATABASE IF NOT EXISTS candycrm;

USE candycrm;


-- 1.Заказ
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  customer_id INT UNSIGNED NOT NULL,
  deadline DATETIME NOT NULL,
  total_cost decimal(15,2) COMMENT 'цена заказа',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) COMMENT 'Заказы';


-- 2.Заказчик
DROP TABLE IF EXISTS customers;
CREATE TABLE customers(
	id SERIAL PRIMARY KEY,
	first_name VARCHAR(64),
	last_name VARCHAR(128),
	patronomyc_name VARCHAR(128),
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) COMMENT 'Заказчик';

-- 3.Контакт заказчика
DROP TABLE IF EXISTS contacts;
CREATE TABLE contacts (
  id SERIAL PRIMARY KEY,
  contact_type_id INT COMMENT 'тип контакта',
  contact_value VARCHAR(128),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) COMMENT 'Контактная информация';

-- 4.Тип контакта заказчика
DROP TABLE IF EXISTS contact_types;
CREATE TABLE contact_types (
  id SERIAL PRIMARY KEY,
  name VARCHAR(128), 
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) COMMENT 'Тип контакта заказчика';

-- 5.Отзыв по заказу
DROP TABLE IF EXISTS order_reviews;
CREATE TABLE order_reviews (
  id SERIAL PRIMARY KEY,
  order_id INT COMMENT 'идентификатор заказа',
  review_text TEXT COMMENT 'текст отзыва', 
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) COMMENT 'Тип контакта заказчика';


-- 6.Позиция заказа (может включать упаковку)
DROP TABLE IF EXISTS order_items;
CREATE TABLE order_items (
  id SERIAL PRIMARY KEY,
  order_id INT UNSIGNED NOT NULL COMMENT 'номер заказа',
  range_item_id INT UNSIGNED COMMENT 'позиция ассортимента',
  quantity INT UNSIGNED COMMENT 'количество в штуках',
  commodity_id INT UNSIGNED COMMENT 'позиция товара потребления',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) COMMENT 'Позиции заказа';


-- 7.Ассортимент (включает цену за шт.)
DROP TABLE IF EXISTS range_items;
CREATE TABLE range_items (
  id SERIAL PRIMARY KEY,
  name VARCHAR(256),
  price decimal(15,2) UNSIGNED COMMENT 'цена за единицу',
  recipe_id INT UNSIGNED NOT NULL COMMENT 'номер рецепта',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) COMMENT 'Позиции заказа';


-- 8.Рецепты
DROP TABLE IF EXISTS recipes;
CREATE TABLE recipes(
  id SERIAL PRIMARY KEY,
  instruction TEXT COMMENT 'текст рецепта',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) COMMENT 'Рецепты';


-- 9.Позиция рецепта (количество продукта)
DROP TABLE IF EXISTS recipe_items;
CREATE TABLE recipe_items(
  id SERIAL PRIMARY KEY,
  recipe_id INT UNSIGNED NOT NULL COMMENT 'номер рецепта',
  ingredient_id INT UNSIGNED NOT NULL COMMENT 'номер ингридиента',
  weight decimal(9,3) UNSIGNED NOT NULL COMMENT 'вес в граммах',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) COMMENT 'Рецепты';

-- 9.1 Ингридиент
DROP TABLE IF EXISTS ingredients;
CREATE TABLE ingredients(
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) COMMENT 'Ингридиенты';

-- 9.2 Предмет потребления/товар
DROP TABLE IF EXISTS commodities;
CREATE TABLE commodities(
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) COMMENT 'Товар потребления';


-- 10.Закупка
DROP TABLE IF EXISTS purchases;
CREATE TABLE purchases(
  id SERIAL PRIMARY KEY,
  total_sum decimal(15,2) UNSIGNED NOT NULL COMMENT 'стоимость закупки',
  name VARCHAR(255),
  purchase_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 11.Позиция закупки (может быть упаковкой)
DROP TABLE IF EXISTS purchase_items;
CREATE TABLE purchase_items(
  id SERIAL PRIMARY KEY,
  ingredient_id INT UNSIGNED COMMENT 'номер ингридиента',  
  weight decimal(9,3) UNSIGNED COMMENT 'вес в граммах',
  name VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);


-- 13.Позиция кладовой (может быть упаковкой)
DROP TABLE IF EXISTS larder_items;
CREATE TABLE larder_items(
  id SERIAL PRIMARY KEY,
  ingredient_id INT UNSIGNED COMMENT 'номер ингридиента',  
  weight decimal(9,3) UNSIGNED COMMENT 'вес в граммах',
  commodity_id INT UNSIGNED COMMENT 'номер товара потребления',
  name VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);