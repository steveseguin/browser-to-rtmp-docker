FROM ubuntu:18.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y pulseaudio xvfb curl unzip xdotool apt-utils
RUN apt-get install -y ffmpeg
RUN apt-get install -y chromium-browser
RUN apt-get --fix-broken install -y

COPY run.sh /
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
