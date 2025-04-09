SELECT COUNT(DISTINCT(customer_id)) AS customers_count 
FROM customers;
-- проект 1_задание 4: Запрос находит общее количество уникальных покупателей из таблицы customers

SELECT concat(TRIM(e.first_name), ' ', TRIM(e.last_name)) AS seller,
       COUNT(s.sales_id) AS operations,
       floor(sum(p.price * s.quantity)) AS income 
FROM employees e
JOIN sales s ON e.employee_id = s.sales_person_id 
JOIN products p ON p.product_id = s.product_id 
GROUP BY seller
ORDER BY sum(p.price * s.quantity) DESC
LIMIT 10;
-- проект 1_задание 5_часть 1 : Запрос конкатенирует имя и фамилию продавцов в 1 записи (топ-10 по выручке), выводит кол-во продаж и общую выручку на каждого продавца

WITH seller_income AS (
                       SELECT
                             CONCAT(TRIM(e.first_name), ' ', TRIM(e.last_name)) AS seller,
                             AVG(s.quantity * p.price) AS average_income
                       FROM sales s
                       JOIN employees e ON s.sales_person_id = e.employee_id
                       JOIN products p ON s.product_id = p.product_id
                       GROUP BY seller
                      ),
     overall_average AS (
                       SELECT AVG(quantity * price) AS global_avg_income
                       FROM sales s
                       JOIN products p ON s.product_id = p.product_id
                        )
SELECT
  si.seller,
  ROUND(si.average_income)::int AS average_income
FROM seller_income si,
     overall_average oa
WHERE si.average_income < oa.global_avg_income
ORDER BY average_income ASC;
-- проект 1_задание 5_часть 2 : Выводим 2 оконные функции со всеми продавцами и их средней выручкой по сделке, и оконная функция со средней выручкой по сделке в целом. Далее выводим имя и фам продавца со средней выручкой по 1 сделке, которая меньше средней выручки по рынку/магазину в целом. 

SELECT
  CONCAT(TRIM(e.first_name), ' ', TRIM(e.last_name)) AS seller,
  TO_CHAR(s.sale_date, 'Day') AS day_of_week,
  floor(SUM(p.price * s.quantity)) AS income
FROM sales s
JOIN employees e ON s.sales_person_id = e.employee_id
JOIN products p ON s.product_id = p.product_id
GROUP BY 
  seller,
  day_of_week,
  EXTRACT(ISODOW FROM s.sale_date)
ORDER BY 
  EXTRACT(ISODOW FROM s.sale_date),
  seller;
-- проект 1_задание 5_часть 3 : Запрос конкатенирует имя и фамилию продавца в 1 записи, выводит к ним день недели продажи в формате названия дня недели и выводит доход по купленным товарам, округленный в меньшую сторону и сортирует записи по продавцу, дню недели, номеру дня недели 
