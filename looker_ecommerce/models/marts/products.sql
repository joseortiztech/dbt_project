WITH product_base AS (
    SELECT 
        id AS product_id,
        name AS product_name,
        category AS product_category,
        department AS product_department
    FROM {{ ref('stg_looker__products') }}
)

, inventory_items AS (
    SELECT 
        product_id,
        SUM(CASE WHEN sold_at is NOT NULL THEN cost END) AS cost_of_goods_sold
    FROM {{ ref('stg_looker__inventory_items') }}
    -- WHERE sold_at IS NULL
    GROUP BY 1
)

, order_items AS (
    SELECT 
        product_id,
        SUM(sale_price) AS sales_amount
    FROM {{ ref('stg_looker__order_items') }}
    GROUP BY 1    
)

SELECT 
    pb.product_id,
    -- dimensions
    pb.product_name,
    pb.product_category,
    -- facts (e.g. profit analysis)
    oi.sales_amount,
    ii.cost_of_goods_sold,
    oi.sales_amount - ii.cost_of_goods_sold AS profit
FROM product_base pb 
LEFT JOIN inventory_items ii 
    ON pb.product_id = ii.product_id 
LEFT JOIN order_items oi 
    ON pb.product_id = oi.product_id