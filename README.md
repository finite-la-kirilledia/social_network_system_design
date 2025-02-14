# Social Network - System Design

---

## Functional requirements
1) create post (description + photos + geolocation)
2) add comment to post (with rating)
3) subscribe to user
4) search popular geolocations
5) get posts from geolocation
6) get posts of user
7) get posts from subscribers (descending chronological order)

---

## Non-functional requirements
- 10M DAU
- CIS region
- Store data forever
- No seasonal activity
- Availability 99,95%
- Average user activity
  - user creates 1 post/week (3 photos)
  - user views 10 posts/day
  - user adds 2 comments/week
  - user views 10 comments/day

---

## RPS
#### Posts
* READ: 10 posts/day * 10M DAU / 86400 seconds/day = 1200 RPS
* WRITE: 1 post/week * 10M DAU / 7 days/week / 86400 seconds/day = 17 RPS

#### Comments
* READ: 10 comments/day * 10M DAU / 86400 = 1200 RPS
* WRITE: 2 comments/week * 10M DAU / 7 days/week / 86400 seconds/day = 33 RPS

---

## Traffic
#### Posts

| Post property | Size            | 
|---------------|-----------------|
| id            | 8 bytes         |
| description   | 255 bytes       |
| image         | 3 photos * 1 MB |
| geolocation   | 8 bytes         |

* READ: 1200 RPS * 3 MB = 3600 MB/s
* WRITE: 17 RPS * 3 MB = 51 MB/s

#### Comments

| Comment property | Size      | 
|------------------|-----------|
| id               | 8 bytes   |
| description      | 255 bytes |
| rating           | 1 byte    |

* READ: 1200 RPS * 300 B = 360k B/s = 3.6 MB/s
* WRITE: 33 RPS * 300 B = 10k B/s = 1 MB/s

---

## Connections
* 10M DAU * 0.1 = 1M
