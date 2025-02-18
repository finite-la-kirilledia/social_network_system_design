# Social Network - System Design

---

## Functional requirements
1) create post (description + photos + geolocation)
2) add comment to post
3) like post
4) subscribe to user
5) search popular geolocations
6) get posts from geolocation
7) get posts of user
8) get posts from subscribers (descending chronological order)

---

## Non-functional requirements
- 10M DAU
- CIS region
- Store data forever
- Seasonal activity: 40-50% increase in load during summer
- Availability 99,95%
- Average user activity
  - user creates 1 post/week (3 photos)
  - user views 10 posts/day
  - user likes 5 posts/day
  - user adds 2 comments/week
  - user views 10 comments/day
  - user subscribes 1 time/day
- Timings:
  - create post within 1 sec
  - add comment within 1 sec
  - load posts within 2 secs
  - find popular geolocations within 2 secs
- Limits:
  - max 10 posts/day
  - max 100 comments/day
  - max 100 subscriptions/day
  - max 1M subscribers & subscriptions

---

## RPS
#### Posts
* READ: 10 posts/day * 10M DAU / 86400 seconds/day = 1200 RPS
* WRITE: 1 post/week * 10M DAU / 7 days/week / 86400 seconds/day = 17 RPS

#### Comments
* READ: 10 comments/day * 10M DAU / 86400 = 1200 RPS
* WRITE: 2 comments/week * 10M DAU / 7 days/week / 86400 seconds/day = 33 RPS

#### Subscriptions
* WRITE: 1 time/day * 10M DAU / 86400 seconds/day = 116 RPS

#### Likes
* WRITE: 5 posts/day * 10M DAU / 86400 seconds/day = 580 RPS

---

## Traffic
#### Posts

| Post property | Size            | 
|---------------|-----------------|
| userId        | 8 bytes         |
| description   | 255 bytes       |
| image         | 3 photos * 1 MB |
| geolocation   | 8 bytes         |
| timestamp     | 8 bytes         |

| Meta                                               | Media           | 
|----------------------------------------------------|-----------------|
| userId + description + geo + timestamp = 279 bytes | 3 images = 3 MB |

* READ (Meta): 1200 RPS * 279 bytes = 335 KB/s
* WRITE (Meta): 17 RPS * 279 bytes = 5 KB/s


* READ (Media): 1200 RPS * 3 MB = 3600 MB/s
* WRITE (Media): 17 RPS * 3 MB = 51 MB/s

#### Comments

| Comment property | Size      | 
|------------------|-----------|
| postId           | 8 bytes   |
| userId           | 8 bytes   |
| description      | 255 bytes |
| timestamp        | 8 bytes   |

* READ: 1200 RPS * 279 B = 335 KB/s
* WRITE: 33 RPS * 279 B = 9 KB/s

#### Subscriptions

| Subscription property | Size    | 
|-----------------------|---------|
| fromUserId            | 8 bytes |
| toUserId              | 8 bytes |

* WRITE: 116 RPS * 16 B = 1.9 KB/s

#### Likes

| Like property | Size    | 
|---------------|---------|
| postId        | 8 bytes |
| userId        | 8 bytes |

* WRITE: 580 RPS * 16 B = 9.3 KB/s

---

## Connections
* 10M DAU * 0.1 = 1M
