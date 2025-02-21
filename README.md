# UPS-DM

This is the code for [A Closed-Form Solution to Uncalibrated Photometric Stereo via Diffuse Maxima](https://www.cvg.unibe.ch/media/project/papadhimitri/CVPR2012/index.html), adapted for personal usage.

## Usage

First build the docker image, or pull from ghcr.io:

```bash
docker build -t ups-dm:latest .
# or
docker pull ghcr.io/yousiki/ups-dm:latest
docker tag ghcr.io/yousiki/ups-dm:latest ups-dm:latest
```

Then run the docker container:

```bash
docker run -it --rm \
    -v "$(pwd)/data:/workspace/data" \
    ups-dm:latest \
    octave Run_LDR_Method.m \
    data/octopus.mat \
    data/octopus_output.mat
```
