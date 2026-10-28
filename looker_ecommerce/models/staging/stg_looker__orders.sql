SELECT *
FROM {{ source('looker_ecommerce', 'orders') }} -- Fill in the source 