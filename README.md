# Minecraft Server — Podman Commands

## Directory Structure
```
mcserver/
├── compose.yml
├── .env                        ← put your playit secret key here
├── minecraft/
│   ├── Dockerfile.minecraft
│   ├── entrypoint.sh
│   ├── backup.sh
│   └── server.properties
└── playit/
    └── Dockerfile.playit
```

## First-Time Setup

```bash
# 1. Fill in your playit.gg secret key
echo "PLAYIT_SECRET_KEY=your_key_here" > .env

# 2. Create data directories (ensures correct permissions before first run)
mkdir -p mc-data/world mc-data/logs backups
podman unshare chown -R 1000:1000 mc-data backups

# 3. Build images
podman-compose build

# 4. Start everything
podman-compose up -d
```

## Daily Operations

```bash
# View live logs (both containers)
podman-compose logs -f

# View only minecraft logs
podman-compose logs -f minecraft

# Stop everything
podman-compose down

# Restart just minecraft (e.g. after config change)
podman-compose restart minecraft
```

## Updating (get latest Paper + Terralith)

```bash
podman-compose down
podman-compose build --no-cache
podman-compose up -d
```

## Manual Backup (outside of schedule)

```bash
podman-compose exec minecraft /server/backup.sh
```

## Check Backup Status

```bash
ls -lh backups/
```

## Open a Shell Inside the Minecraft Container

```bash
podman-compose exec minecraft bash
```

---

## Without podman-compose (raw podman)

If you prefer not to use podman-compose:

```bash
# Build images
podman build -t mc-minecraft -f minecraft/Dockerfile.minecraft ./minecraft
podman build -t mc-playit    -f playit/Dockerfile.playit       ./playit

# Create networks
podman network create mc-internal --internal
podman network create mc-external

# Run minecraft
podman run -d \
  --name minecraft \
  --network mc-internal \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  -v ./mc-data/world:/server/world:Z \
  -v ./mc-data/logs:/server/logs:Z \
  -v ./backups:/backups:Z \
  --restart unless-stopped \
  mc-minecraft

# Run playit
podman run -d \
  --name playit \
  --network mc-internal \
  --network mc-external \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --read-only \
  --tmpfs /tmp \
  -e SECRET_KEY=your_key_here \
  --restart unless-stopped \
  mc-playit
```

> Note: The `:Z` suffix on volume mounts is important on SELinux systems
> (Fedora, RHEL, etc.) — it relabels the volume so the container can access it.
> Remove it if you're on a non-SELinux system like Debian/Ubuntu.
