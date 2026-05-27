#!/bin/bash
set -e

# Install Terralith into the world's datapack folder on first run
DATAPACK_DIR="/server/world/datapacks"
mkdir -p "$DATAPACK_DIR"
for f in /server/datapack-staging/*.zip; do
    [ -f "$f" ] || continue
    fname=$(basename "$f")
    if [ ! -f "${DATAPACK_DIR}/${fname}" ]; then
        cp "$f" "$DATAPACK_DIR/"
        echo "[entrypoint] Installed datapack: $fname"
    fi
done

# Start backup scheduler in the background
(
  while true; do
    now=$(date +%s)
    midnight=$(date -d "tomorrow 00:00" +%s)
    sleep $(( midnight - now ))
    /server/backup.sh
  done
) &

# Hand off to PaperMC (exec replaces this shell, so signals pass through cleanly)
exec java \
    -Xms1G -Xmx2G \
    -XX:+UseG1GC \
    -XX:+ParallelRefProcEnabled \
    -XX:MaxGCPauseMillis=200 \
    -XX:+UnlockExperimentalVMOptions \
    -XX:+DisableExplicitGC \
    -jar server.jar --nogui
