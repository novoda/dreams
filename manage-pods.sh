#!/bin/bash

if [ $1 = "--start" ]
then
	start=true
	stop=false
	apiKey=$2
	huggingFaceToken=$3
fi

if [ $1 = "--stop" ]
then
	start=false
	stop=true
	apiKey=$2
	huggingFaceToken=$3
fi

if [ $start = true ]
then
	curl --request POST \
	--header 'content-type: application/json' \
	--url 'https://api.runpod.io/graphql?api_key='$apiKey''  \
	--data '{"query": "mutation { podFindAndDeployOnDemand( input: { cloudType: ALL, gpuCount: 1, volumeInGb: 40, containerDiskInGb: 40, minVcpuCount: 2, minMemoryInGb: 15, gpuTypeId: \"NVIDIA RTX A4000\", name: \"RunPod PyTorch\", imageName: \"runpod/pytorch\", dockerArgs: \"bash -c \\\"wget -O - https://raw.githubusercontent.com/novoda/dreams/main/pod-start-command.sh | bash\\\"\", ports: \"8888/http\", volumeMountPath: \"/workspace\", env: [{ key: \"HUGGING_FACE\", value: \"'$huggingFaceToken'\" }] } ) { id imageName env machineId machine { podHostId } } }"}'
fi


if [ $stop = true ]
then
	id=$(curl --request POST \
	--header 'content-type: application/json' \
	--url 'https://api.runpod.io/graphql?api_key='$apiKey''  \
	--data '{"query": "query Pods { myself { pods { id } } }"}' | jq -r '.data.myself.pods[0].id')

    curl --request POST \
    --header 'content-type: application/json' \
    --url 'https://api.runpod.io/graphql?api_key=ZR0NG1K70SI1TSPMAQ6Y8ZHKBDYH2VMY0WH1LV5T' \
    --data '{"query": "mutation { podTerminate( input: { podId: \"'$id'\" } ) }"}'
fi
