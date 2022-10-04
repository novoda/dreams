#!/bin/bash

operation=$1
apiKey=$2
huggingFaceToken=$3

## START ##
if [ $operation = "--start" ]
then
	## Start a pod with NVIDIA RTX A4000 GPU
	curl --request POST \
	--header 'content-type: application/json' \
	--url 'https://api.runpod.io/graphql?api_key='$apiKey''  \
	--data '{"query": "mutation { podFindAndDeployOnDemand( input: { cloudType: ALL, gpuCount: 1, volumeInGb: 5, containerDiskInGb: 5, minVcpuCount: 2, minMemoryInGb: 15, gpuTypeId: \"NVIDIA RTX A4000\", name: \"RunPod PyTorch\", imageName: \"runpod/pytorch\", dockerArgs: \"bash -c \\\"wget -O - https://raw.githubusercontent.com/novoda/dreams/main/pod-start-command.sh | bash\\\"\", ports: \"8888/http\", volumeMountPath: \"/workspace\", env: [{ key: \"HUGGING_FACE\", value: \"'$huggingFaceToken'\" }] } ) { id imageName env machineId machine { podHostId } } }"}'
fi

## STOP ##
if [ $operation = "--stop" ]
then
	## Finds running Pod
	id=$(curl --request POST \
	--header 'content-type: application/json' \
	--url 'https://api.runpod.io/graphql?api_key='$apiKey''  \
	--data '{"query": "query Pods { myself { pods { id } } }"}' | jq -r '.data.myself.pods[0].id')

	## Terminates running Pod
	curl --request POST \
	--header 'content-type: application/json' \
	--url 'https://api.runpod.io/graphql?api_key='$apiKey'' \
	--data '{"query": "mutation { podTerminate( input: { podId: \"'$id'\" } ) }"}'
fi
