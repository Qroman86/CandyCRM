DROP DATABASE IF EXISTS candycrm;
CREATE DATABASE IF NOT EXISTS candycrm;

USE candycrm;


-- 2.Заказчик
DROP TABLE IF EXISTS customers;
CREATE TABLE customers(
	id SERIAL PRIMARY KEY,
	first_name VARCHAR(64),
	last_name VARCHAR(128),
	patronomyc_name VARCHAR(128),
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) COMMENT 'Заказчик';


-- 1.Заказ
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  customer_id BIGINT UNSIGNED NOT NULL,
  deadline DATETIME NOT NULL,
  total_cost decimal(10,2) COMMENT 'цена заказа',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY customer_order_fk (customer_id) 
  REFERENCES customers(id)
  ON DELETE CASCADE
) COMMENT 'Заказы';


-- 4.Тип контакта заказчика
DROP TABLE IF EXISTS contact_types;
CREATE TABLE contact_types (
  id SERIAL PRIMARY KEY,
  name VARCHAR(128), 
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) COMMENT 'Тип контакта заказчика';

-- 3.Контакт заказчика
DROP TABLE IF EXISTS contacts;
CREATE TABLE contacts (
  id SERIAL PRIMARY KEY,
  contact_type_id BIGINT UNSIGNED NOT NULL COMMENT 'тип контакта',
  customer_id BIGINT UNSIGNED NOT NULL,
  contact_value VARCHAR(128),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY contact_contact_type_fk (contact_type_id)
  REFERENCES contact_types(id)
  ON DELETE CASCADE,
  FOREIGN KEY contact_customer_fk (customer_id)
  REFERENCES customers(id)
  ON DELETE CASCADE
) COMMENT 'Контактная информация';



-- 5.Отзыв по заказу
DROP TABLE IF EXISTS order_reviews;
CREATE TABLE order_reviews (
  id SERIAL PRIMARY KEY,
  rating INT NOT NULL COMMENT 'оценка',
  order_id BIGINT  UNSIGNED NOT NULL COMMENT 'идентификатор заказа',
  review_text TEXT COMMENT 'текст отзыва', 
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,  
  FOREIGN KEY order_review_order_fk (order_id)
  REFERENCES orders(id)
  ON DELETE CASCADE
) COMMENT 'Отзывы по заказу';

-- 8.Рецепты
DROP TABLE IF EXISTS recipes;
CREATE TABLE recipes(
  id SERIAL PRIMARY KEY,
  name VARCHAR(128),
  instruction TEXT COMMENT 'текст рецепта',
  cook_time_minutes INT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) COMMENT 'Рецепты';

-- 7.Ассортимент (включает цену за шт.)
DROP TABLE IF EXISTS range_items;
CREATE TABLE range_items (
  id SERIAL PRIMARY KEY,
  name VARCHAR(256),
  price decimal(15,2) UNSIGNED COMMENT 'цена за единицу',
  recipe_id BIGINT UNSIGNED NOT NULL COMMENT 'номер рецепта',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY range_item_recipe_fk (recipe_id)
  REFERENCES recipes(id)
  ON DELETE CASCADE
) COMMENT 'Позиции заказа';


-- 9.2 Предмет потребления/товар
DROP TABLE IF EXISTS commodities;
CREATE TABLE commodities(
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) COMMENT 'Товар потребления';

-- 6.Позиция заказа (может включать упаковку)
DROP TABLE IF EXISTS order_items;
CREATE TABLE order_items (
  id SERIAL PRIMARY KEY,
  order_id BIGINT UNSIGNED COMMENT 'номер заказа',
  range_item_id BIGINT UNSIGNED COMMENT 'позиция ассортимента',
  quantity INT UNSIGNED COMMENT 'количество в штуках',
  commodity_id BIGINT UNSIGNED COMMENT 'позиция товара потребления',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY order_item_order_fk (order_id)
  REFERENCES orders(id)
  ON DELETE CASCADE,
  FOREIGN KEY order_item_range_item_fk (range_item_id)
  REFERENCES range_items(id)
  ON DELETE SET NULL,
  FOREIGN KEY order_item_commodity_fk (commodity_id)
  REFERENCES commodities(id)
  ON DELETE SET NULL
) COMMENT 'Позиции заказа';






-- 9.1 Ингридиент
DROP TABLE IF EXISTS ingredients;
CREATE TABLE ingredients(
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) COMMENT 'Ингридиенты';

-- 9.Позиция рецепта (количество продукта)
DROP TABLE IF EXISTS recipe_items;
CREATE TABLE recipe_items(
  id SERIAL PRIMARY KEY,
  recipe_id BIGINT UNSIGNED NOT NULL COMMENT 'номер рецепта',
  ingredient_id BIGINT UNSIGNED NOT NULL COMMENT 'номер ингридиента',
  weight decimal(9,3) UNSIGNED NOT NULL COMMENT 'вес в граммах',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY recipe_item_commodity_recipe_fk (recipe_id)
  REFERENCES recipes(id)
  ON DELETE CASCADE,
  FOREIGN KEY recipe_item_ingredient_fk (recipe_id)
  REFERENCES ingredients(id)
  ON DELETE CASCADE
) COMMENT 'Рецепты';



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
  purchase_id BIGINT UNSIGNED NOT NULL,
  ingredient_id BIGINT UNSIGNED COMMENT 'номер ингридиента',
  commodity_id BIGINT UNSIGNED COMMENT 'позиция товара потребления',
  weight decimal(9,3) UNSIGNED COMMENT 'вес в граммах',
  cost decimal(9,2) UNSIGNED NOT NULL COMMENT 'стоимость',
  name VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY purchase_item_purchase_fk (purchase_id)
  REFERENCES purchases(id)
  ON DELETE CASCADE,
  FOREIGN KEY purchase_item_ingredient_fk (ingredient_id)
  REFERENCES ingredients(id)
  ON DELETE SET NULL,
  FOREIGN KEY purchase_item_commodity_fk (commodity_id)
  REFERENCES commodities(id)
  ON DELETE SET NULL
  
);


-- 13.Позиция кладовой (может быть упаковкой)
DROP TABLE IF EXISTS larder_items;
CREATE TABLE larder_items(
  id SERIAL PRIMARY KEY,
  ingredient_id BIGINT UNSIGNED COMMENT 'номер ингридиента',  
  weight decimal(9,3) UNSIGNED COMMENT 'вес в граммах',
  commodity_id BIGINT UNSIGNED COMMENT 'номер товара потребления',
  name VARCHAR(255),
  expiration_date DATETIME COMMENT 'срок годности',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY larder_item_ingredient_fk (ingredient_id)
  REFERENCES ingredients(id)
  ON DELETE SET NULL,
  FOREIGN KEY larder_item_commodity_fk (commodity_id)
  REFERENCES commodities(id)
  ON DELETE SET NULL
);

-- Слоты готовки позиций заказов
DROP TABLE IF EXISTS cooking_slots;
CREATE TABLE cooking_slots(
  id SERIAL PRIMARY KEY,
  confectioner_id INT DEFAULT NULL,
  order_item_id BIGINT UNSIGNED COMMENT 'номер позиции заказа',
  starttime DATETIME COMMENT 'начало готовки',
  stoptime DATETIME COMMENT 'окончание готовки',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY cooking_slots_order_item_fk (order_item_id)
  REFERENCES order_items(id)
  ON DELETE SET NULL
);