-- проверим достаточно ли продуктов в кладовой для приготовления заказа
use candycrm;


-- select * from larder_fact_weight_resiues;		


DROP FUNCTION IF EXISTS check_is_ingredients_enough_for_order;
DELIMITER //
CREATE FUNCTION check_is_ingredients_enough_for_order (order_id BIGINT)
RETURNS BOOL READS SQL DATA
BEGIN
	DECLARE need_weight decimal(9,3);
	DECLARE fact_weight decimal(9,3);
	DECLARE need_quantity INT;
	DECLARE fact_quantity INT;
	DECLARE cid_value BIGINT;
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
		
	
	OPEN cur_weight_data;
	cycle1: LOOP
		FETCH cur_weight_data INTO cid_value, need_weight, fact_weight;
		IF fact_weight IS NULL THEN RETURN FALSE;
		END IF;
		IF fact_weight < need_weight THEN RETURN FALSE; 
		END IF;
	END LOOP cycle1;
	
	CLOSE cur_weight_data;

	OPEN cur_non_weight_data;
	cycle2: LOOP
		FETCH cur_non_weight_data INTO cid_value, need_quantity, fact_quantity;
		IF fact_quantity IS NULL THEN RETURN FALSE;
		END IF;
		IF fact_quantity < need_quantity THEN RETURN FALSE; 
		END IF;
	END LOOP cycle2;
	
	CLOSE cur_non_weight_data;
	
	RETURN TRUE;
END//

DELIMITER ;

-- SELECT check_is_ingredients_enough_for_order(2);

