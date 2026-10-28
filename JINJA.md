## JINJA

### Los tres lenguajes de dbt

| Lenguaje | Uso | Ejemplo |
|---|---|---|
| SQL | Transformaciones | `SELECT * FROM ...` |
| YAML | Documentación y tests | `- name: customers` / `description: A data mart` |
| Jinja | Templating (plantillas) | `FROM {{ ref('stg_looker__users') }}` |

### Qué es Jinja

- Lenguaje de plantillas inspirado en Python (*Pythonic*).
- Permite generar SQL de forma dinámica.
- Se usa en modelos, macros, tests, etc.
- Ventajas: mejor colaboración y menos repetición (DRY), con código más reutilizable.

Ejemplos de uso:

```sql
-- Referenciar modelos dbt
SELECT *
FROM {{ ref('stg_looker__users') }}

-- Crear bucles
{% for column in ['col1', 'col2'] %}
  SELECT {{ column }}
  FROM table_name
{% endfor %}
```

### Tipos de Jinja

| Tipo | Delimitador | Ejemplo |
|---|---|---|
| Sentencias (*statements*) | `{% ... %}` | `{% set order_statuses = ['Shipped', 'Complete', 'Processing'] %}` |
| Expresiones (*expressions*) | `{{ ... }}` | `SELECT * FROM {{ ref('stg_looker__users') }}` |
| Comentarios | `{# ... #}` | `{# Esto es un comentario #}` |

Los comentarios Jinja no aparecen en el SQL compilado, a diferencia de los comentarios SQL (`--`).

### Sentencias: `set`

Existen varios tipos de sentencias: `set`, bucles (`for`), condicionales (`if/else`), macros, etc. `set` crea una variable y le asigna un valor.

```jinja
{% set country = 'Australia' %}
```

Ejemplo con una lista, útil para evitar repetir código. En `customers.sql` los conteos por estado se repiten cinco veces y podrían generarse con un bucle:

```sql
{% set order_statuses = ['Shipped', 'Complete', 'Processing', 'Cancelled', 'Returned'] %}

SELECT
    user_id,
    {% for status in order_statuses %}
    COUNT(DISTINCT CASE WHEN status = '{{ status }}' THEN order_id END)
        AS num_orders_{{ status | lower }}
    {%- if not loop.last %},{% endif %}
    {% endfor %}
FROM {{ ref('stg_looker__orders') }}
GROUP BY 1
```

Un condicional:

```sql
SELECT *
FROM {{ ref('stg_looker__orders') }}
{% if target.name == 'dev' %}
LIMIT 100
{% endif %}
```

### Jinja y `dbt compile`

`dbt compile` convierte el Jinja en SQL puro, sin ejecutarlo contra la base de datos.

Dentro de `customers.sql`, tal como se escribe:

```sql
{% set country = 'Australia' %}

SELECT ...
FROM ...
WHERE country = '{{ country }}'
```

Salida de `dbt compile -s customers.sql`:

```sql
SELECT ...
FROM ...
WHERE country = 'Australia'
```

La sentencia `{% set %}` desaparece (deja una línea en blanco) y `{{ country }}` se reemplaza por su valor.

### Salida de `dbt compile`

- En la terminal se muestra el SQL compilado de un modelo (`Compiled node 'customers' is: ...`). Ahí `ref('stg_looker__users')` se convierte en la ruta completa, por ejemplo `"dbt"."main"."stg_looker__users"`.
- Además, dbt guarda los archivos compilados en `target/compiled/looker_ecommerce/models/...` (por ejemplo `.../models/marts/`). Es útil para revisar el SQL final o depurar errores.

```bash
dbt compile                      # compila todos los modelos
dbt compile -s customers.sql     # compila un modelo y muestra el SQL
```
