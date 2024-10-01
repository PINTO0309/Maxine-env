FROM nvcr.io/nvidia/tensorrt:22.11-py3

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
        cuda-compat-11-8 \
        nano \
        alsa-base \
    && && sed -i 's/# set linenumbers/set linenumbers/g' /etc/nanorc \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i '$ a\export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/cuda-11.8/compat' ~/.bashrc
