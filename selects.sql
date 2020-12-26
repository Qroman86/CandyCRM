-- выбрать информацию по рецептам, по которым получена хотя оценка 3 и ниже по результатм отзыва по заказу

SELECT or2.rating, or2.review_text, r2.name, r2.instruction FROM candycrm.order_reviews or2 
		left join order_range_items ori on ori.order_id = or2.order_id 
		left join range_items ri  on ori.range_item_id = ri.id 
		left join recipes r2 on r2.id = ri.recipe_id 
		where or2.rating <= 3;
		
-- выбрать три самых популярных позиций ассортимента в заказах
SELECT  ori.q_sum, ri.name FROM 
		(SELECT sum(ort.quantity) q_sum, ort.range_item_id FROM order_range_items ort
		GROUP BY ort.range_item_id 
		ORDER BY q_sum DESC LIMIT 3) ori  
		left join range_items ri  on ori.range_item_id = ri.id; 
		
-- вывести информацию по продуктам для данного заказа (что есть в кладовой, чего не хватает и сколько)

		
		