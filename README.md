# Maxine-env
NVIDIA Maxine - A playground for running the Audio Effects SDK.

1. https://blogs.nvidia.co.jp/2022/09/28/maxine-cloud-native/

2. https://developer.nvidia.com/maxine?ncid=so-yout-521880-vt50

3. https://docs.nvidia.com/deeplearning/maxine/audio-effects-sdk/index.html#

4. https://catalog.ngc.nvidia.com/orgs/nvidia/teams/maxine/resources/maxine_windows_audio_effects_sdk_ga

5. https://catalog.ngc.nvidia.com/orgs/nvidia/teams/maxine/resources/maxine_linux_audio_effects_sdk_ga

## 0. Environment
1. Ubuntu 22.04
2. Docker
3. NVIDIA RTX3070 (8GB)

## 1. Advance preparation

- A sequence for installing and starting additional packages
  ```bash
  IP_ADDRESS=$(hostname -I | cut -f1 -d' ')
  
  docker run --rm -it --gpus all \
  -v `pwd`:/workdir \
  -w /workdir \
  -e PULSE_SERVER=$IP_ADDRESS \
  nvcr.io/nvidia/tensorrt:22.11-py3
  
  nvcc --version
  
  nvcc: NVIDIA (R) Cuda compiler driver
  Copyright (c) 2005-2022 NVIDIA Corporation
  Built on Wed_Sep_21_10:33:58_PDT_2022
  Cuda compilation tools, release 11.8, V11.8.89
  Build cuda_11.8.r11.8/compiler.31833905_0
  
  dpkg -l | grep TensorRT
  
  ii  libnvinfer-bin        8.5.1-1+cuda11.8   amd64 TensorRT binaries
  ii  libnvinfer-dev        8.5.1-1+cuda11.8   amd64 TensorRT development libraries and headers
  ii  libnvinfer-plugin-dev 8.5.1-1+cuda11.8   amd64 TensorRT plugin libraries
  ii  libnvinfer-plugin8    8.5.1-1+cuda11.8   amd64 TensorRT plugin libraries
  ii  libnvinfer8           8.5.1-1+cuda11.8   amd64 TensorRT runtime libraries
  ii  libnvonnxparsers-dev  8.5.1-1+cuda11.8   amd64 TensorRT ONNX libraries
  ii  libnvonnxparsers8     8.5.1-1+cuda11.8   amd64 TensorRT ONNX libraries
  ii  libnvparsers-dev      8.5.1-1+cuda11.8   amd64 TensorRT parsers libraries
  ii  libnvparsers8         8.5.1-1+cuda11.8   amd64 TensorRT parsers libraries
  ii  tensorrt-dev          8.5.1.7-1+cuda11.8 amd64 Meta package for TensorRT development libraries
  
  apt-get update \
  && apt-get install -y \
      cuda-compat-11-8 \
      nano \
      alsa-base
  
  sed -i '$ a\export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/cuda-11.8/compat' ~/.bashrc
  source ~/.bashrc
  ```

or

- Additional packages installed
  ```bash
  IP_ADDRESS=$(hostname -I | cut -f1 -d' ')
  
  docker run --rm -it --gpus all \
  -v `pwd`:/workdir \
  -w /workdir \
  -e PULSE_SERVER=$IP_ADDRESS \
  pinto0309/maxine-env:cuda11.8-tensorrt8.5.1
  ```

https://developer.nvidia.com/cuda-gpus


```bash
cd samples/effects_demo

nano run_effect.sh
```
```sh
declare -A gpu_map=( ["a100"]="sm_80"
                     ["a30"]="sm_80"
                     ["a2"]="sm_86"
                     ["a10"]="sm_86"
                     ["a16"]="sm_86"
                     ["a40"]="sm_86"
                     ["rtx3070"]="sm_86" #<--- Add
                     ["t4"]="sm_75"
                     ["v100"]="sm_70"
                    )

model="../../models"
if [ "$effect" == "superres" ]; then
  if [ "$sample_rate" == "16" ]; then
    model="${model}/${arch}/${effect}_${sample_rate}k_to_${output_sample_rate}k_192.trtpkg"
  fi
  if [ "$sample_rate" == "8" ]; then
    if [ "$output_sample_rate" == "16" ]; then
      model="${model}/${arch}/${effect}_${sample_rate}k_to_${output_sample_rate}k_416.trtpkg"
    else
      model="${model}/${arch}/${effect}_${sample_rate}k_to_${output_sample_rate}k_128.trtpkg"
    fi
  fi
fi

if [ "$effect" == "aec" ]; then
  if [ "$sample_rate" == "16" ]; then
    model="${model}/${arch}/${effect}_${sample_rate}k_3072.trtpkg"
  else
    model="${model}/${arch}/${effect}_${sample_rate}k_1536.trtpkg"
  fi
fi

if [ "$effect" == "dereverb" ]; then
  model="${model}/${arch}/${effect}_${sample_rate}k_3072.trtpkg"
fi

if [ "$effect" == "dereverb_denoiser" ]; then
  if [ "$sample_rate" == "16" ]; then
    model="${model}/${arch}/${effect}_${sample_rate}k_3072.trtpkg"
  else
    model="${model}/${arch}/${effect}_${sample_rate}k_1024.trtpkg"
  fi
fi
```

## 2. Execution
### 2-1. Noise Removal/Background Noise Suppression Effect
https://docs.nvidia.com/deeplearning/maxine/audio-effects-sdk/index.html#background-noise-supp-effect
```bash
./run_effect.sh -g rtx3070 -s 16 -e denoiser
```
### 2-2. Acoustic Echo Cancellation Effect (BETA)
https://docs.nvidia.com/deeplearning/maxine/audio-effects-sdk/index.html#acoustic-echo-cancellation
```bash
./run_effect.sh -g rtx3070 -s 16 -e aec
./run_effect.sh -g rtx3070 -s 48 -e aec
```

## 3. Processed WAV playback
```
aplay denoiser/16k/denoiser_16k_1.wav
aplay aec/16k/aec_16k_1.wav
```
