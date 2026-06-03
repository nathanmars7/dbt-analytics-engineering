with source as (

    select * from {{ ref('raw_orders') }}

),

renamed as (

    select
        cast(id as integer) as order_id,
        cast(customer_id as integer) as customer_id,
        cast(order_date as date) as order_date,
        cast(amount as decimal(10, 2)) as amount,
        cast(status as varchar) as status

    from source

)

select * from renamed
