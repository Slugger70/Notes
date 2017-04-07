# Restart Status page

### If it goes down

```
sudo su
service stop nginx
cd /home/ubuntu/cachet-docker
nohup docker-compose up &
```

