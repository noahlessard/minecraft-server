## Minecraft Server Setup

```bash
# Fill in your playit.gg secret key in .env, then update ops.json and whitelist.json
nano .env

# Create data directories (ensures correct permissions before first run)
# Don't run the mkdir as root, it needs to be user
mkdir -p mc-data/world mc-data/logs backups
nano mc-data/ops.json 

podman unshare chown -R 1000:1000 mc-data backups mc-data/ops.json

# Build images
podman-compose build

# Start everything
podman-compose up -d
```


## Manual Backup (outside of schedule)

```bash
podman-compose exec minecraft /server/backup.sh
```
