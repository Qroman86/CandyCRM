
use candycrm;

DELIMITER //

DROP PROCEDURE IF EXISTS generate_larderitems//
CREATE PROCEDURE generate_larderitems (IN purchases_id BIGINT)
BEGIN
  
	

END//

-- рассчитываем суммарную стоимость закупки в случае, когда переводим в статус "DONE"
DROP TRIGGER IF EXISTS before_purchase_update//
CREATE TRIGGER before_purchase_update BEFORE UPDATE ON purchases
	FOR EACH ROW BEGIN
	    DECLARE total_cost Decimal(9,3);
	    SET total_cost = 0;
		IF NEW.status = 'DONE' AND OLD.status != 'DONE' THEN
			SELECT  SUM(cost) INTO total_cost FROM purchase_items where purchase_id = NEW.ID;
			SET NEW.total_sum = total_cost;
		END IF;
END//
	
-- select * from purchases
-- update purchases set status = 'DONE' where id = 1

-- проверим достаточно ли продуктов в кладовой для приготовления заказа	
DROP FUNCTION IF EXISTS check_is_ingredients_enough_for_order//
CREATE FUNCTION check_is_ingredients_enough_for_order (order_id BIGINT)
RETURNS BOOL READS SQL DATA
BEGIN
	DECLARE need_weight decimal(9,3);
	DECLARE fact_weight decimal(9,3);
	DECLARE need_quantity INT;
	DECLARE fact_quantity INT;
	DECLARE cid_value BIGINT;
	DECLARE result_value BOOL;
	
	DECLARE cur_weight_data CURSOR FOR WITH  c AS (SELECT v.cid, SUM(v.weight) as sum_weight FROM commodities_for_order_view v		
		where v.order_id = order_id
		and v.is_ingredient = TRUE
		GROUP BY v.cid),
		l as (SELECT SUM(lfwr.fact_abs_weight_residue) AS sum_abs_fact_weight, lfwr.cid 
		FROM larder_fact_weight_resiues lfwr 
		GROUP BY lfwr.cid)
		SELECT c.cid, c.sum_weight as need_weight, l.sum_abs_fact_weight FROM c
		LEFT JOIN l ON l.cid = c.cid;	
	
	DECLARE cur_non_weight_data CURSOR FOR WITH c AS (SELECT sum(quantity) as sum_quantity, cid FROM commodities_for_order_view v
		where v.order_id = order_id
		and v.is_ingredient = FALSE
		GROUP BY v.cid),
		l as (SELECT SUM(lnfwr.quantity) AS sum_abs_fact_quantity, lnfwr.cid 
		FROM larder_fact_non_weight_resiues lnfwr 
		GROUP BY lnfwr.cid)
		SELECT c.cid, c.sum_quantity as need_quantity, l.sum_abs_fact_quantity  FROM c
		LEFT JOIN l ON l.cid = c.cid;
		
	SET result_value = TRUE;
	OPEN cur_weight_data;
	cycle1: LOOP
		FETCH cur_weight_data INTO cid_value, need_weight, fact_weight;
		IF fact_weight IS NULL THEN 
			SET result_value = FALSE;
			LEAVE cycle1;
		END IF;
		IF fact_weight < need_weight THEN 
			SET result_value = FALSE;
			LEAVE cycle1; 
		END IF;
	END LOOP cycle1;
	
	CLOSE cur_weight_data;

	OPEN cur_non_weight_data;
	cycle2: LOOP
		FETCH cur_non_weight_data INTO cid_value, need_quantity, fact_quantity;
		IF fact_quantity IS NULL THEN 
			SET result_value = FALSE;
			LEAVE cycle2;
		END IF;
		IF fact_quantity < need_quantity THEN 
			SET result_value = FALSE;
			LEAVE cycle2; 
		END IF;
	END LOOP cycle2;
	
	CLOSE cur_non_weight_data;
	
	RETURN result_value;
END//



-- SELECT check_is_ingredients_enough_for_order(2);

-- процедура генерации закупок

