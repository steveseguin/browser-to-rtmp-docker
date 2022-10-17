# Webpage -> RTMP  Demo

This repository contains a Docker container that, when started, will join a selected website and broadcast the meeting's audio and video in high definition (1080p at 30fps) to an RTMP endpoint you specify.

## Prerequisites

You will need Docker and `make` installed on your system. As this container is running a Firefox browser instance and transcoding audio and video in real time, it is recommended to use a host system with at least 8GB RAM and 4 CPU cores, such as an m5.xlarge EC2 instance running Ubuntu Linux 18.04 LTS.
 
## Configuration

The input for the container is a file called `container.env`. You create this file by copying the `container.env.template` to `container.env` and filling in the following variables:
 
 
* `MEETING_URL`: Browser URL (without any spaces in it)
  * Example(If you want to record VDO.Ninja): `https://vdo.ninja/?room=ROOMID&scene`
 
* `RTMP_URL`: the URL of the RTMP endpoint,
  * Twitch example: `rtmp://live.twitch.tv/app/<stream key>`
  * YouTube Live example: `rtmp://a.rtmp.youtube.com/live2/<stream key>`

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

