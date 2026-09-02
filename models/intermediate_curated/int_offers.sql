-- models/intermediate_curated/int_offers.sql

with offers as (
    select * from {{ ref('stg_offers') }}
),

bookings as (
    select
        booking_id,
        booking_status,
        requested_at
    from {{ ref('stg_bookings') }}
),

drivers as (
    select * from {{ ref('stg_drivers') }}
),

final as (
    select
        o.offer_id,
        o.offered_at,
        o.booking_id,
        o.driver_id,
        o.route_distance_meters,
        o.offer_state,
        o.driver_read,
        b.booking_status,
        b.requested_at,
        d.driver_country,
        d.driver_rating
    from offers o
    left join bookings b on o.booking_id = b.booking_id
    left join drivers d on o.driver_id = d.driver_id
)

select * from final