/*1. Посчитайте, сколько компаний закрылось.*/
select count(status) 
from company 
where status = 'closed';

/*2. Отобразите количество привлечённых средств для новостных компаний США. 
Используйте данные из таблицы company. 
Отсортируйте таблицу по убыванию значений в поле funding_total .*/
select funding_total 
from company   
where category_code='news' and country_code='USA' 
order by funding_total desc;

/*3 Найдите общую сумму сделок по покупке одних компаний другими в долларах.
Отберите сделки, которые осуществлялись только за наличные с 2011 по 2013 год включительно.*/
select sum(price_amount) 
from acquisition 
WHERE term_code='cash' and EXTRACT(YEAR FROM CAST(acquired_at AS DATE)) BETWEEN 2011 AND 2013

/*4 Отобразите имя, фамилию и названия аккаунтов людей в твиттере, у которых названия аккаунтов начинаются на 'Silver'.*/
select first_name,last_name,twitter_username 
from people 
where twitter_username like 'Silver%';

/*5 Выведите на экран всю информацию о людях, у которых названия 
#аккаунтов в твиттере содержат подстроку 'money', а фамилия начинается на 'K'.*/

select * 
from people 
where twitter_username like '%money%' and last_name like 'K%';

/*6 Для каждой страны отобразите общую сумму привлечённых инвестиций, 
которые получили компании, зарегистрированные в этой стране. 
Страну, в которой зарегистрирована компания, можно определить по коду страны. Отсортируйте данные по убыванию суммы.*/
SELECT country_code, SUM(funding_total) 
FROM company 
GROUP BY country_code 
ORDER BY SUM(funding_total) DESC;

/*7.Составьте таблицу, в которую войдёт дата проведения раунда, 
# а также минимальное и максимальное значения суммы инвестиций, привлечённых в эту дату. 
# Оставьте в итоговой таблице только те записи, в которых минимальное значение 
# суммы инвестиций не равно нулю и не равно максимальному значению.*/
SELECT funded_at, min(raised_amount),max(raised_amount) 
FROM funding_round 
GROUP BY funded_at 
HAVING MIN(raised_amount) != 0 AND MIN(raised_amount) != MAX(raised_amount);

/*8. Создайте поле с категориями: 
# Для фондов, которые инвестируют в 100 и более компаний, 
# назначьте категорию high_activity. Для фондов, 
# которые инвестируют в 20 и более компаний до 100, назначьте категорию middle_activity. 
# Если количество инвестируемых компаний фонда не достигает 20, 
# назначьте категорию low_activity. Отобразите все поля таблицы fund и новое поле с категориями.*/
SELECT *, 
    CASE 
        WHEN invested_companies >= 100 THEN 'high_activity'     
        WHEN invested_companies BETWEEN 20 AND 99 THEN 'middle_activity'     
        WHEN invested_companies < 20 THEN 'low_activity' 
    END  
FROM fund;

/*9. Для каждой из категорий, назначенных в предыдущем задании, 
посчитайте округлённое до ближайшего целого числа среднее количество инвестиционных раундов, 
в которых фонд принимал участие. Выведите на экран категории и среднее число инвестиционных раундов. 
Отсортируйте таблицу по возрастанию среднего.*/
SELECT        
    CASE                
        WHEN invested_companies>=100 THEN 'high_activity'
        WHEN invested_companies>=20 THEN 'middle_activity'
        ELSE 'low_activity'        
    END AS activ, ROUND(AVG(investment_rounds)) 
FROM fund 
GROUP BY activ 
ORDER BY round;

/*10. Проанализируйте, в каких странах находятся фонды, которые чаще всего инвестируют в стартапы.  
Для каждой страны посчитайте минимальное, максимальное и среднее число компаний, 
в которые инвестировали фонды этой страны, основанные с 2010 по 2012 год включительно. 
Исключите страны с фондами, у которых минимальное число компаний, получивших инвестиции, равно нулю.  
Выгрузите десять самых активных стран-инвесторов: отсортируйте таблицу 
по среднему количеству компаний от большего к меньшему. Затем добавьте сортировку по коду страны в лексикографическом порядке.*/
SELECT 
country_code,MIN(invested_companies),MAX(invested_companies),AVG(invested_companies) 
FROM fund 
WHERE EXTRACT(YEAR FROM founded_at) BETWEEN '2010' AND '2012'
GROUP BY country_code 
HAVING MIN(invested_companies) != 0 
ORDER BY avg DESC 
LIMIT 10;

/*11. Отобразите имя и фамилию всех сотрудников стартапов. 
Добавьте поле с названием учебного заведения, которое окончил сотрудник, если эта информация известна.*/
SELECT p.first_name, p.last_name,e.instituition 
FROM people AS p 
LEFT OUTER JOIN education AS e ON p.id=e.person_id;

