# Maxine-env
NVIDIA Maxine - A playground for running the Audio Effects SDK.

1. https://blogs.nvidia.co.jp/2022/09/28/maxine-cloud-native/

2. https://developer.nvidia.com/maxine?ncid=so-yout-521880-vt50

3. https://docs.nvidia.com/deeplearning/maxine/audio-effects-sdk/index.html#

4. https://catalog.ngc.nvidia.com/orgs/nvidia/teams/maxine/resources/maxine_windows_audio_effects_sdk_ga

5. https://catalog.ngc.nvidia.com/orgs/nvidia/teams/maxine/resources/maxine_linux_video_effects_sdk_ga

## 1. Advance preparation

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
  model="${model}/${arch}/${effect}_${sample_rate}k_to_${output_sample_rate}k.trtpkg"
else
  model="${model}/${arch}/${effect}_${sample_rate}k_3072.trtpkg"
fi
```

## 2. Execution
```
./run_effect.sh -c t4_denoise48k_1_cfg.txt -g rtx3070
```

## 3. Noise-reduced WAV playback
```
aplay denoiser/16k/denoiser_16k_1.wav
```