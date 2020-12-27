-- выбрать информацию по рецептам, по которым получена хотя оценка 3 и ниже по результатм отзыва по заказу

SELECT or2.rating, or2.review_text, r2.name as recipe_name, ri.name as range_item_name, CONCAT(c2.first_name, ' ', c2.last_name)  FROM candycrm.order_reviews or2 
		left join order_range_items ori on ori.order_id = or2.order_id
		left join orders ors on ors.id = ori.order_id
		left join customers c2 on c2.id = ors.customer_id 
		left join range_items ri  on ori.range_item_id = ri.id 
		left join recipes r2 on r2.id = ri.recipe_id 
		where or2.rating <= 3;
		
-- выбрать три самых популярных позиций ассортимента в заказах
SELECT  ori.q_sum, ri.name FROM 
		(SELECT sum(ort.quantity) q_sum, ort.range_item_id FROM order_range_items ort
		GROUP BY ort.range_item_id 
		ORDER BY q_sum DESC LIMIT 3) ori  
		left join range_items ri  on ori.range_item_id = ri.id; 
		
-- информация о временных слотах приготовления заказа
SELECT ori.id, ri.name , cs.starttime, cs.stoptime, cs.status FROM  order_range_items ori 
		INNER JOIN cooking_slots cs on ori.range_item_id = cs.order_item_id
		LEFT JOIN range_items ri on ori.range_item_id = ri.id
		WHERE ori.order_id  = 2
		ORDER BY ori.id

		
-- Суммарная стоимость и суммарный вес закупленных ингридиентов 
SELECT SUM(pi2.cost) AS total_cost, SUM(pi2.weigth_per_item * pi2.quantity) as total_weight, c.name as ingridient_name, c.id as ingridient_id 
					 FROM purchase_items pi2
					 INNER JOIN commodities c ON pi2.commodity_id = c.id 	
					 WHERE c.is_ingredient = TRUE AND c.is_weight = TRUE
					 GROUP BY pi2.commodity_id 	

		