/*12. Для каждой компании найдите количество учебных заведений, которые окончили её сотрудники. 
Выведите название компании и число уникальных названий учебных заведений. 
Составьте топ-5 компаний по количеству университетов.*/
SELECT co.name, COUNT(DISTINCT(e.instituition))  
FROM people AS pe 
LEFT JOIN education AS e ON p.id=e.person_id 
LEFT JOIN company AS co ON p.company_id=co.id  
GROUP BY co.name 
ORDER BY count DESC 
LIMIT 5 OFFSET 1;

/*13. Составьте список с уникальными названиями закрытых компаний, для которых первый раунд финансирования оказался последним.*/
SELECT DISTINCT(co.name) 
FROM company AS co WHERE status = 'closed' AND id IN ( 
    SELECT company_id     
    FROM funding_round     
    WHERE is_first_round = 1 AND is_last_round = 1);

/*14. Составьте список уникальных номеров сотрудников, 
которые работают в компаниях, отобранных в предыдущем задании.*/

SELECT pe.id 
FROM people AS pe
WHERE company_id IN (
    SELECT id
    FROM company AS co
    WHERE status = 'closed' AND id IN (
        SELECT company_id
        FROM funding_round
        WHERE is_first_round = 1 AND is_last_round = 1));

/*15. Составьте таблицу, куда войдут уникальные пары с номерами сотрудников из предыдущей задачи и учебным заведением, 
которое окончил сотрудник.*/
SELECT DISTINCT(pe.id), e.instituition 
FROM people AS pe LEFT JOIN education AS e ON p.id=e.person_id 
WHERE company_id IN (     
    SELECT id
    FROM company AS co
    WHERE status = 'closed'AND id IN (
        SELECT company_id
        FROM funding_round
        WHERE is_first_round = 1 AND is_last_round = 1))
    AND e.instituition IS NOT NULL;

/*16. Посчитайте количество учебных заведений для каждого сотрудника из предыдущего задания. 
При подсчёте учитывайте, что некоторые сотрудники могли окончить одно и то же заведение дважды.*/
SELECT DISTINCT(pe.id), COUNT(e.instituition) 
FROM people AS pe LEFT JOIN education AS e ON p.id=e.person_id 
WHERE company_id IN (
    SELECT id
    FROM company AS co 
    WHERE status = 'closed' AND id IN (
        SELECT company_id
        FROM funding_round
        WHERE is_first_round = 1 AND is_last_round = 1))
    AND e.instituition IS NOT NULL 
GROUP BY pe.id;

/*17. Дополните предыдущий запрос и выведите среднее число учебных заведений (всех, не только уникальных), 
которые окончили сотрудники разных компаний. Нужно вывести только одну запись, группировка здесь не понадобится.*/
WITH i AS (
    SELECT DISTINCT(pe.id), COUNT(e.instituition) 
    FROM people AS pe 
    LEFT JOIN education AS e ON p.id=e.person_id
    WHERE company_id IN (
        SELECT id
        FROM company AS co
        WHERE status = 'closed' AND id IN (
            SELECT company_id
            FROM funding_round
            WHERE is_first_round = 1 AND is_last_round = 1))
        AND e.instituition IS NOT NULL 
        GROUP BY pe.id)  
SELECT AVG(count) 
FROM i;

/*18. Напишите похожий запрос: выведите среднее число учебных заведений (всех, не только уникальных), 
которые окончили сотрудники Facebook*. *(сервис, запрещённый на территории РФ)*/
WITH a AS (
    SELECT (pe.id), COUNT(e.instituition)
    FROM people AS pe
    LEFT JOIN education AS e ON p.id=e.person_id
    WHERE company_id IN (
        SELECT id
        FROM company AS co
        WHERE name = 'Facebook')
    AND e.instituition IS NOT NULL
    GROUP BY pe.id) 
SELECT AVG(count) 
FROM a;

/*19. Составьте таблицу из полей: name_of_fund — название фонда; 
name_of_company — название компании; amount — сумма инвестиций,
которую привлекла компания в раунде. В таблицу войдут данные о компаниях, 
в истории которых было больше шести важных этапов, а раунды финансирования проходили с 2012 по 2013 год включительно*/
SELECT f.name AS f_name,c.name AS co_name,fr.raised_amount AS amo
FROM investment AS i 
LEFT JOIN company AS co ON i.company_id=c.id 
LEFT JOIN fund AS f ON i.fund_id=f.id 
LEFT JOIN funding_round AS fr ON i.funding_round_id=fr.id 
WHERE i.company_id IN (
    SELECT id
    FROM company
    WHERE milestones > 6) AND EXTRACT(YEAR FROM funded_at) IN (2012, 2013);

