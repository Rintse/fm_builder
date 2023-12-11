FROM ubuntu:20.04 AS build-stage
ARG DEBIAN_FRONTEND=noninteractive

# The amount of CPU cores to allocate to the container. Note that there is a
# pretty intensive build step, probably a good idea to change this. Easiest is
# to run with `--build-arg CPU_COUNT=$(getconf _NPROCESSORS_ONLN 2>/dev/null)`
ARG CPU_COUNT=1

# Choose which slippi version to build
# 1) Slippi r18"
# 2) Slippi r16"
# 3) Slippi r11"
# 4) Slippi r10"
ARG SLIPPI_VERSION=1

# A list of shared object files to copy over from the container. For most
# systems, the runtime deps are so out of date that you need older versions.
ARG MISSING_LIBS_LIST=missing_libs.txt

# Install dependencies
RUN apt update
RUN apt install -y \
    curl cmake pkg-config git libao-dev libasound2-dev libavcodec-dev \
    libavformat-dev libbluetooth-dev libenet-dev libgtk2.0-dev liblzo2-dev \
    libminiupnpc-dev libopenal-dev libpulse-dev libreadline-dev libsfml-dev \
    libsoil-dev libsoundtouch-dev libswscale-dev libusb-1.0-0-dev \
    libwxbase3.0-dev libwxgtk3.0-gtk3-dev libxext-dev libxrandr-dev \
    portaudio19-dev zlib1g-dev libudev-dev libevdev-dev libmbedtls-dev \
    libcurl4-openssl-dev libegl1-mesa-dev libpng-dev qtbase5-private-dev \
    libxxf86vm-dev x11proto-xinerama-dev

# Alias sudo such that scripts that contain it will run
RUN echo "#!/bin/bash\n\$@" > /usr/bin/sudo
RUN chmod +x /usr/bin/sudo

# Run the installer in a temporary folder
RUN mkdir fm_build_tmp
WORKDIR fm_build_tmp
# full echo path is needed to interpret -e as an agrument to echo
RUN /bin/echo -e "y\ny\nn\nn\n$SLIPPI_VERSION\n$CPU_COUNT\n" \
    | sh -c "$(curl -Ls https://github.com/project-slippi/Slippi-FM-installer/raw/master/setup)"

# Gather the runtime dep shared objects that are not on the host machine
# (specified in the MISSING_LIBS_LIST file argument)
RUN mkdir lib 
COPY $MISSING_LIBS_LIST .
RUN for lib in $(cat missing_libs.txt); \
    do cp $(ldconfig -p | grep "$lib" | cut -d' ' -f4) lib ; \
    done
RUN rm $MISSING_LIBS_LIST

# Copy the files we want to the host machine
# TODO: this also contains the Dockerfile etc. right now
FROM scratch AS export-stage
COPY --from=build-stage fm_build_tmp/ /

