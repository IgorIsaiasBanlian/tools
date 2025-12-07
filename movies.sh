#!/bin/bash
# Reproducir todos los videos en /roms2/movies/ (y subcarpetas) con MPV
# Maneja espacios y caracteres especiales en nombres de archivo.



set -euo pipefail

CARPETA="/roms2/movies"

# Extensiones admitidas (insensible a mayúsculas)
PATTERN='.*\.\(mp4\|mov\|avi\|mkv\|wmv\|flv\|webm\|m4v\)$'

# Construir una lista segura en un arreglo Bash usando NUL como separador
mapfile -d '' VIDEOS < <(find "$CARPETA" -type f -iregex "$PATTERN" -print0 | sort -z)

if (( ${#VIDEOS[@]} == 0 )); then
  echo "No se encontraron videos en $CARPETA."
  exit 1
fi

echo "Se encontraron ${#VIDEOS[@]} videos. Iniciando reproducción…"

# Reproducir (aleatorio, bucle infinito, pantalla completa)
#mpv --save-position-on-quit=yes --resume-playback --fs "${VIDEOS[@]}"
mpv --osd-status-msg="" --input-conf=<(echo 'm script-binding osc/visibility') --script=<(echo 'mp.add_key_binding(nil, "PLAY", function() mp.command("cycle pause") end))
mp.add_key_binding(nil, "PlayCD", function() mp.command("cycle pause") end)') \
--ao=pulse --osd-font='Century Schoolbook' --sub-color='#ffff01' --sub-shadow-offset=10 --sub-visibility=yes --sub-shadow-color='#0f0300' --sub-bold=yes --sub-font-size=60 --sub-pos=60 --save-position-on-quit=yes --resume-playback --fs --osd-level=2 --osd-color="#05fcba" --osd-duration=5000 --osd-font-size=40.000 --osd-italic=yes --osd-scale=1.300 --osd-shadow-color="#000000" --osd-shadow-offset=8.000 --player-operation-mode=cplayer --geometry=640x480 --autofit=640x480 --image-display-duration=inf --video-unscaled=yes --video-aspect=-1 --volume-max=100.000 --cache=no --demuxer-thread=no --hr-seek=no --vd-lavc-threads=1 --hwdec=no --really-quiet --untimed "${VIDEOS[@]}" --input-ipc-server=/tmp/mpvsocket
