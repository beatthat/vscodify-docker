# VSCODE_BASE_IMAGE
#
# The base image that will be used as 'FROM' in the Dockerfile
#
# you generally want to set the base image to a docker image 
# that you're now extending to have a developer image
# that launches your base image with vscode to edit the working copy
VSCODE_BASE_IMAGE?=ubuntu:xenial

# VSCODE_IMAGE
#
# The 'tag' of the image we will build and run
#
# Usually set build image to something related to your base image, 
# e.g. myuser/myrepo:vscode
VSCODE_IMAGE?=vscodify

# VSCODE_DOCKERFILE
#
# Path to this Dockerfile from the Makefile.
#
# They're distributed in the same directory,
# and probably easiest to just cd to that directory
# and there run:
#
#		make build
#
VSCODE_DOCKERFILE?=./Dockerfile

# VSCODE_CONTAINER_NAME
# 
# The name to use for the container started by docker run
VSCODE_CONTAINER_NAME?=vscodify

VSCODE_EXITED_CONTAINER_ID=$(shell docker ps --quiet --all --filter "name=${VSCODE_CONTAINER_NAME}" --filter "status=exited" 2> /dev/null)

# VSCODE_WORKING_COPY
# 
# The host-machine path to the root of the working copy 
# this vs-code-enabled docker image will be used to edit.
#
# When you call 'make run' VS Code will open
# with this directory in its workspace
VSCODE_WORKING_COPY=${shell pwd}

# VSCODE_WORKING_COPY_MOUNT
#
# Mountpoint inside the docker container 
# where the host-machine working copy will be mounted.
VSCODE_WORKING_COPY_MOUNT?=/docker_host

# Build the vscode-enable docker image
build:
	docker build \
		--rm \
		--build-arg BASE_IMAGE=${VSCODE_BASE_IMAGE} \
		--build-arg VSCODE_WORKING_COPY_DEFAULT=${VSCODE_WORKING_COPY_MOUNT} \
		--file ${VSCODE_DOCKERFILE} \
		--tag ${VSCODE_IMAGE} \
		.

# Most users are going to just close VS Code when they're done using it.
#
# This will leave a container with the name $VSCODE_CONTAINER_NAME
# in exited status, and that will block subsequent 'docker run'
# with the same container name.
#
# So look for an exited container with the default run name we use.
# If we find it, remove it.
rm-exited-container:
ifneq ("${VSCODE_EXITED_CONTAINER_ID}", "")
	@echo "found exited container with id ${VSCODE_EXITED_CONTAINER_ID} and removing..."
	docker rm ${VSCODE_EXITED_CONTAINER_ID}
endif

# Run the vscode-enabled docker image
run: rm-exited-container
	docker run \
	-dti \
	--runtime=nvidia \
	--net="host" \
	--ipc="host" \
	--name=${VSCODE_CONTAINER_NAME} \
	-h ${VSCODE_CONTAINER_NAME} \
	-e DISPLAY=${DISPLAY} \
	-e MYUID=${shell id -u} \
	-e MYGID=${shell id -g} \
	-e MYUSERNAME=${shell id -un} \
	-e SSH_AUTH_SOCK=${SSH_AUTH_SOCK} \
	-v /dev/shm:/dev/shm \
	-v ${shell dirname ${SSH_AUTH_SOCK}}:${shell dirname ${SSH_AUTH_SOCK}} \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-v ${HOME}:${HOME} \
	-v ${VSCODE_WORKING_COPY}:${VSCODE_WORKING_COPY_MOUNT} \
	-w ${VSCODE_WORKING_COPY_MOUNT} \
	${VSCODE_IMAGE} 
