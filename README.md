# Webpage -> RTMP  Demo

This repository contains a Docker container that, when started, will join a selected website and broadcast the meeting's audio and video in high definition (1080p at 30fps) to an RTMP endpoint you specify.

Chromium (or Chrome), along with FFmpeg is used to achieve this, and it is supported without a display connected.  Audio sync issues do not seem to be an issue so long as the CPU is not being overloaded, so the default is not to apply audio audio sync compensation

## Prerequisites

You will need Docker and `make` installed on your system. As this container is running a Chromium (or Chrome) browser instance and transcoding audio and video in real time, it is recommended to use a host system with at least 4GB RAM and 8 CPU cores, such as an c5.2xlarge EC2 instance running Ubuntu Linux 18.04 LTS (or newer).

While it might be possible to get away with just a 4-vCPU server for encoding and broadcasting a simple website without audio or video-decoding, it's not recommended if trying to transcode a video mix at 1080p. Common problems if the CPU is not sufficient include audio and video not staying in sync, low frame rates, and other issues with stability.

I've successfully tested this Docker on an Orange Pi 5 small embedded computer, which is an 8-core ARM processor, with total CPU usage being just 25% when playing back a 720p30 video using VDO.Ninja and also encoding an 720p30 RTMP x264 output stream based on that browser output. I could in theory then load this setup with the VDO.Ninja Mixer app (vdo.ninja/mixer), with several inbound webRTC video streams mixed together, and still avoid running into sync issues.

## Configuration

The input for the container is a file called `container.env`. You create this file by copying the `container.env.template` to `container.env` and filling in the following variables:
 
* `MEETING_URL`: Browser URL (without any spaces in it)
  * Example(If you want to record a VDO.Ninja room): `https://vdo.ninja/?room=ROOMID&scene`
 
* `RTMP_URL`: the URL of the RTMP endpoint,
  * Twitch example: `rtmp://live.twitch.tv/app/<stream key>`
  * YouTube Live example: `rtmp://a.rtmp.youtube.com/live2/<stream key>`
 
* You may wish to also change the ffmpeg sync value from 562 to 2562, or some other value as needed, to dial in the audio/video sync. This may vary based on your system and configuration. 

## Running

To build the Docker image, run:
 
```
$ make
```
 
Once you have configured the `container.env` file, run the container:
 
```
$ make run
```
 
The container will start up and load the given website and then start streaming H.264/AAC in FLV format to the given RTMP endpoint.

When your broadcast has finished, stop the stream by killing the container:

```
$ docker kill bcast
```

If you launched an EC2 instance to host the Docker container, you may also want to stop the instance to avoid incurring cost.

## Support

I offer limited technical support on Discord at https://discord.vdo.ninja.  You can just make a support ticket in the #vdo-ninja-supprot channel there, and I'll help as I can.

