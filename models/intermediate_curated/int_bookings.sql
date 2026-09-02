with bookings as (
    select * from {{ ref('stg_bookings') }}
),

accepted_offers as (
    select
        booking_id,
        offer_id,
        offered_at,
        driver_id,
        route_distance_meters
    from {{ ref('stg_offers') }}
    where offer_state = 'ACCEPTED'
),

drivers as (
    select * from {{ ref('stg_drivers') }}
),

financials as (
    select * from {{ ref('stg_order_financials') }}
),

final as (

    select
        b.booking_id,
        b.requested_at,
        b.booking_status,
        b.estimated_route_fare_eur,
        b.estimated_route_fare_eur > 1000 as is_fare_outlier, -- flags implausible fares
        ao.offer_id            as accepted_offer_id,
        ao.offered_at          as accepted_at,
        ao.route_distance_meters,
        coalesce(ao.driver_id, b.driver_id) as driver_id,-- if accepted offer driver exists, use that driver_id, else use the one from bookings
        d.driver_country,
        d.driver_rating,
        f.gmv,
        f.gmv > 1000 as is_gmv_outlier, -- flags implausible GMV values
        f.tip,
        f.commission,
        f.currency,
        f.payment_method
    from bookings b
    left join accepted_offers ao on b.booking_id = ao.booking_id
    left join drivers d on coalesce(ao.driver_id, b.driver_id) = d.driver_id
    left join financials f on b.booking_id = f.booking_id

)

select * from final