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
INSERT INTO `customers` VALUES ('1','Syble','Runolfsdottir','Beier','464.826.1740x427','abecker@example.org','2020-12-26 08:51:39'),
('2','Amy','Osinski','Kilback','1-947-795-0382x3','jensen89@example.com','2020-12-26 08:51:39'),
('3','Blanca','Grant','Hickle','1-891-919-6715','ccollins@example.com','2020-12-26 08:51:39'),
('4','Carlotta','Jacobson','Strosin','1-823-436-5021','icie99@example.com','2020-12-26 08:51:39'),
('5','Eudora','Wisozk','Maggio','1-527-140-9048x2','braun.sabrina@example.com','2020-12-26 08:51:39'),
('6','Adolf','Cronin','Anderson','00520807768','orrin40@example.org','2020-12-26 08:51:39'),
('7','Orland','Veum','Leannon','045-451-7522x225','vanessa88@example.net','2020-12-26 08:51:39'),
('8','Raphaelle','Grady','Hand','+47(2)6093799110','bpadberg@example.net','2020-12-26 08:51:39'),
('9','Jordane','Hackett','Sipes','1-984-766-3819','ternser@example.com','2020-12-26 08:51:39'),
('10','Gussie','Veum','Herman','712.858.1589','sophia30@example.net','2020-12-26 08:51:39'),
('11','Tianna','Hegmann','Brown','+39(6)5671816141','favian.jenkins@example.net','2020-12-26 08:51:39'),
('12','Liza','Block','Eichmann','238-687-3817','carolanne04@example.net','2020-12-26 08:51:39'),
('13','Lenora','Botsford','Hilpert','05778880806','agraham@example.net','2020-12-26 08:51:39'),
('14','Bettie','Braun','Kozey','501-168-4921x172','heaney.samir@example.org','2020-12-26 08:51:39'),
('15','Vance','Kling','Krajcik','043-162-3681x124','nakia24@example.org','2020-12-26 08:51:39'),
('16','Rosemary','Buckridge','Mosciski','008.159.7188x581','idaugherty@example.net','2020-12-26 08:51:39'),
('17','Burdette','Murphy','Harvey','+88(7)5101970644','zprice@example.net','2020-12-26 08:51:39'),
('18','Brenna','Mosciski','Wisoky','1-793-703-4185x5','alaina88@example.net','2020-12-26 08:51:39'),
('19','Mercedes','Thiel','Lubowitz','(037)651-2073','tklocko@example.com','2020-12-26 08:51:39'),
('20','Loren','Blanda','Runolfsson','565-168-0467x703','bernhard.elta@example.com','2020-12-26 08:51:39'),
('21','Burnice','Breitenberg','Langworth','1-615-389-0834','aschneider@example.org','2020-12-26 08:51:39'),
('22','Rafaela','McKenzie','Hauck','(042)558-0280','ahilll@example.org','2020-12-26 08:51:39'),
('23','Brandon','Douglas','Douglas','(350)317-5625','stracke.laura@example.com','2020-12-26 08:51:39'),
('24','Demond','Bradtke','Gutmann','(943)270-1056','walker.martine@example.org','2020-12-26 08:51:39'),
('25','Tara','Jacobs','Schowalter','(602)333-6592','ssimonis@example.org','2020-12-26 08:51:39'),
('26','Kiley','Schuppe','Koelpin','(409)168-9094','alvah51@example.net','2020-12-26 08:51:39'),
('27','Darrion','Keebler','Cruickshank','067.187.1066x349','julie.cole@example.com','2020-12-26 08:51:39'),
('28','Halle','Conroy','Gleason','550-950-8427','walter.richie@example.net','2020-12-26 08:51:39'),
('29','Jayce','Luettgen','Wehner','474-492-9747x909','jtoy@example.net','2020-12-26 08:51:39'),
('30','Vernon','Gibson','Lakin','+86(8)8150721154','xzboncak@example.net','2020-12-26 08:51:39'),
('31','Sydnie','Konopelski','Stroman','529.311.5789x617','gene.veum@example.org','2020-12-26 08:51:39'),
('32','Mellie','Dickinson','Bergstrom','02600571540','orn.juanita@example.com','2020-12-26 08:51:39'),
('33','Cayla','Quigley','Gutkowski','+09(1)5418800967','beier.merle@example.org','2020-12-26 08:51:39'),
('34','Lamar','Cartwright','Zemlak','1-810-497-2293','reid98@example.com','2020-12-26 08:51:39'),
('35','Alexandrine','Jakubowski','Mills','(498)308-8092x76','gregg.osinski@example.org','2020-12-26 08:51:39'),
('36','Oda','Waters','Boehm','1-569-116-9516x5','damien.wilderman@example.com','2020-12-26 08:51:39'),
('37','Maryam','Bernhard','Berge','005-886-9616','warren42@example.net','2020-12-26 08:51:39'),
('38','Jody','Powlowski','Stracke','1-234-127-5742x1','hans78@example.net','2020-12-26 08:51:39'),
('39','Marjorie','Haag','Frami','1-843-574-8411x0','chelsey62@example.net','2020-12-26 08:51:39'),
('40','Lilian','Yundt','Gaylord','162.510.3851x262','murray.will@example.com','2020-12-26 08:51:39'),
('41','Columbus','Harris','Kub','591-444-1141x379','morissette.justen@example.com','2020-12-26 08:51:39'),
('42','Dedrick','Wilkinson','Stoltenberg','293-202-5603x082','kovacek.ruthie@example.org','2020-12-26 08:51:39'),
('43','Amalia','Aufderhar','Torp','723-968-8336x448','liam.will@example.net','2020-12-26 08:51:39'),
('44','Muriel','Denesik','Hackett','333.741.7564x957','bayer.genesis@example.org','2020-12-26 08:51:39'),
('45','Kurtis','Goodwin','Kuphal','1-978-968-2638','rbednar@example.org','2020-12-26 08:51:39'),
('46','Wilfrid','Conroy','Rempel','1-052-225-2225x6','lexi15@example.net','2020-12-26 08:51:39'),
('47','Milton','Murazik','Predovic','(079)932-5377','alexzander.wiza@example.net','2020-12-26 08:51:39'),
('48','Romaine','Bogisich','D\'Amore','+72(6)0718434156','quigley.jacinto@example.com','2020-12-26 08:51:39'),
('49','Ellie','Shields','Walker','1-389-177-5785x9','hrutherford@example.org','2020-12-26 08:51:39'),
('50','Kelsi','Weber','Boyer','1-403-532-1671x4','wiza.elyse@example.org','2020-12-26 08:51:39'),
('51','Americo','Pollich','Welch','963.485.8379','abbie37@example.com','2020-12-26 08:51:39'),
('52','Prince','Harber','Morissette','333.247.0553x687','bartoletti.monserrat@example.net','2020-12-26 08:51:39'),
('53','Ara','Wilderman','Balistreri','1-167-132-0716','tillman.wiegand@example.net','2020-12-26 08:51:39'),
('54','Dahlia','Yundt','Feil','1-835-944-7658','joe79@example.com','2020-12-26 08:51:39'),
('55','Marquise','Koelpin','Collins','1-514-052-3210','larson.evalyn@example.net','2020-12-26 08:51:39'),
('56','Lavinia','Okuneva','Auer','(597)707-1005x02','mcclure.isabelle@example.org','2020-12-26 08:51:39'),
('57','Buck','Wiegand','Gutmann','05395117534','alden89@example.org','2020-12-26 08:51:39'),
('58','Jasmin','Kub','Gutkowski','652-434-6432','jchamplin@example.net','2020-12-26 08:51:39'),
('59','Lonnie','Bins','Schuppe','236.021.9397x385','rogers25@example.com','2020-12-26 08:51:39'),
('60','Kayli','Lemke','Nitzsche','323.018.8478','lincoln.rolfson@example.org','2020-12-26 08:51:39'),
('61','Louvenia','Koepp','Gleichner','863.272.2031x477','luna40@example.org','2020-12-26 08:51:39'),
('62','Coleman','Daugherty','Labadie','1-226-725-6223','royce.miller@example.org','2020-12-26 08:51:39'),
('63','Allan','Kilback','Cummings','(368)053-2490x05','kunde.ofelia@example.org','2020-12-26 08:51:39'),
('64','Arvilla','Huel','Douglas','(702)385-2301x56','reuben01@example.net','2020-12-26 08:51:39'),
('65','Maybelle','West','Murray','1-523-229-8114x2','al.mraz@example.net','2020-12-26 08:51:39'),
('66','Andre','Trantow','Kub','(012)170-1540','denesik.riley@example.org','2020-12-26 08:51:39'),
('67','Nathanial','Romaguera','Russel','415.802.4173','reichel.alessandro@example.org','2020-12-26 08:51:39'),
('68','Ofelia','Tromp','Keeling','170-819-1187','adeckow@example.com','2020-12-26 08:51:39'),
('69','Britney','Jacobson','Herman','312-116-7677x555','eldon12@example.org','2020-12-26 08:51:39'),
('70','Margarette','Reichel','Kling','1-058-149-4719x2','sjacobs@example.com','2020-12-26 08:51:39'),
('71','Brook','Lebsack','Kutch','432-761-5524x755','julian43@example.net','2020-12-26 08:51:39'),
('72','Paris','Emard','Quitzon','1-014-420-8423x7','hirthe.brando@example.com','2020-12-26 08:51:39'),
('73','Willard','McKenzie','Kuvalis','(825)943-0472','mlynch@example.com','2020-12-26 08:51:39'),
('74','Abe','Labadie','Waelchi','1-912-122-2950x1','gislason.cielo@example.net','2020-12-26 08:51:39'),
('75','Jerrell','Auer','Carroll','1-199-138-1931x5','iprice@example.com','2020-12-26 08:51:39'),
('76','Shanny','Denesik','McCullough','375.805.4574','haley.bartoletti@example.net','2020-12-26 08:51:39'),
('77','Graciela','Hartmann','King','(666)062-0997x81','elinore.beahan@example.com','2020-12-26 08:51:39'),
('78','Lew','O\'Keefe','Cassin','1-643-200-3142x4','ebarton@example.com','2020-12-26 08:51:39'),
('79','Elvie','Adams','Schoen','(958)069-5799x14','ncorkery@example.org','2020-12-26 08:51:39'),
('80','Colin','Witting','Willms','628-680-9571','xwisoky@example.net','2020-12-26 08:51:39'),
('81','Linnea','Lang','Miller','(673)863-0779','jakubowski.asia@example.net','2020-12-26 08:51:39'),
('82','Lavonne','Oberbrunner','Boehm','+94(8)0842825752','karli.stracke@example.net','2020-12-26 08:51:39'),
('83','Hortense','Labadie','Deckow','1-321-555-5684x9','gilbert.lang@example.net','2020-12-26 08:51:39'),
('84','Lazaro','Renner','Kilback','1-324-809-7440x5','kari.lynch@example.com','2020-12-26 08:51:39'),
('85','Cayla','Quitzon','Kassulke','1-239-019-7882','hjacobs@example.com','2020-12-26 08:51:39'),
('86','Danial','Turner','Hilpert','1-185-613-3864','sigmund97@example.org','2020-12-26 08:51:39'),
('87','Shanelle','Cole','O\'Connell','240.171.2937','ward.mathias@example.org','2020-12-26 08:51:39'),
('88','Leanne','Little','Kuvalis','(643)635-7460x38','amber.hintz@example.net','2020-12-26 08:51:39'),
('89','Cloyd','Sawayn','Beahan','609.723.3634','ferne89@example.com','2020-12-26 08:51:39'),
('90','Arnulfo','Predovic','Keebler','118.891.8064x346','hammes.mervin@example.net','2020-12-26 08:51:39'),
('91','Lenora','Durgan','Cummings','708.916.9576','sadye88@example.com','2020-12-26 08:51:39'),
('92','Brooke','Bogisich','Rowe','260.171.4233x550','upagac@example.org','2020-12-26 08:51:39'),
('93','Delilah','Cummings','Dickens','1-207-368-5764x5','odell06@example.org','2020-12-26 08:51:39'),
('94','Hailee','Jones','Cremin','09937418768','emayert@example.org','2020-12-26 08:51:39'),
('95','Dayana','Wolff','Mueller','353.399.5950x560','fleta.kunze@example.net','2020-12-26 08:51:39'),
('96','Loyce','Gusikowski','Kozey','(887)294-5805x14','kay33@example.org','2020-12-26 08:51:39'),
('97','Lyda','Little','Kuhlman','+40(9)5883366287','monahan.griffin@example.com','2020-12-26 08:51:39'),
('98','Verlie','VonRueden','Stamm','528.510.7849x691','chesley.mraz@example.org','2020-12-26 08:51:39'),
('99','Jayson','Breitenberg','Bernier','1-287-704-4137x0','swaniawski.destiney@example.net','2020-12-26 08:51:39'),
('100','Carroll','Quigley','King','303.019.0305','abigail.leffler@example.org','2020-12-26 08:51:39'); 
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
SELECT 0, concat('Закупка в онлайн-магазине "Все для кондитера"', a.N), DATE_ADD(NOW(), INTERVAL FLOOR(1 + (RAND() * 4)) day)  
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
(confectioner_id, order_item_id, starttime)
VALUES(null, 1, DATE_ADD(NOW(), INTERVAL FLOOR(1 + (RAND() * 4)) day));

-- select * from candycrm.cooking_slots


COMMIT;