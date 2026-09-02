with source as (

    select * from {{ source('freenow_raw', 'drivers') }}

),

drivers as (

    select
        id                                                                              as driver_id,
        country                                                                         as driver_country,
        cast(nullif(rating, 'null') as decimal(3,2))                                    as driver_rating, -- forcing decimals, fixing "null" issue
        cast(nullif(rating_count, 'null') as integer)                                   as driver_rating_count, -- forcing integer, fixing "null" issue
        case
            when try_cast(date_registration as bigint) is not null
                then cast(to_timestamp(cast(date_registration as bigint)) as timestamp)
            else cast(date_registration as timestamp)
        end                                                                                 as registered_at, -- handles mixed epoch/string date formats
        cast(receive_marketing as boolean)                                                  as receive_marketing  -- forcing boolean

    from source

)

select distinct * from drivers