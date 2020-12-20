-- ToDo обернуть все в транзакцию
-- вводим позиции ингридиентов и упаковки
START TRANSACTION;
INSERT INTO commodities
(name, is_weight, is_ingredient)
SELECT concat('Ингридиент №', a.N+10*b.N), TRUE, TRUE  
from ((select 0 as N union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) a
      , (select 0 as N union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) b
);

INSERT INTO commodities
(name, is_weight, is_ingredient)
SELECT concat('Упаковка, тип №', a.N), FALSE, FALSE  
from (select 0 as N union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) a
;


-- select * from commodities 

-- вводим рецепты

INSERT INTO recipes
(name, instruction, cook_time_minutes)
SELECT concat('Рецепт №', a.N+10*b.N), 'Текст рецепта', FLOOR(1 + (RAND() * 120))  
from ((select 0 as N union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) a
      , (select 0 as N union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) b
);

-- select * from recipes

INSERT INTO candycrm.recipe_items
(recipe_id , ingredient_id , weight)
SELECT recipe.id, commodity.id, FLOOR(1 + (RAND() * 100)) FROM (
	(SELECT id FROM commodities
	WHERE commodities.is_ingredient = TRUE ORDER BY RAND() LIMIT 10) commodity,
	(SELECT id FROM recipes) recipe
);



-- select * from candycrm.recipe_items


-- создаем данные по ассортименту
-- ToDo сделать копейки также случайной величиной
INSERT INTO candycrm.range_items
(name, price, recipe_id)
SELECT concat('Кондитерское изделие №', recipe.id), FLOOR(50 + (RAND() * 100))+0.25, recipe.id  FROM 
	(SELECT id FROM recipes) recipe;


-- select * from range_items

-- заполним данные по кладовой
-- ToDo задать другой срок годности
-- вводим данные по коробкам с ингридиентами
INSERT INTO candycrm.larder_items
(quantity, weight_per_item, commodity_id, weight_residue, name, expiration_date)
SELECT * FROM (
SELECT FLOOR(2 + (RAND() * 5)) as q, FLOOR(1 + (RAND() * 4)) * 250 as w, 100, c.id, 'Коробка в кладовой с ингридиентом', CURRENT_TIMESTAMP  FROM 
(SELECT id FROM commodities  WHERE is_ingredient = TRUE AND is_weight = TRUE) c
UNION ALL 
SELECT 1, FLOOR(1 + (RAND() * 4)) * 250 as w, FLOOR(1 + (RAND() * 100)), c.id, 'Распечатанная коробка в кладовой с ингридиентом',  CURRENT_TIMESTAMP FROM 
(SELECT id FROM commodities  WHERE is_ingredient = TRUE AND is_weight = TRUE) c
) c2;

-- вводим данные по упаковкам
INSERT INTO candycrm.larder_items
(quantity, weight_per_item, commodity_id, weight_residue, name, expiration_date)
SELECT * FROM (
SELECT FLOOR(1 + (RAND() * 10)) as q, 100 as w, c.id, 100, 'Упаковка для сладостей', null  FROM 
(SELECT id FROM commodities  WHERE is_ingredient = FALSE AND is_weight = FALSE) c
) с2;

-- select * from larder_items

-- вставим данные по заказчикам
INSERT INTO candycrm.customers
(first_name, last_name, patronomyc_name, mobile_phone, email)
VALUES('Мария', 'Петрова', 'Ивановна', '+79237474848', 'petrova@mail.ru');

INSERT INTO candycrm.customers
(first_name, last_name, patronomyc_name, mobile_phone, email)
VALUES('Дмитрий', 'Федоров', 'Алексеевич', '+79437474800', 'fedorov@mail.ru');

INSERT INTO candycrm.customers
(first_name, last_name, patronomyc_name, mobile_phone, email)
VALUES('Денис', 'Комов', 'Викторович', '+78971239439', 'komov@mail.ru');

-- select * from customers


-- вставим данные по заказам
-- ToDo установка произвольной даты исполнения заказа
INSERT INTO candycrm.orders
(customer_id, deadline)
SELECT c.id, CURRENT_TIMESTAMP  FROM 
(SELECT * FROM customers c) c;

-- введем данные по позициям заказа, относящимся к ассортименту кондитерской
INSERT INTO candycrm.order_range_items
(order_id, range_item_id, quantity)
SELECT oi.oid, oi.rid, FLOOR(1 + (RAND() * 10)) as q FROM (
	SELECT orders.id as oid,
	(SELECT range_items.id FROM range_items ORDER BY RAND() LIMIT 1) as rid
	FROM orders
	JOIN customers 
) oi;


UPDATE order_range_items SET range_item_id = (SELECT range_items.id FROM range_items ORDER BY RAND() LIMIT 1);

-- select * from order_range_items

-- введем данные по позициям заказа, относящимся к упаковке кондитерских изделий
INSERT INTO candycrm.order_non_range_items
(order_id, commodity_item_id, quantity)
SELECT oi.oid, oi.rid, FLOOR(1 + (RAND() * 10)) as q FROM (
	SELECT orders.id as oid,
	(SELECT commodities.id FROM commodities WHERE commodities.is_ingredient = FALSE ORDER BY RAND() LIMIT 1) as rid
	FROM orders	
) oi;

-- select * from order_non_range_items


-- вставим данные по отзывам
INSERT INTO candycrm.order_reviews
(rating, order_id, review_text)
SELECT FLOOR(1 + (RAND() * 5)) as rate, orders.id, 'Текст отзыва' as rtext FROM orders;

-- select * from order_reviews


-- вставим данные по закупкам
INSERT INTO purchases
(total_sum, name, purchase_time)
SELECT 0, concat('Закупка в онлайн-магазине "Все для кондитера"', a.N), CURRENT_TIMESTAMP  
from (select 0 as N union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) a
;

-- SELECT * FROM purchases p2


-- вставим данные по позициям закупки


INSERT INTO candycrm.purchase_items
(purchase_id, commodity_id, quantity, cost, weigth_per_item, name)
SELECT t.id, (SELECT commodities.id FROM commodities WHERE commodities.is_ingredient = TRUE ORDER BY RAND() LIMIT 1) as cid, 
FLOOR(1 + (RAND() * 10)) as q, FLOOR(50 + (RAND() * 100)) as cost, FLOOR(1 + (RAND() * 4)) * 250 as w, 'Позиция закупки'
from (select p.id from purchases p 
join
	 (select 0 as N union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) a
) t;


INSERT INTO candycrm.purchase_items
(purchase_id, commodity_id, quantity, cost, weigth_per_item, name)
SELECT t.id, (SELECT commodities.id FROM commodities WHERE commodities.is_ingredient = FALSE ORDER BY RAND() LIMIT 1) as cid, 
FLOOR(1 + (RAND() * 10)) as q, FLOOR(50 + (RAND() * 100)) as cost, FLOOR(1 + (RAND() * 4)) * 250 as w, 'Позиция закупки (упаковка)'
from (select p.id from purchases p 
join
	 (select 0 as N union all select 1 union all select 2 union all select 3) a
) t;


-- SELECT * FROM purchase_items

-- вставим данные по слотам изготовления кондитерских изделий
-- сгенерировать слоты приготовления выпечки
INSERT INTO candycrm.cooking_slots
(confectioner_id, order_item_id, starttime, stoptime)
VALUES(null, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);


-- select * from cooking_slots

COMMIT;