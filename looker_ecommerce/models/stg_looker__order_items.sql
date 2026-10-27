SELECT *
FROM {{ source('looker_ecommerce', 'order_items') }} -- Fill in the source 