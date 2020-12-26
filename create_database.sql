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
	mobile_phone VARCHAR(16),
	email VARCHAR(64),
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) COMMENT 'Заказчик';

CREATE INDEX customers_fullname_indx ON customers(first_name, last_name, patronomyc_name);

-- 1.Заказ
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  customer_id BIGINT UNSIGNED NOT NULL,
  deadline DATETIME NOT NULL COMMENT 'срок, к которому нужно выполнить заказ',
  total_cost decimal(10,2) COMMENT 'цена заказа',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  status ENUM('CREATE','INPROGRESS', 'DONE') DEFAULT 'CREATE',
  FOREIGN KEY customer_order_fk (customer_id) 
  REFERENCES customers(id)
  ON DELETE CASCADE
) COMMENT 'Заказы';

CREATE INDEX orders_customer_indx ON orders(customer_id);

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

CREATE INDEX order_reviews_indx ON order_reviews(order_id);

-- 8.Рецепты
DROP TABLE IF EXISTS recipes;
CREATE TABLE recipes(
  id SERIAL PRIMARY KEY,
  name VARCHAR(128),
  instruction TEXT COMMENT 'текст рецепта',
  cook_time_minutes INT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) COMMENT 'Рецепты';

CREATE INDEX recipes_indx ON recipes(name, cook_time_minutes);

-- 7.Ассортимент (включает цену за шт.)
DROP TABLE IF EXISTS range_items;
CREATE TABLE range_items (
  id SERIAL PRIMARY KEY,
  name VARCHAR(256),
  price decimal(9,2) UNSIGNED COMMENT 'цена за единицу',
  recipe_id BIGINT UNSIGNED NOT NULL COMMENT 'номер рецепта',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY range_item_recipe_fk (recipe_id)
  REFERENCES recipes(id)
  ON DELETE CASCADE
) COMMENT 'Позиции заказа';

CREATE INDEX range_items_indx ON range_items(name, recipe_id);

-- 9.2 Предмет потребления/товар
DROP TABLE IF EXISTS commodities;
CREATE TABLE commodities(
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  is_weight BOOL DEFAULT TRUE COMMENT 'весовой или количественный товар',
  is_ingredient BOOL DEFAULT TRUE COMMENT 'является ли товар ингриедиентом для приготовления',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) COMMENT 'Товар потребления';

CREATE INDEX commodities_indx ON commodities(name);

-- 6.Позиция заказа (не может включать упаковку)
DROP TABLE IF EXISTS order_range_items;
CREATE TABLE order_range_items (
  id SERIAL PRIMARY KEY,
  order_id BIGINT UNSIGNED COMMENT 'номер заказа',
  range_item_id BIGINT UNSIGNED COMMENT 'позиция ассортимента',
  quantity INT UNSIGNED COMMENT 'количество в штуках',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY order_item_order_fk (order_id)
  REFERENCES orders(id)
  ON DELETE CASCADE,
  FOREIGN KEY order_range_item_range_item_fk (range_item_id)
  REFERENCES range_items(id)
  ON DELETE SET NULL  
) COMMENT 'Позиции заказа';

CREATE INDEX order_range_items_indx ON order_range_items(order_id, range_item_id);


DROP TABLE IF EXISTS order_non_range_items;
CREATE TABLE order_non_range_items (
  id SERIAL PRIMARY KEY,
  order_id BIGINT UNSIGNED COMMENT 'номер заказа',
  commodity_item_id BIGINT UNSIGNED COMMENT 'позиция ассортимента',
  quantity INT UNSIGNED COMMENT 'количество в штуках',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY order_item_order_fk (order_id)
  REFERENCES orders(id)
  ON DELETE CASCADE,
  FOREIGN KEY order_item_commodities_fk (commodity_item_id)
  REFERENCES commodities(id)
  ON DELETE SET NULL  
) COMMENT 'Позиции заказа';

CREATE INDEX order_non_range_items_indx ON order_non_range_items(order_id, commodity_item_id);

