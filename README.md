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
### Posts
* READ: 10 posts/day * 10M DAU / 86400 seconds/day = 1200 RPS
* WRITE: 1 post/week * 10M DAU / 7 days/week / 86400 seconds/day = 17 RPS

### Comments
* READ: 10 comments/day * 10M DAU / 86400 = 1200 RPS
* WRITE: 2 comments/week * 10M DAU / 7 days/week / 86400 seconds/day = 33 RPS

### Subscriptions
* WRITE: 1 time/day * 10M DAU / 86400 seconds/day = 116 RPS

### Likes
* WRITE: 5 posts/day * 10M DAU / 86400 seconds/day = 580 RPS

---

## Traffic
### Posts

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

### Comments

| Comment property | Size      | 
|------------------|-----------|
| postId           | 8 bytes   |
| userId           | 8 bytes   |
| description      | 255 bytes |
| timestamp        | 8 bytes   |

* READ: 1200 RPS * 279 B = 335 KB/s
* WRITE: 33 RPS * 279 B = 9 KB/s

### Subscriptions

| Subscription property | Size    | 
|-----------------------|---------|
| fromUserId            | 8 bytes |
| toUserId              | 8 bytes |

* WRITE: 116 RPS * 16 B = 1.9 KB/s

### Likes

| Like property | Size    | 
|---------------|---------|
| postId        | 8 bytes |
| userId        | 8 bytes |

* WRITE: 580 RPS * 16 B = 9.3 KB/s

---

## Connections
* 10M DAU * 0.1 = 1M

---

## Disks evaluation for 1 year

### Posts

#### Meta

* capacity = 5 KB/s * 86400 seconds/day * 365 days/year = 157680000 KB = 158 GB
* traffic_per_second = 335 KB/s + 5 KB/s = 340 KB/s
* iops = 1200 RPS + 17 RPS = 1217 RPS

HDD
* Disks_for_capacity = capacity / disk_capacity = 158 GB / 500 GB = 1 disk
* Disks_for_throughput = traffic_per_second / disk_throughput = 340 KB/s / 100 MB/s = 1 disk
* Disks_for_iops = iops / disk_iops = 1217 / 100 = 13 disks
* Disks = max(1, 1, 13) = 13 disks

SSD (SATA)
* Disks_for_capacity = capacity / disk_capacity = 158 GB / 500 GB = 1 disk
* Disks_for_throughput = traffic_per_second / disk_throughput = 340 KB/s / 500 MB/s = 1 disk 
* Disks_for_iops = iops / disk_iops = 1217 / 1000 = 2 disks
* Disks = max(1, 1, 2) = 2 disks

SSD (nVME)
* Disks_for_capacity = capacity / disk_capacity = 158 GB / 500 GB = 1 disk
* Disks_for_throughput = traffic_per_second / disk_throughput = 340 KB/s / 3 GB/s = 1 disk
* Disks_for_iops = iops / disk_iops = 1217 / 10k = 1 disk
* Disks = max(1, 1, 1) = 1 disk

_Decision: will take 2 SSD (SATA) disks by 500 GB_ 

#### Media

* capacity = 51 MB/s * 86400 seconds/day * 365 days/year = 1.6e9 MB = 1.6 PB
* traffic_per_second = 335 KB/s + 5 KB/s = 340 KB/s
* iops = 1200 RPS + 17 RPS = 1217 RPS

HDD
* Disks_for_capacity = capacity / disk_capacity = 1.6 PB / 32 TB = 60 disks
* Disks_for_throughput = traffic_per_second / disk_throughput = 340 KB/s / 100 MB/s = 1 disk
* Disks_for_iops = iops / disk_iops = 1217 / 100 = 13 disks
* Disks = max(60, 1, 13) = 60 disks

SSD (SATA)
* Disks_for_capacity = capacity / disk_capacity = 1.6 PB / 100 TB = 20 disks 
* Disks_for_throughput = traffic_per_second / disk_throughput = 340 KB/s / 500 MB/s = 1 disk
* Disks_for_iops = iops / disk_iops = 1217 / 1000 = 2 disks
* Disks = max(20, 1, 2) = 20 disks

SSD (nVME)
* Disks_for_capacity = capacity / disk_capacity = 1.6 PB / 30 TB = 60 disks
* Disks_for_throughput = traffic_per_second / disk_throughput = 340 KB/s / 3 GB/s = 1 disk
* Disks_for_iops = iops / disk_iops = 1217 / 10k = 1 disk
* Disks = max(60, 1, 1) = 60 disks

