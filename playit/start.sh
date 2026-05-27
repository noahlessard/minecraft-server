#!/bin/sh
mkdir -p /home/playit/.config/playit_gg
echo "secret_key = \"${SECRET_KEY}\"" > /home/playit/.config/playit_gg/playit.toml
exec playit