/*20. Выгрузите таблицу, в которой будут такие поля: название компании-покупателя; 
сумма сделки; название компании, которую купили; сумма инвестиций, вложенных в купленную компанию; 
доля, которая отображает, во сколько раз сумма покупки превысила сумму вложенных в компанию инвестиций, 
округлённая до ближайшего целого числа. Не учитывайте те сделки, в которых сумма покупки равна нулю. 
Если сумма инвестиций в компанию равна нулю, исключите такую компанию из таблицы.  
Отсортируйте таблицу по сумме сделки от большей к меньшей, а затем по названию купленной 
компании в лексикографическом порядке. Ограничьте таблицу первыми десятью записями.*/
SELECT c.name AS acquiring_name,
a.price_amount,c2.name AS acquired_name,
c2.funding_total,
ROUND((a.price_amount / c2.funding_total))  
FROM acquisition AS a 
LEFT JOIN company AS co ON a.acquiring_company_id=co.id 
LEFT JOIN company AS co2 ON a.acquired_company_id=co2.id 
WHERE a.price_amount != 0 AND co2.funding_total != 0 
ORDER BY  a.price_amount DESC, co2.name 
LIMIT 10;

/*21. Выгрузите таблицу, в которую войдут названия компаний из категории social, 
получившие финансирование с 2010 по 2013 год включительно. 
Проверьте, что сумма инвестиций не равна нулю. Выведите также номер месяца, в котором проходил раунд финансирования.*/
SELECT  co.name AS social_co, EXTRACT (MONTH FROM fr.funded_at) AS month 
FROM company AS co 
LEFT JOIN funding_round AS fr ON co.id = fr.company_id 
WHERE co.category_code = 'social' AND fr.funded_at BETWEEN '2010-01-01' AND '2013-12-31' AND fr.raised_amount <> 0;

/*22. Отберите данные по месяцам с 2010 по 2013 год, когда проходили инвестиционные раунды. 
Сгруппируйте данные по номеру месяца и получите таблицу, в которой будут поля: номер месяца,
в котором проходили раунды; количество уникальных названий фондов из США, 
которые инвестировали в этом месяце; количество компаний, купленных за этот месяц; 
общая сумма сделок по покупкам в этом месяце.*/
WITH fundings AS (
    SELECT EXTRACT(MONTH FROM CAST(fr.funded_at AS DATE)) AS funding_month, 
    COUNT(DISTINCT f.id) AS funds 
    FROM fund AS f 
    LEFT JOIN investment AS i ON f.id = i.fund_id 
    LEFT JOIN funding_round AS fr ON i.funding_round_id = fr.id 
    WHERE f.country_code = 'USA' AND EXTRACT(YEAR FROM CAST(fr.funded_at AS DATE)) BETWEEN 2010 AND 2013 
    GROUP BY funding_month), acquisitions AS (
        SELECT EXTRACT(MONTH FROM CAST(acquired_at AS DATE)) AS funding_month,
        COUNT(acquired_company_id) AS bought_co,
        SUM(price_amount) AS sum_total 
        FROM acquisition 
        WHERE EXTRACT(YEAR FROM CAST(acquired_at AS DATE)) BETWEEN 2010 AND 2013 
        GROUP BY funding_month) 
SELECT fundi.funding_month, fundi.funds, acq.bought_co, acq.sum_total 
FROM fundings AS fundi 
LEFT JOIN acquisitions AS acq ON fundi.funding_month = acq.funding_month;

/*23. Составьте сводную таблицу и выведите среднюю сумму инвестиций для стран, 
в которых есть стартапы, зарегистрированные в 2011, 2012 и 2013 годах. 
Данные за каждый год должны быть в отдельном поле. 
Отсортируйте таблицу по среднему значению инвестиций за 2011 год от большего к меньшему.*/
WITH a AS (
    SELECT country_code AS co
    FROM company
    WHERE EXTRACT(YEAR FROM founded_at) BETWEEN 2011 AND 2013
    GROUP BY co),
year_2011 AS (
    SELECT country_code AS co, 
    AVG(funding_total) AS avg_2011
    FROM company
    WHERE EXTRACT(YEAR FROM founded_at) = 2011
    GROUP BY country_code),
year_2012 AS (
    SELECT country_code AS co, 
    AVG(funding_total) AS avg_2012
    FROM company
    WHERE EXTRACT(YEAR FROM founded_at) = 2012
    GROUP BY country_code),
year_2013 AS (
    SELECT country_code AS co, 
    AVG(funding_total) AS avg_2013
    FROM company
    WHERE EXTRACT(YEAR FROM founded_at) = 2013
    GROUP BY country_code)  
SELECT year_2011.co,year_2011.avg_2011, year_2012.avg_2012,year_2013.avg_2013
FROM year_2011 INNER JOIN year_2012 ON year_2011.co=year_2012.co 
INNER JOIN year_2013 ON year_2012.co=year_2013.co  
ORDER BY avg_2011 DESC;
