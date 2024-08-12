# UniFi Network Controller

## Useful Command

- `system-wrapper.sh restore-default`
- `set-inform http://<IP>:8080/inform`

## Self Hosting Snippet

```yaml
---
version: "2.1"
services:
  unifi-db:
    image: docker.io/mongo:6.0.6
    container_name: unifi-db
    networks:
      - default
    volumes:
      - ./init-mongo.js:/docker-entrypoint-initdb.d/init-mongo.js:ro
      - ./mongo_data:/data/db
    restart: unless-stopped
  unifi-network-application:
    image: rekcod.robotflow.ai/linuxserver/unifi-network-application:8.0.26-ls26
    container_name: unifi-network-application
    networks:
      default:
      lan:
        ipv4_address: <IP>
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - MONGO_USER=unifi
      - MONGO_PASS=unifi
      - MONGO_HOST=unifi-db
      - MONGO_PORT=27017
      - MONGO_DBNAME=unifi
      - MEM_LIMIT=1024 #optional
      - MEM_STARTUP=1024 #optional
      - MONGO_TLS= #optional
      - MONGO_AUTHSOURCE= #optional
    volumes:
      - ./unifi_data:/config
    restart: unless-stopped

networks:
  default:
    driver: bridge
    external: false
  lan:
    external: true
```

> This example use docker macvlan network for the `lan` network.
