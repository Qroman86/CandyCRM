-- представление формирующее сколько продуктов не хватает по заказу
/*
SELECT ori.id, ori.quantity, ri.name, ri2.ingredient_id, ri2.weight  FROM order_range_items ori
		LEFT JOIN range_items ri on ori.range_item_id = ri.id 
		LEFT JOIN recipe_items ri2 on ri2.recipe_id  = ri.recipe_id 
		WHERE ori.order_id = 1;	

SELECT onri.id, onri.quantity, c2.name FROM order_non_range_items onri		
	LEFT JOIN commodities c2 on c2.id = onri.commodity_item_id 	
	WHERE onri.order_id = 1;			
*/
-- сделаем вью
CREATE OR REPLACE VIEW commodities_for_order_view
AS SELECT ori.order_id, ori.id as oid, ori.quantity, ri.name as cname, ri2.ingredient_id as cid, ri2.weight, c2.is_ingredient  FROM order_range_items ori
		LEFT JOIN range_items ri on ori.range_item_id = ri.id 
		LEFT JOIN recipe_items ri2 on ri2.recipe_id  = ri.recipe_id 
		LEFT JOIN commodities c2 on c2.id = ri2.ingredient_id 
UNION ALL
SELECT onri.order_id, onri.id as oid, onri.quantity, c2.name as cname, c2.id as cid, 0 as weight, c2.is_ingredient FROM order_non_range_items onri		
	LEFT JOIN commodities c2 on c2.id = onri.commodity_item_id;

--select * from commodities_for_order_view;

CREATE OR REPLACE VIEW larder_fact_weight_resiues 
AS SELECT li.id as lid, c.id as cid, li.quantity, li.weight_residue, li.weight_per_item, c.name, 
	li.weight_residue * li.quantity * li.weight_per_item / 100 as fact_abs_weight_residue 	
FROM larder_items li 
	 INNER JOIN commodities c on li.commodity_id = c.id 		
	 WHERE c.is_ingredient = TRUE and c.is_weight = TRUE;		

CREATE OR REPLACE VIEW larder_fact_non_weight_resiues 
AS SELECT li.id as lid, c.id as cid, li.quantity, li.weight_residue, li.weight_per_item, c.name	
FROM larder_items li 
	 INNER JOIN commodities c on li.commodity_id = c.id 		
	 WHERE c.is_ingredient = FALSE and c.is_weight = FALSE;			
	
SELECT * FROM larder_fact_resiues		 

-- появились значения с 0.5 (некритично)
/*
SELECT sum(fact_abs_weight_residue), cid   FROM larder_fact_weight_resiues		
GROUP BY cid


SELECT sum(quantity), cid FROM larder_fact_non_weight_resiues
GROUP BY cid

-- выбираем ингридиенты
SELECT v.cid, SUM(v.weight) FROM commodities_for_order_view v
		where v.order_id = 1
		and v.is_ingredient = TRUE
		GROUP BY v.cid

		
		
SELECT v.cid, sum(quantity) FROM commodities_for_order_view v
		where v.order_id = 1
		and v.is_ingredient = FALSE
		GROUP BY v.cid		
*/		
-- делаем выборку 