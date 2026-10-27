SELECT *
FROM {{ source('looker_ecommerce', 'inventory_items') }} -- Fill in the source 