_Decision:
for 30% of data (hot data) will take 6 SSD (DATA) disks by 100 TB.
For 70% of data (cold data) will take 42 HDD by 32 TB_

### Comments

* capacity = 9 KB/s * 86400 seconds/day * 365 days/year = 2.9e8 KB = 290 GB
* traffic_per_second = 335 KB/s + 9 KB/s = 344 KB/s
* iops = 1200 RPS + 33 RPS = 1233 RPS

HDD
* Disks_for_capacity = capacity / disk_capacity = 290 GB / 500 GB = 1 disk
* Disks_for_throughput = traffic_per_second / disk_throughput = 344 KB/s / 100 MB/s = 1 disk
* Disks_for_iops = iops / disk_iops = 1233 / 100 = 13 disks
* Disks = max(1, 1, 13) = 13 disks

SSD (SATA)
* Disks_for_capacity = capacity / disk_capacity = 290 GB / 500 GB = 1 disk
* Disks_for_throughput = traffic_per_second / disk_throughput = 344 KB/s / 500 MB/s = 1 disk
* Disks_for_iops = iops / disk_iops = 1233 / 1000 = 2 disks
* Disks = max(1, 1, 2) = 2 disks

SSD (nVME)
* Disks_for_capacity = capacity / disk_capacity = 290 GB / 500 GB = 1 disk
* Disks_for_throughput = traffic_per_second / disk_throughput = 344 KB/s / 3 GB/s = 1 disk
* Disks_for_iops = iops / disk_iops = 1233 / 10k = 1 disk
* Disks = max(1, 1, 1) = 1 disk

_Decision: will take 2 SSD (SATA) disks by 500 GB_

### Subscriptions

* capacity = 1.9 KB/s * 86400 seconds/day * 365 days/year = 6e7 KB = 60 GB
* traffic_per_second = 1.9 KB/s
* iops = 116 RPS

HDD
* Disks_for_capacity = capacity / disk_capacity = 60 GB / 500 GB = 1 disk
* Disks_for_throughput = traffic_per_second / disk_throughput = 1.9 KB/s / 100 MB/s = 1 disk
* Disks_for_iops = iops / disk_iops = 116 / 100 = 2 disks
* Disks = max(1, 1, 2) = 2 disks

SSD (SATA)
* Disks_for_capacity = capacity / disk_capacity = 60 GB / 500 GB = 1 disk
* Disks_for_throughput = traffic_per_second / disk_throughput = 1.9 KB/s / 500 MB/s = 1 disk
* Disks_for_iops = iops / disk_iops = 116 / 1000 = 1 disk
* Disks = max(1, 1, 1) = 1 disk

SSD (nVME)
* Disks_for_capacity = capacity / disk_capacity = 60 GB / 500 GB = 1 disk
* Disks_for_throughput = traffic_per_second / disk_throughput = 1.9 KB/s / 3 GB/s = 1 disk
* Disks_for_iops = iops / disk_iops = 116 / 10k = 1 disk
* Disks = max(1, 1, 1) = 1 disk

_Decision: will take 1 SSD (SATA) disk with 500 GB_

### Likes

* capacity = 9.3 KB/s * 86400 seconds/day * 365 days/year = 2.9e8 KB = 290 GB
* traffic_per_second = 9.3 KB/s
* iops = 580 RPS

HDD
* Disks_for_capacity = capacity / disk_capacity = 290 GB / 500 GB = 1 disk
* Disks_for_throughput = traffic_per_second / disk_throughput = 9.3 KB/s / 100 MB/s = 1 disk
* Disks_for_iops = iops / disk_iops = 580 / 100 = 6 disks
* Disks = max(1, 1, 6) = 6 disks

SSD (SATA)
* Disks_for_capacity = capacity / disk_capacity = 290 GB / 500 GB = 1 disk
* Disks_for_throughput = traffic_per_second / disk_throughput = 9.3 KB/s / 500 MB/s = 1 disk
* Disks_for_iops = iops / disk_iops = 580 / 1000 = 1 disk
* Disks = max(1, 1, 1) = 1 disk

SSD (nVME)
* Disks_for_capacity = capacity / disk_capacity = 290 GB / 500 GB = 1 disk
* Disks_for_throughput = traffic_per_second / disk_throughput = 9.3 KB/s / 3 GB/s = 1 disk
* Disks_for_iops = iops / disk_iops = 580 / 10k = 1 disk
* Disks = max(1, 1, 1) = 1 disk

_Decision: will take 1 SSD (SATA) disk with 500 GB_
