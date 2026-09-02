with source as (

    select * from {{ source('freenow_raw', 'offers') }}

),

offers as (

    select
        id                                                  as offer_id,
        cast(datecreated as timestamp)                      as offered_at, -- forcing timestamp
        bookingid                                           as booking_id,
        driverid                                            as driver_id,
        cast(nullif(routedistance, 'null') as double)       as route_distance_meters, -- forcing double, fixing "null"
        state                                               as offer_state,
        cast(driverread as boolean)                         as driver_read -- forcing boolean

    from source

)

select * from offers