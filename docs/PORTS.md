# Port reference

Defaults for **local JAR** / host networking. In **Docker**, host ports come from `.env` (`*_SERVICE_PORT`, `MYSQL_PORT`, etc.).

## Main entry points

| Service | Port | URL |
|---------|------|-----|
| UI dashboard | 8080 | http://localhost:8080 |
| API gateway | 18888 | http://localhost:18888 |
| Nacos | 8848 | http://localhost:8848/nacos |
| MySQL (compose) | 3307 | `localhost:3307` (see `.env`) |
| Redis | 6379 | localhost:6379 |

## Authentication & users

| Service | Port |
|---------|------|
| Auth | 12340 |
| User | 12342 |
| Verification code | 15678 |
| Contacts | 12347 |

## Booking & orders

| Service | Port |
|---------|------|
| Travel | 12346 |
| Travel2 | 16346 |
| Travel plan | 14322 |
| Preserve | 14568 |
| Preserve other | 14569 |
| Order | 12031 |
| Order other | 12032 |
| Cancel | 18885 |
| Rebook | 18886 |
| Wait order | 16804 |

## Payment

| Service | Port |
|---------|------|
| Payment | 19001 |
| Inside payment | 18673 |

## Train & route

| Service | Port |
|---------|------|
| Train | 14567 |
| Route | 11178 |
| Route plan | 14578 |
| Station | 12345 |
| Seat | 18898 |
| Config | 15679 |

## Food & delivery

| Service | Port |
|---------|------|
| Food | 18856 |
| Station food | 18855 |
| Train food | 19999 |
| Food delivery | 18957 |
| Delivery | 18808 |

## Non-Java & other

| Service | Port |
|---------|------|
| News (Go) | 12862 |
| Ticket office (Node) | 16108 |
| Voucher (Python) | 16101 |
| Avatar (Python) | 17001 |

## Admin

| Service | Port |
|---------|------|
| Admin basic info | 18767 |
| Admin order | 16112 |
| Admin route | 16113 |
| Admin travel | 16114 |
| Admin user | 16115 |

Check running listeners: `./scripts/status.sh` or `docker compose -f docker-compose.build.yml ps`.
