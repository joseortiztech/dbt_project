SELECT *
FROM {{ source('looker_ecommerce', 'events') }}