DROP PROCEDURE IF EXISTS generate_purchase//
CREATE PROCEDURE generate_purchase (IN order_id_in BIGINT)
BEGIN
  
  DECLARE need_weight decimal(9,3);
  DECLARE fact_weight decimal(9,3);
  DECLARE need_quantity INT;
  DECLARE fact_quantity INT;
  DECLARE cid_value BIGINT;	
  DECLARE current_purchase_id BIGINT;
  DECLARE result_value VARCHAR(128);
  DECLARE finished INTEGER DEFAULT 0;
  DECLARE cur_weight_data2 CURSOR FOR WITH  c AS (SELECT v.cid, SUM(v.weight) as sum_weight FROM commodities_for_order_view v		
		where v.order_id = order_id_in
		and v.is_ingredient = TRUE
		GROUP BY v.cid),
		l as (SELECT SUM(lfwr.fact_abs_weight_residue) AS sum_abs_fact_weight, lfwr.cid 
		FROM larder_fact_weight_resiues lfwr 
		GROUP BY lfwr.cid)
		SELECT c.cid, c.sum_weight as need_weight, l.sum_abs_fact_weight FROM c
		LEFT JOIN l ON l.cid = c.cid;	
	
  DECLARE cur_non_weight_data2 CURSOR FOR WITH c AS (SELECT sum(quantity) as sum_quantity, cid FROM commodities_for_order_view v
		where v.order_id = order_id_in
		and v.is_ingredient = FALSE
		GROUP BY v.cid),
		l as (SELECT SUM(lnfwr.quantity) AS sum_abs_fact_quantity, lnfwr.cid 
		FROM larder_fact_non_weight_resiues lnfwr 
		GROUP BY lnfwr.cid)
		SELECT c.cid, c.sum_quantity as need_quantity, l.sum_abs_fact_quantity  FROM c
		LEFT JOIN l ON l.cid = c.cid;

	
	DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;
       
	SET result_value = 'Не было добавлено ни одной позиции закупки';	
  IF (order_id_in > 0) THEN	
	
	INSERT INTO candycrm.purchases
	(total_sum, name, purchase_time)
	VALUES(0, '', CURRENT_TIMESTAMP);
	SELECT LAST_INSERT_ID() INTO current_purchase_id;

	

	OPEN cur_weight_data2;
	cycle3: LOOP FETCH cur_weight_data2 INTO cid_value, need_weight, fact_weight;
		IF finished = 1 THEN
			LEAVE cycle3;
		END IF;
		IF fact_weight IS NULL THEN
			
			INSERT INTO candycrm.purchase_items
			(purchase_id, commodity_id, quantity, weigth_per_item, cost, name)			
			VALUES(current_purchase_id, cid_value, CEILING(need_weight / 500), 500, 0, '');
			SET result_value = CONCAT( 'Была добавлена по крайней мере одна позиция закупки! Id закупки:', current_purchase_id);
		END IF;
		IF fact_weight < need_weight THEN
			INSERT INTO candycrm.purchase_items
			(purchase_id, commodity_id, quantity, weigth_per_item, cost, name)
			VALUES(current_purchase_id, cid_value, CEILING((need_weight - fact_weight) / 500) , 500, 0, '');
			SET result_value = CONCAT( 'Была добавлена по крайней мере одна позиция закупки! Id закупки:', current_purchase_id);
		END IF;
	END LOOP cycle3;
	
	CLOSE cur_weight_data2;
	SET finished = 0;

	OPEN cur_non_weight_data2;
	cycle4: LOOP
		FETCH cur_non_weight_data2 INTO cid_value, need_quantity, fact_quantity;
		IF finished = 1 THEN
			LEAVE cycle4;
		END IF;
		IF fact_quantity IS NULL THEN
			INSERT INTO candycrm.purchase_items
			(purchase_id, commodity_id, quantity, weigth_per_item, cost, name)
			VALUES(current_purchase_id, cid_value, need_quantity, 500, 0, '');
			SET result_value = CONCAT( 'Была добавлена по крайней мере одна позиция закупки! Id закупки:', current_purchase_id);
		END IF;
		IF fact_quantity < need_quantity THEN
			INSERT INTO candycrm.purchase_items
			(purchase_id, commodity_id, quantity, weigth_per_item, cost, name)
			VALUES(current_purchase_id, cid_value, need_quantity - fact_quantity, 500, 0, '');
			SET result_value = CONCAT( 'Была добавлена по крайней мере одна позиция закупки! Id закупки:', current_purchase_id);
		END IF;
	END LOOP cycle4;
	
	CLOSE cur_non_weight_data2;
	
  
  END IF;
 	SELECT result_value;
END//



 	
DELIMITER ;

-- CALL generate_purchase(1);
-- select * from orders o where id =1;
-- update orders set status = 'INPROGRESS' WHERE id = 1;
-- -select count(*), max(id) from purchases p -- 46
-- -select * from purchase_items pi2 where purchase_id = 18