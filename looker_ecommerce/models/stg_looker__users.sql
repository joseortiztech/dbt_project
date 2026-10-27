SELECT *
FROM {{ source('looker_ecommerce', 'users') }} -- Fill in the source 