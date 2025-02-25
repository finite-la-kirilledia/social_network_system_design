Table users {
    id serial [primary key]
    name string
}

Table posts {
    id serial [primary key]
    user_id bigint [not null, ref: > users.id]
    post_text string
    photos string[]
    geolocation_id bigint [not null, ref: > geolocations.id]
    created_at timestamp
}

Table comments {
    id serial [primary key]
    post_id bigint [not null, ref: > posts.id]
    user_id bigint [not null, ref: > users.id]
    created_at timestamp
}

Table subscriptions {
    from_user_id bigint [not null, ref: > users.id]
    to_user_id bigint [not null, ref: > users.id]
    created_at timestamp
    indexes {
        (from_user_id, to_user_id) [unique]
    }
}

Table likes {
    id serial [primary key]
    post_id bigint [not null, ref: > posts.id]
    user_id bigint [not null, ref: > users.id]
    created_at timestamp
    indexes {
        (post_id, user_id) [unique]
    }
}

Table geolocations {
    id serial [primary key]
    name string
    longitude decimal(9,6) [not null]
    latitude decimal(9,6) [not null]
}
