with source as (

    select * from {{ ref('raw_customers') }}

),

renamed as (

    select
        cast(id as integer) as customer_id,
        cast(first_name as varchar) as first_name,
        cast(last_name as varchar) as last_name

    from source

)

select * from renamed
