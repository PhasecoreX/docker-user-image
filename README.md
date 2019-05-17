# User Images
Base images that step down from root into a runtime-defined non-privileged user

[![Donate to support my code](https://img.shields.io/badge/Paypal-Donate-blue.svg)](https://paypal.me/pcx)

This repository is used as the template for building many of my `user-[IMAGE]` images. Currently we have the following images set up with multi-arch support:

- [`alpine`](https://git.pcxserver.com/PhasecoreX/docker-user-alpine) [![Build Status](https://ci.pcxserver.com/api/badges/PhasecoreX/docker-user-alpine/status.svg)](https://ci.pcxserver.com/PhasecoreX/docker-user-alpine)
- [`debian`](https://git.pcxserver.com/PhasecoreX/docker-user-debian) [![Build Status](https://ci.pcxserver.com/api/badges/PhasecoreX/docker-user-debian/status.svg)](https://ci.pcxserver.com/PhasecoreX/docker-user-debian)
- [`python`](https://git.pcxserver.com/PhasecoreX/docker-user-python) [![Build Status](https://ci.pcxserver.com/api/badges/PhasecoreX/docker-user-python/status.svg)](https://ci.pcxserver.com/PhasecoreX/docker-user-python)
- [`ubuntu`](https://git.pcxserver.com/PhasecoreX/docker-user-ubuntu) [![Build Status](https://ci.pcxserver.com/api/badges/PhasecoreX/docker-user-ubuntu/status.svg)](https://ci.pcxserver.com/PhasecoreX/docker-user-ubuntu)

Just replace `[IMAGE]` in the below commands with any of the above image names.

## For Developers
Simply have your image use this image as it's base image:
```
FROM phasecorex/user-[IMAGE]
```
Whatever you set as CMD in your image will be run as the user specified in the environment variables at runtime.

### Directories
There are also three directories created for your programs use:
- `/app`: Useful to store your program, or other scripts
- `/config`: Useful to have your programs config files stored. The user can easily volume mount this directory and modify config values.
- `/data`: Useful for your program to store databases or other persistence data. Again, the user can easily volume mount this directory to save persistence.

These three directories will be chowned to the specified user at start, but not recursively. It is up to the user to make sure permissions are correct inside the volume mounted folders.

### Multi-Arch
Pulling the base image will automatically pull the correct architecture for your build environment. If you need a specific architecture for your image (if you're making a multi-arch image, for example), you can pull a specific tag with one of the following suffixes:

- `-amd64`
- `-arm32v5`
- `-arm32v6`
- `-arm32v7`
- `-arm64v8`

For example, `phasecorex/user-alpine:edge-arm32v7` will get the alpine edge image built for an arm device (Raspberry Pi). Additionally, the appropriate qemu static files have been included, so you do not need to include them if you're planning on building multi-arch images in an x64 build environment!

### Custom Entrypoints
This image uses an entrypoint script to do all of the setup at runtime. If your image utilizes an entrypoint script as well, you will need to prepend this images entrypoint ("user-entrypoint") to it:
```
ENTRYPOINT ["user-entrypoint", "your", "other", "commands"]
```
If you've modified the $PATH, or otherwise can't run user-entrypoint, you can use "/bin/user-entrypoint" instead.

## For Users
If you're a developer using this image, consider including this information in your images readme.

### UID/GID
Set the environment variable `PUID` as the user ID you want the process to run as.
You can also set the environment variable `PGID` to specify the group ID. It will default to the user ID.

For example:
```
docker run -it -e PUID=1000 phasecorex/user-[IMAGE]
docker run -it -e PUID=1000 -e PGID=1024 phasecorex/user-[IMAGE]
docker run -it -e PUID=0 phasecorex/user-[IMAGE]
```
If not supplied, the default `PUID` and `PGID` will be 1000.

If set manually to 0, the process will run as root.

### Timezone
You can also set a timezone that your process will run in. Simply define the `TZ` environment variable:
```
docker run -it -e TZ=America/Detroit -e PUID=1000 phasecorex/user-[IMAGE]
```
This helps with having correct times in process logs.

