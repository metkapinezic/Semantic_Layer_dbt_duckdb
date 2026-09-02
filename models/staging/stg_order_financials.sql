with source as (

    select * from {{ source('freenow_raw', 'order_financials') }}

),

order_financials as (

    select
        booking_id,
        cast(dt as date)                                    as financial_date, --forcing date
        cast(gmv as decimal(18,2))                          as gmv,-- forcing numeric 2 decimal
        cast(nullif(tip, 'null') as decimal(18,2))          as tip, -- forcing numeric 2 decimal, fixing "null"
        cast(nullif(commission, 'null')as decimal(18,2))    as commission, -- forcing numeric 2 decimal, fixing "null"
        currency,
        payment_method

    from source

)

select distinct * from order_financials -- distinct resolves the duplications