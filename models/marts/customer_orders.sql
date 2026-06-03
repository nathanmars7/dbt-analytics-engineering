with customers as (

    select * from {{ ref('stg_customers') }}

),

orders as (

    select * from {{ ref('stg_orders') }}

),

customer_orders as (

    select
        c.customer_id,
        c.first_name || ' ' || c.last_name as full_name,

        -- count() of all-NULL orders (no-order customers) is naturally 0
        count(o.order_id) as total_orders,

        -- sum()/avg() over an empty group return NULL, so coalesce to 0
        cast(coalesce(sum(o.amount), 0) as decimal(10, 2)) as total_spend,
        cast(coalesce(avg(o.amount), 0) as decimal(10, 2)) as avg_order_value,

        -- conditional counts via FILTER; count() already yields 0 when empty
        count(case when status = 'completed' then 1 end) as completed_orders, --count(o.order_id) filter (where o.status = 'completed') as completed_orders,
        count(case when status = 'returned' then 1 end) as returned_orders, --count(o.order_id) filter (where o.status = 'returned') as returned_orders,

    from customers as c
    left join orders as o
        on c.customer_id = o.customer_id

    group by c.customer_id, c.first_name, c.last_name

)

select
    customer_id,
    full_name,
    total_orders,
    total_spend,
    avg_order_value,
    completed_orders,
    returned_orders

from customer_orders
