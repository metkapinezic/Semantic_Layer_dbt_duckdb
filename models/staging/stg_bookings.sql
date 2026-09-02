with source as (
    select * from {{ source('freenow_raw', 'bookings') }}
),

bookings as (

    select
        id                                  as booking_id,
        cast(request_date as timestamp)     as requested_at, -- forcing timestamp
        status                               as booking_status,
        nullif(id_driver, 'null')            as driver_id, -- fixing the "null" issue
        cast(nullif(estimated_route_fare, 'null') as decimal(18,2)) as estimated_route_fare_eur, -- forcing decimal, widening, fixing the "null"

    from source

)

select distinct * from bookings -- distinct removes duplicates