#!/bin/bash

echo "run.sh starting"

BROWSER_URL=${WEBSITE_URL}
SCREEN_WIDTH=1280
SCREEN_HEIGHT=720
SCREEN_RESOLUTION=${SCREEN_WIDTH}x${SCREEN_HEIGHT}
COLOR_DEPTH=24
VIDEO_BITRATE=6000
VIDEO_FRAMERATE=30
VIDEO_GOP=$((VIDEO_FRAMERATE * 2))
AUDIO_BITRATE=160k
AUDIO_SAMPLERATE=44100
AUDIO_CHANNELS=2

echo "Setting up Xvfb"

pulseaudio -D --exit-idle-time=-1
pacmd load-module module-virtual-sink sink_name=v1  # Load a virtual sink as `v1`
pacmd set-default-sink v1  # Set the `v1` as the default sink device
pacmd set-default-source v1.monitor  # Set the monitor of the v1 sink to be the default source

Xvfb :2 -ac -screen 0 ${SCREEN_RESOLUTION}x${COLOR_DEPTH} > /dev/null 2>&1 &
sleep 2

if command -v google-chrome-stable &>/dev/null; then
    DISPLAY=:2 google-chrome-stable --kiosk --autoplay-policy=no-user-gesture-required --window-size=${SCREEN_WIDTH},${SCREEN_HEIGHT} --window-position=0,0 --no-sandbox "${BROWSER_URL}" & sleep 5
    echo "CHROME STABLE STARTED"
elif command -v chromium &>/dev/null; then
    DISPLAY=:2 chromium --kiosk --autoplay-policy=no-user-gesture-required --window-size=${SCREEN_WIDTH},${SCREEN_HEIGHT} --window-position=0,0 --no-sandbox "${BROWSER_URL}" & sleep 5
    echo "CHROMIUM STARTED"
elif command -v chromium-browser &>/dev/null; then
    DISPLAY=:2 chromium-browser --kiosk --autoplay-policy=no-user-gesture-required --window-size=${SCREEN_WIDTH},${SCREEN_HEIGHT} --window-position=0,0 --no-sandbox "${BROWSER_URL}" & sleep 5
    echo "CHROMIUM BROWSER STARTED"
else
    echo "Neither Google Chrome nor Chromium found."
    exit 1
fi

echo "moving mouse"
xdotool mousemove 1 1 click 1  # Move mouse out of the way so it doesn't trigger the "pause" overlay on the video tile

echo "starting ffmpeg"
ffmpeg \
  -hide_banner \
  -s ${SCREEN_RESOLUTION} \
  -r ${VIDEO_FRAMERATE} \
  -draw_mouse 0 \
  -f x11grab -i :2 \
  -f pulse -i default \
  -ac ${AUDIO_CHANNELS} \
  -c:v libx264 -pix_fmt yuv420p -profile:v main -preset veryfast  -minrate ${VIDEO_BITRATE} -maxrate ${VIDEO_BITRATE} -g ${VIDEO_GOP} \
  -filter_complex "aresample=async=1000:min_hard_comp=0.100000:first_pts=0,adelay=delays=0|0" \
  -c:a aac -b:a ${AUDIO_BITRATE} -ac ${AUDIO_CHANNELS} -ar ${AUDIO_SAMPLERATE} \
  -f flv ${RTMP_URL}

echo "exiting"
