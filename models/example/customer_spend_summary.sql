/*
  MODEL NAME: customer_spend_summary
  PURPOSE: Implements business transformation logic on top of sample data.
*/

-- Materialize this model as a physical table in Snowflake
{{ config(materialized='table') }}

WITH base_data AS (
    -- Safely reference the upstream model using the ref() macro
    SELECT 
        id AS customer_id
    FROM {{ ref('my_first_dbt_model') }}
),

transformed_data AS (
    -- Calculate simulated metrics and tiers based on the source IDs
    SELECT
        customer_id,
        CASE 
            WHEN customer_id = 1 THEN 1250.00
            WHEN customer_id = 2 THEN 450.00
            ELSE 0.00 
        END AS lifetime_spend,
        CURRENT_TIMESTAMP() AS processed_at
    FROM base_data
    -- Filter out null testing data records
    WHERE customer_id IS NOT NULL
)

SELECT 
    customer_id,
    lifetime_spend,
    CASE 
        WHEN lifetime_spend >= 1000 THEN 'Tier 1 / VIP'
        ELSE 'Tier 2 / Standard'
    END AS customer_segment,
    processed_at    
FROM transformed_data