-- 9.Позиция рецепта (количество продукта)
DROP TABLE IF EXISTS recipe_items;
CREATE TABLE recipe_items(
  id SERIAL PRIMARY KEY,
  recipe_id BIGINT UNSIGNED NOT NULL COMMENT 'номер рецепта',
  ingredient_id BIGINT UNSIGNED NOT NULL COMMENT 'номер ингридиента',
  weight decimal(9,3) UNSIGNED NOT NULL COMMENT 'вес в граммах',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY recipe_item_recipe_fk (recipe_id)
  REFERENCES recipes(id),
  FOREIGN KEY recipe_item_commodity_fk (ingredient_id)
  REFERENCES commodities(id)
) COMMENT 'Рецепты';

CREATE INDEX recipe_items_indx ON recipe_items(recipe_id, ingredient_id);

-- 10.Закупка
DROP TABLE IF EXISTS purchases;
CREATE TABLE purchases(
  id SERIAL PRIMARY KEY,
  total_sum decimal(15,2) UNSIGNED NOT NULL COMMENT 'стоимость закупки',
  name VARCHAR(255),
  status ENUM('CREATE', 'DONE') DEFAULT 'CREATE',
  purchase_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX purchases_indx ON purchases(name, purchase_time);

-- 11.Позиция закупки (может быть упаковкой)
DROP TABLE IF EXISTS purchase_items;
CREATE TABLE purchase_items(
  id SERIAL PRIMARY KEY,
  purchase_id BIGINT UNSIGNED NOT NULL,
  commodity_id BIGINT UNSIGNED COMMENT 'позиция товара потребления',
  quantity INT UNSIGNED COMMENT 'количество',
  weigth_per_item decimal(9,3) UNSIGNED COMMENT 'вес в граммах в одной упаковке',
  cost decimal(9,2) UNSIGNED NOT NULL COMMENT 'стоимость за упаковку',
  name VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY purchase_item_purchase_fk (purchase_id)
  REFERENCES purchases(id)
  ON DELETE CASCADE,
  FOREIGN KEY purchase_item_commodity_fk (commodity_id)
  REFERENCES commodities(id)
  ON DELETE SET NULL
  
);

CREATE INDEX purchase_items_indx ON purchase_items(purchase_id, commodity_id);


-- 13.Позиция кладовой (может быть упаковкой)
DROP TABLE IF EXISTS larder_items;
CREATE TABLE larder_items(
  id SERIAL PRIMARY KEY,
  quantity INT UNSIGNED DEFAULT 1 COMMENT 'количество',
  weight_per_item decimal(9,3) UNSIGNED COMMENT 'вес в граммах в одной упаковке',  
  commodity_id BIGINT UNSIGNED COMMENT 'номер товара потребления',
  weight_residue decimal(6,3) UNSIGNED COMMENT 'фактический весовой остаток в процентах для указанного количества упаковок',
  name VARCHAR(255),
  expiration_date DATETIME COMMENT 'срок годности',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,  
  FOREIGN KEY larder_item_commodity_fk (commodity_id)
  REFERENCES commodities(id)
  ON DELETE SET NULL
);

CREATE INDEX larder_items_indx ON larder_items(commodity_id, expiration_date);

-- Слоты готовки позиций заказов
DROP TABLE IF EXISTS cooking_slots;
CREATE TABLE cooking_slots(
  id SERIAL PRIMARY KEY,
  confectioner_id INT DEFAULT NULL,
  order_item_id BIGINT UNSIGNED COMMENT 'номер позиции заказа',
  starttime DATETIME COMMENT 'начало готовки',
  stoptime DATETIME COMMENT 'окончание готовки',
  status ENUM('CREATE','INPROGRESS', 'DONE') DEFAULT 'CREATE',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY cooking_slots_order_item_fk (order_item_id)
  REFERENCES order_range_items(id)
  ON DELETE SET NULL
);

CREATE INDEX cooking_slots_indx ON cooking_slots(order_item_id, starttime, stoptime);