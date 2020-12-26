-- представление возвращающее количество ингридиентов и количество упаковки, необходимое для приготовления и оформления заказа
CREATE OR REPLACE VIEW commodities_for_order_view
AS SELECT ori.order_id, ori.id as oid, ori.quantity, ri.name as cname, ri2.ingredient_id as cid, ri2.weight, c2.is_ingredient  FROM order_range_items ori
		LEFT JOIN range_items ri on ori.range_item_id = ri.id 
		LEFT JOIN recipe_items ri2 on ri2.recipe_id  = ri.recipe_id 
		LEFT JOIN commodities c2 on c2.id = ri2.ingredient_id 
UNION ALL
SELECT onri.order_id, onri.id as oid, onri.quantity, c2.name as cname, c2.id as cid, 0 as weight, c2.is_ingredient FROM order_non_range_items onri		
	LEFT JOIN commodities c2 on c2.id = onri.commodity_item_id;


-- предстваление, формирующее фактическую информацию о количестве ингридиентов, хранящихся в кладовой
CREATE OR REPLACE VIEW larder_fact_weight_resiues 
AS SELECT li.id as lid, c.id as cid, li.quantity, li.weight_residue, li.weight_per_item, c.name, 
	li.weight_residue * li.quantity * li.weight_per_item / 100 as fact_abs_weight_residue 	
FROM larder_items li 
	 INNER JOIN commodities c on li.commodity_id = c.id 		
	 WHERE c.is_ingredient = TRUE and c.is_weight = TRUE;		

-- представление, формирующее фактическую информацию о количестве упаковок, хранящейся в кладовой	
CREATE OR REPLACE VIEW larder_fact_non_weight_resiues 
AS SELECT li.id as lid, c.id as cid, li.quantity, li.weight_residue, li.weight_per_item, c.name	
FROM larder_items li 
	 INNER JOIN commodities c on li.commodity_id = c.id 		
	 WHERE c.is_ingredient = FALSE and c.is_weight = FALSE;			
	
-- представление, выдающее информацию о том сколько нужно потратить в минутах на приготовление одного заказа
CREATE OR REPLACE VIEW cooking_time_counter
AS SELECT ori.order_id, ori.id as order_item_id, ri.name ,ori.quantity, ori.quantity * r.cook_time_minutes as total_time_in_min, r.cook_time_minutes as time_per_one FROM order_range_items ori 
		 LEFT JOIN range_items ri on ori.range_item_id = ri.id 
		 LEFT JOIN recipes r on ri.recipe_id = r.id
		 
