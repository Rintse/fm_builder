# Slippi-FM builder

This repository contains a `Dockerfile` that will spit out the binary (and
possibly some runtime `.so` dependencies) for various Faster Melee versions.

Basically all it does is set up a container in which to run [this installer
script](https://github.com/project-slippi/Slippi-FM-installer) by
[Nikki](https://github.com/NikhilNarayana). This might be needed due to modern
operating systems possibly not meeting (easily) the build/runtime requirements.

I needed this when I wanted to practice doubles on a CPU again. Maybe someone
else finds it some day.

## Usage
Firstly, install `docker`. Then run:
```
docker build \
    --build-arg CPU_COUNT=$(getconf _NPROCESSORS_ONLN 2>/dev/null) \
    --output type=tar,dest=slippi.tar \
    .
```
After this finishes, you should have a tar file named `slippi.tar` on your
machine. Unpack this file somewhere, e.g.:
```
mkdir -p ~/.config/fm_slippi/
tar -xf slippi.tar -C ~/.config/fm_slippi/
```
Then you can run the executable (with the exported object files) in that
directory as follows:
```
LD_LIBRARY_PATH=~/.config/fm_slippi/lib/ ~/.config/fm_slippi/slippi-r18-netplay
```

In `missing_libs.txt` you can change what shared objects you want to copy over
from the container.

You can inspect `Dockerfile` to see the possible arguments.
