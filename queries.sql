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

SELECT CONCAT(TRIM(e.first_name), ' ', TRIM(e.last_name)) AS seller,
       floor(AVG(s.quantity * p.price)) AS average_income
FROM sales s
JOIN employees e ON s.sales_person_id = e.employee_id
JOIN products p ON s.product_id = p.product_id
GROUP BY seller
HAVING AVG(s.quantity * p.price) < (SELECT AVG(quantity * price) AS global_avg_income
                                    FROM sales s
                                    JOIN products p ON s.product_id = p.product_id) 
ORDER BY AVG(s.quantity * p.price) asc;
-- проект 1_задание 5_часть 2 : Выводим 2 оконные функции со всеми продавцами и их средней выручкой по сделке, и оконная функция со средней выручкой по сделке в целом. Далее выводим имя и фам продавца со средней выручкой по 1 сделке, которая меньше средней выручки по рынку/магазину в целом. 

SELECT
  CONCAT(TRIM(e.first_name), ' ', TRIM(e.last_name)) AS seller,
  lower(TO_CHAR(s.sale_date, 'Day')) AS day_of_week,
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



SELECT 
CASE
WHEN age BETWEEN 16 AND 25 THEN '16-25'
WHEN age BETWEEN 26 AND 40 THEN '26-40'
WHEN age > 40 THEN '40+'
END AS age_category,
COUNT(distinct (customer_id)) AS age_count 
FROM customers
GROUP BY age_category;
-- проект 1_задание 6_часть 1 : Вспомогательный подзапрос классифицирует всех покупателей в БД customers по возрастным категориям, далее выводим таблицу с кол-вом уникальных покупателей по каждой возрастной категории


SELECT
TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
COUNT(DISTINCT s.customer_id) AS total_customers,
floor(SUM(p.price * s.quantity)) AS income
FROM sales s
JOIN products p ON s.product_id = p.product_id  
GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM')
ORDER BY selling_month ASC;
-- проект 1_задание 6_часть 2 : Запрос выводит месяцы продаж с кол-вом уникальных покупателей и округленной общей выручкой от них


WITH ranking AS (
    SELECT
        CONCAT(c.first_name, ' ', c.last_name) AS customer, 
        s.sale_date,
        CONCAT(e.first_name, ' ', e.last_name) AS seller,
        ROW_NUMBER() OVER (PARTITION BY c.customer_id ORDER BY s.sale_date ASC) AS rn
    FROM sales s
    JOIN customers c ON c.customer_id = s.customer_id
    JOIN employees e ON s.sales_person_id = e.employee_id 
    JOIN products p ON s.product_id = p.product_id  
    WHERE p.price = 0
)
SELECT customer, sale_date, seller
FROM ranking
WHERE rn = 1
ORDER BY customer;
-- проект 1_задание 6_часть 3 : Подзапрос 1 выводит сконкатенированную строку с именем и фамилией покупателя, его датой первой покупки с суммой затрат, при этом сумма затрат = 0. Подзапрос 2 выводит сконкатенированную строку с именем и фамилией покупателя, его датой первой покупки и сконкатенированную строку с именем и фамилией продавца. Итоговый запрос выводит ФИ покупателя, дату первой покупки и ФИ продавца с сортировкой по покупателю.
