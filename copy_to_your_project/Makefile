
# VSCODE_BASE_IMAGE
# 
# The base image to which Visual Studio Code support will be added.
#
# You generally do want to override this with your own base image.
VSCODE_BASE_IMAGE?=ubuntu:xenial

# VSCODE_IMAGE
#
# The docker image name we will build and run as a Visual Studio Code extension
# of your base image.
#
# The default name will be ${VSCODE_BASE_IMAGE_MINUS_TAG}:vscode
VSCODE_IMAGE?=$(shell tmp='$(VSCODE_BASE_IMAGE)'; echo "$${tmp%%:*}:vscode")

# VSCODE_RUN_NAME
# 
# Name assigned to vscode docker container at run time.
#
# Handy to assign a specific name to  make it easier 
# to have additional rules to, say , open a shell on the container
VSCODE_RUN_NAME?=$(shell basename `pwd`)

# WORKING COPY
#
# The host-machine path to the root of your working copy.
#
# Will be the main directory opened in the Visual Studio Code
# workspace when you run vscode, e.g. 
#
#	make vscode-run
#
VSCODE_WORKING_COPY?=${shell pwd}

# VSCODE_DOCKER_DIR
#
# Path from your repo root to vscodify-docker root.
#
# If you've included vscodify-docker as a git submodule
# then this should be simply ./vscodify-docker
VSCODE_DOCKER_DIR?=./vscodify-docker

# vscode-build
#
# Build the vscode-tagged extension of your base image.
# 
# Requires that you have set variable VSCODE_BASE_IMAGE
vscode-build:
	cd ${VSCODE_DOCKER_DIR} && \
		make \
			VSCODE_IMAGE=${VSCODE_IMAGE} \
			VSCODE_BASE_IMAGE=${VSCODE_BASE_IMAGE} \
		build


# vscode-run
#
# Open a Visual Studio Code session of you project.
# 
# Runs the vscode-tagged docker image, which should
# open an X11 Visual Studio Code window from docker
# onto your host desktop, with your workingcopy
# open in the vs-code workspace.
vscode-run:
	cd ${VSCODE_DOCKER_DIR} && \
		make \
			VSCODE_IMAGE=${VSCODE_IMAGE} \
			VSCODE_RUN_NAME=${VSCODE_RUN_NAME} \
			VSCODE_WORKING_COPY=${VSCODE_WORKING_COPY} \
		run