SELECT *
FROM {{ source('looker_ecommerce', 'orders') }}