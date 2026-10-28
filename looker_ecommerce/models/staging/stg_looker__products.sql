SELECT *
FROM {{ source('looker_ecommerce', 'products') }} -- Fill in the source 