{{
    config(
        materialized = 'table'
    )
}}

with days as (

    select
        cast(range as date) as date_day
    from range(
        cast('2015-01-01' as date),
        cast('2030-01-01' as date),
        interval 1 day
    )

)

select * from days