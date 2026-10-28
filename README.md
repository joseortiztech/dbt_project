# Proyecto dbt – Looker Ecommerce (DuckDB)

## Ramas

| Rama | Qué se trabajó |
|---|---|
| `1_create_seed` | Creación del proyecto dbt y carga de datos crudos con seeds |
| `2_create_users` | Primer modelo staging de `users` y carga de sus datos raw |
| `3_otras_fuentes` | Definición del resto de fuentes (`sources`) y modelos staging: distribution_centers, events, inventory_items, order_items, orders, products |
| `4_agregando_columnas_a_modelos` | Selección, renombrado y documentación de columnas en los modelos |
| `5_testing` | Tests de datos (`unique`, `not_null`, etc.) en algunos modelos |
| `6_data_marts` | Reorganización de `models/` en `staging/` y `marts/`, y creación de los marts `customers` y `products` |
| `7_snapshots` | Snapshots `orders_snapshot` (fuente `orders`, clave `order_id`) e `inventory_snapshot` (fuente `inventory_items`, clave `id`), ambos con estrategia `timestamp` sobre `created_at` y destino en el schema `main` |

## Comandos básicos

```bash
# Entorno
source venv/bin/activate
pip install -r requirements.txt

# Git
git checkout -b <nombre_rama>
git add . && git commit -m "mensaje"
git push -u origin <nombre_rama>

# dbt (desde looker_ecommerce/)
dbt debug              # verificar conexión
dbt seed               # cargar seeds
dbt run                # ejecutar modelos
dbt run -s <modelo>    # ejecutar un modelo específico
dbt test               # correr tests
dbt build              # seed + run + test (+ snapshot)
dbt docs generate      # generar documentación
dbt docs serve         # verla en el navegador
dbt snapshot                       # ejecutar todos los snapshots
dbt snapshot -s orders_snapshot    # ejecutar un snapshot específico

# Selección de modelos
dbt build -s +customers                    # el modelo y sus dependencias
dbt build -s +models/marts/customers.sql   # equivalente por ruta
dbt build -s marts                         # todos los marts
```

## APUNTES

- **Snapshot**: registra el historial de cambios de una tabla fuente (SCD tipo 2). Agrega `dbt_valid_from` y `dbt_valid_to`. Se ejecuta con `dbt snapshot` y solo captura cambios entre ejecuciones.
- **Snapshots del proyecto**: se definen como bloque `{% snapshot %}` en `.sql` dentro de `snapshots/`. Alternativa desde dbt 1.9: archivo `.yml` con `relation` y `schema` (sin SQL). Ambas se ejecutan igual con `dbt snapshot`.
- **Limitación de la config actual**: con `strategy='timestamp'` y `updated_at='created_at'`, los cambios en filas existentes (por ejemplo, el `status` de un pedido) no se detectan, porque `created_at` no cambia. Para capturarlos, usar `strategy='check'` con `check_cols=['status']` o una columna real de actualización.
- **Staging**: primera capa de modelos. Relación 1:1 con las fuentes, solo limpieza (renombrar, castear tipos), sin joins ni agregaciones. Nombre: `stg_<fuente>__<tabla>`.
- **Marts**: capa final para análisis. Aquí van los joins, agregaciones y reglas de negocio, usando `ref()` sobre los modelos staging.
- **Ubicación de modelos**: los marts deben estar dentro de `models/` (`model-paths`); fuera de esa ruta dbt no los detecta y `dbt build` responde "does not match any enabled nodes".
- **Nombres únicos**: dos modelos no pueden tener el mismo nombre dentro de un proyecto, aunque estén en carpetas distintas. Por eso el prefijo `stg_looker__` deja libre `customers` para el mart.
- **Paquete**: otro proyecto dbt que se instala con `packages.yml` y `dbt deps` para reutilizar macros, tests o modelos (por ejemplo `dbt_utils`). Los modelos de paquetes distintos pueden repetir nombre y se distinguen con `ref('paquete', 'modelo')`.
- **Orden de columnas en los marts**: un pequeño apunte: el orden de las columnas del mart sigue libremente esta convención: primero la columna de clave primaria, seguida de columnas de dimensión (texto), y luego columnas de hechos (números, agregaciones, etc).
