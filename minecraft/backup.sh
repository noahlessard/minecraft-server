#!/bin/bash
BACKUP_DIR=/backups
DATE=$(date +%Y-%m-%d_%H-%M-%S)

echo "[$DATE] Starting world backup..."
tar -czf "${BACKUP_DIR}/world-${DATE}.tar.gz" -C /server world
echo "[$DATE] Backup written: world-${DATE}.tar.gz"

# Keep only the 10 most recent backups
ls -t "${BACKUP_DIR}"/world-*.tar.gz | tail -n +11 | xargs -r rm -f
echo "[$DATE] Pruned old backups. Current count: $(ls "${BACKUP_DIR}"/world-*.tar.gz 2>/dev/null | wc -l)"
