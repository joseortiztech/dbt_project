SELECT *
FROM {{ source('looker_ecommerce', 'events') }} -- Fill in the source 