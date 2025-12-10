– Query 1: Calculate the number of companies that have been closed down.


SELECT COUNT(*) AS closed_companies
FROM company
WHERE status = 'closed';


-- Query 2: Find the funding totals for news-related companies based in the USA for benchmarking. 
SELECT
    funding_total
FROM
    company
WHERE
    country_code = 'USA'
    AND category_code LIKE '%news%'
ORDER BY
    funding_total DESC;


-- Query 3: Calculate the total amount of cash-based acquisitions between 2011 and 2013, inclusive.


SELECT
    SUM(price_amount) AS total_cash_acquisitions
FROM
    acquisition
WHERE
    term_code = 'cash'
    AND acquired_at >= '2011-01-01'
    AND acquired_at <= '2013-12-31';


-- Query 4: Identifying Industry Influencers whose Twitter usernames start with 'Silver' for an outreach campaign.


SELECT first_name, last_name, twitter_username
FROM people
WHERE twitter_username LIKE 'Silver%';
    






-- Query 5: Finding Finance Influencers whose Twitter usernames include 'money' and whose last names start with 'K' for a targeted campaign.


SELECT *
FROM people
WHERE twitter_username LIKE '%money%'
  AND last_name LIKE 'K%';








-- Query 6: Geographic Investment Analysis - Calculate the total funding raised for each country to guide international investment strategy.


SELECT 
    country_code,
    SUM(funding_total) AS total_raised
FROM 
    company
GROUP BY 
    country_code
ORDER BY 
    total_raised DESC;






-- Query 7: Funding Round Volatility Analysis - Identify dates where funding was highly volatile (max != min and min != 0), using the HAVING clause.


SELECT
    funded_at,
    MAX(raised_amount) AS max_raised,
    MIN(raised_amount) AS min_raised
FROM
    funding_round
GROUP BY
    funded_at
HAVING
    MIN(raised_amount) != 0
    AND MIN(raised_amount) != MAX(raised_amount);








-- Query 8: Fund Activity Classification - Use a CASE statement to categorize funds into high, middle, and low activity based on the number of companies invested in.


SELECT
    fund.*,
    CASE
        WHEN invested_companies >= 100 THEN 'high_activity'
        WHEN invested_companies >= 20 AND invested_companies < 100 THEN 'middle_activity'
        ELSE 'low_activity'
    END AS activity_level
FROM
    fund;


-- Query 9: Investment Strategy by Fund Activity - Calculate the average number of funding rounds participated in for each activity category (using CASE, GROUP BY, and AVG).


SELECT
    CASE
        WHEN invested_companies >= 100 THEN 'high_activity'
        WHEN invested_companies >= 20 AND invested_companies < 100 THEN 'middle_activity'
        ELSE 'low_activity'
    END AS activity_level,
    ROUND(AVG(investment_rounds), 0) AS avg_investment_rounds
FROM
    fund
GROUP BY
    activity_level
ORDER BY
    avg_investment_rounds ASC;
-- Query 10: COMPLEX ANALYSIS - Determine the average number of degrees per employee at startups that closed down after only one funding round, using Subqueries and Joins.


SELECT AVG(degree_count) AS avg_degrees_per_employee
FROM (
    SELECT p.id AS person_id,
           COUNT(ed.degree_type) AS degree_count
    FROM people p
    INNER JOIN education ed
        ON p.id = ed.person_id
    WHERE p.company_id IN (
        SELECT fr.company_id
        FROM funding_round fr
        INNER JOIN company c
            ON c.id = fr.company_id
        WHERE c.status = 'closed'
          AND fr.is_first_round = 1
          AND fr.is_last_round = 1
    )
    GROUP BY p.id
) AS sub;