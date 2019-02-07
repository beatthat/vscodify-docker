# VSCodify Docker

Add a Visual Studio Code development environment to your docker base images.

## Why would you want to do this? 

My own motivation is for computer-vision related python projects, 
where I've often found that I can't get an environment working with just conda
when the environment requires Caffe, OpenCV, ffmpeg, etc.

Rather than start installing required software to my own machine, 
I generally prefer to do everything in a docker container.
The problem with that is, I then lack a modern development enviroment.
To address this, I use vscodify-docker to create a 'devel' tag for my 
docker images, and then code in VS Code running over X11 from the docker container.

## Getting started

The simplest integration is to add vscodify-docker to your project as a git submodule

```bash
# from the root of your working copy
git submodule add -b master https://github.com/beatthat/vscodify-docker.git
```

Copy the contents of vscodify-docker's `copy_to_your_project/Makefile` to a Makefile at the root of your own project, e.g.

```bash
# from the root of your working copy
cat vscodify-docker/copy_to_your_project/Makefile >> Makefile
```

Configure the `VSCODE_BASE_IMAGE` property of the Makefile to docker image[:tag] that you want to extend with a vscode-enabled tag, e.g.

```Makefile
# VSCODE_BASE_IMAGE
# 
# The base image to which Visual Studio Code support will be added.
#
# You generally do want to override this with your own base image.
VSCODE_BASE_IMAGE?=your-base-image-name[:and-tag]
```

Build the vscode-extended docker image. By default it will be tagged `${VSCODE_BASE_IMAGE}:vscode` but you can change the tag by changing the `VSCODIFY_DOCKER_IMAGE` property in your Makefile.

```bash
# from the root of your working copy
make vscode-build
```

Finally, you can run dockerized Visual Studio Code on your project with

```bash
# from the root of your working copy
make vscode-run
```

The above should start docker and open an X11 Visual Studio Code window on your desktop with the your host-machine/local working copy in the vscode workspace.

### Prerequisites

* **linux** (tested on ubuntu 18.04 but should work on any desktop linux dist)
* **docker**
* NOT yet supported on OSX or Windows (need to work out X11 or similar set up for each)

## Use a custom `.workingcopyrc` to configure the environment for your project

The vscodify-docker set up is meant to be as generic/language agnostic as possible, but you're frequently going to want to make changes to your enviroment. The default entrypoint script for vscodify-docker supports this by looking for a `.workingcopyrc` file in the root of your working copy, and sourcing that script if it exists.

Example: say your project is in python and your repo includes a submodule `MySubmodule` and when you run the vscode docker env, you want that submodule included in the `PYTHONPATH`. You could make this happen by adding the following `.workingcopyrc` to your project root:

```bash
# .workingcopyrc at the root of your project
PYTHONPATH=${VSCODIFY_WORKING_COPY}/MySubmodule:${PYTHONPATH}
```

### Use `sh -l` with `docker exec` to make sure your `.workingcopyrc` is sourced in the shell

If you've created a `.workingcopyrc` file for your project, you probably want it sourced for any shell you start with `docker exec` on a running instance of your dev container. To make this happen you need to use the `-l` argument with ssh when you run `docker exec`, e.g.

```
docker exec your_container_name:vscode -it \
    ssh -l -c 'your actual commands here in quotes'
```

The under-the-covers reason is that the `workingcopyrc` file was copied to `/etc/profile.d` at docker-run time, but by the rules of unix, scripts in that location only execute for 'login' shells. If down the road we find a way to get those environement variables sourced without `ssh -l`, we'll remove this extra requirement.

## Authors

* **Larry Kirschner** - [beatthat](https://github.com/beathat)

See also the list of [contributors](https://github.com/beatthat/vscodify-docker/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Based on [allamand/docker-vscode](https://github.com/allamand/docker-vscode)
