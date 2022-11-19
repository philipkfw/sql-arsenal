
-- MERGE INTO
-- Goal: to easily append NEW data as opposed to replacing the data table

CREATE TEMPORARY VIEW my_view AS (
    SELECT
        dt
        ,category
        ,total_orders
    FROM table_1
    WHERE dt BETWEEN (CURRENT_DATE - 5) AND CURRENT_DATE -- rolling 5-day window
    GROUP BY 1,2
)

MERGE INTO table_1
USING my_view
ON table_1.dt = my_view.dt
    AND table_1.category = my_view.category

WHEN MATCHED THEN
    UPDATE SET
        total_orders = my_view.total_orders

WHEN NOT MATCHED THEN INSERT *;


-- Replacing data table values 
-- Goal: whenever we're looking to replace data values without dropping table 

TRUNCATE table_1;
INSERT INTO table_1 (
    SELECT * FROM table_source
);


-- Combining two data tables with different columns
-- Goal: join clauses can easily filter values without knowing - thus should be unioned

WITH my_cte AS (
    SELECT
        primary_key
        ,CAST(0 AS INT) AS annual_revenue
        ,annual_cost
    FROM table_1
    
    UNION ALL
    
    SELECT
        primary_key
        ,annual_revenue
        ,CAST(0 AS INT) AS annual_cost
    FROM table_2
)

SELECT
    primary_key
    ,SUM(annual_revenue) AS annual_revenue
    ,SUM(annual_cost) AS annual_cost
FROM my_cte
GROUP BY 1;


-- QA Check: Reconciling between upstream table and downstream table
-- Goal: to easily validate alignment of aggregate results between multiple data sources

WITH upstream_cte AS (
    SELECT
        YEAR(dt) AS yr
        ,MONTH(dt) AS mnth
        ,COUNT(*) AS record_count
    FROM upstream_table
    WHERE 1=1
        AND YEAR(dt) = YEAR(CURRENT_DATE)
        AND MONTH(dt) = MONTH(CURRENT_DATE)
    GROUP BY 1,2
),

downstream_cte AS (
    SELECT
        YEAR(dt) AS yr
        ,MONTH(dt) AS mnth
        ,COUNT(*) AS record_count
    FROM downstream_table
    WHERE 1=1
        AND YEAR(dt) = YEAR(CURRENT_DATE)
        AND MONTH(dt) = MONTH(CURRENT_DATE)
    GROUP BY 1,2
)

SELECT 'upstream table' AS TB, record_count FROM upstream_cte
UNION ALL
SELECT 'downstream table' AS TB, record_count FROM downstream_cte;

