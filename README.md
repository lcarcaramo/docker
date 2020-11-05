# Tags

> _Built from [`quay.io/ibmz/alpine:3.12`](https://quay.io/repository/ibmz/alpine?tab=info)_
-	[`18.06.3-ce`](https://github.com/lcarcaramo/docker/blob/master/s390x/18.06/Dockerfile) - [![Build Status](https://travis-ci.com/lcarcaramo/docker.svg?branch=master)](https://travis-ci.com/lcarcaramo/docker)
# What is Docker in Docker?

Although running Docker inside Docker is generally not recommended, there are some legitimate use cases, such as development of Docker itself.

*Docker is an open-source project that automates the deployment of applications inside software containers, by providing an additional layer of abstraction and automation of operating-system-level virtualization on Linux, Mac OS and Windows.*

> [wikipedia.org/wiki/Docker_(software)](https://en.wikipedia.org/wiki/Docker_%28software%29)

![logo](https://raw.githubusercontent.com/docker-library/docs/c350af05d3fac7b5c3f6327ac82fe4d990d8729c/docker/logo.png)

Before running Docker-in-Docker, be sure to read through [Jérôme Petazzoni's excellent blog post on the subject](https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/), where he outlines some of the pros and cons of doing so (and some nasty gotchas you might run into).

If you are still convinced that you need Docker-in-Docker and not just access to a container's host Docker server, then read on.

## TLS

**Warning:** in 18.09, this behavior is disabled by default (for compatibility). If you use `--network=host`, shared network namespaces (as in Kubernetes pods), or otherwise have network access to the container (including containers started within the `dind` instance via their gateway interface), this is a potential security issue (which can lead to access to the host system, for example). It is recommended to enable TLS by setting the variable to an appropriate value (`-e DOCKER_TLS_CERTDIR=/certs` or similar). In 19.03+, this behavior is enabled by default.

When enabled, the Docker daemon will be started with `--host=tcp://0.0.0.0:2376 --tlsverify ...` (and when disabled, the Docker daemon will be started with `--host=tcp://0.0.0.0:2375`).

Inside the directory specified by `DOCKER_TLS_CERTDIR`, the entrypoint scripts will create/use three directories:

-	`ca`: the certificate authority files (`cert.pem`, `key.pem`)
-	`server`: the `dockerd` (daemon) certificate files (`cert.pem`, `ca.pem`, `key.pem`)
-	`client`: the `docker` (client) certificate files (`cert.pem`, `ca.pem`, `key.pem`; suitable for `DOCKER_CERT_PATH`)

In order to make use of this functionality from a "client" container, at least the `client` subdirectory of the `$DOCKER_TLS_CERTDIR` directory needs to be shared (as illustrated in the following examples).

# docker:dind
*not available - requires privileged mode* <br />
Running docker:dind and using this variant as a docker daemon requires `--privileged` mode, which is currently **not enabled** on ZCX for security purposes.

# Run Image
**mount `var/run/docker.sock` with read-only mode**
```console
$ docker run --rm -v /var/run/docker.sock:/var/run/docker.sock:ro quay.io/ibmz/docker:18.06.3-ce version
Client:
 Version:           18.06.3-ce
 API version:       1.38
 Go version:        go1.10.4
 Git commit:        d7080c1
 Built:             Wed Feb 20 02:24:15 2019
 OS/Arch:           linux/s390x
 Experimental:      false

Server:
 Engine:
  Version:          19.03.6
  API version:      1.40 (minimum version 1.12)
  Go version:       go1.12.17
  Git commit:       369ce74a3c
  Built:            Wed Feb 19 01:06:16 2020
  OS/Arch:          linux/s390x
  Experimental:     false
 containerd:
  Version:          1.3.3-0ubuntu1~18.04.2
  GitCommit:
 runc:
  Version:          spec: 1.0.1-dev
  GitCommit:
 docker-init:
  Version:          0.18.0
```

# Where to Store Data

Let Docker manage the storage of your data [by writing to disk on the host system using its own internal volume management](https://docs.docker.com/engine/tutorials/dockervolumes/#adding-a-data-volume). This is the default and is easy and fairly transparent to the user. The downside is that the files may be hard to locate for tools and applications that run directly on the host system, i.e. outside containers.

The Docker documentation is a good starting point for understanding the different storage options and variations, and there are multiple blogs and forum postings that discuss and give advice in this area. 
<br />
<br />
It's **important to note** however, that bind mounts with write mode enabled are not presently available on ZCX. Please use docker volumes in their place:

1.	Create a docker volume

	```console
        $ docker volume create <your_volume>
	```

2.	Start your `docker` container like this:

	```console
	$ docker run -it --name some-docker -v <your_volume>:/var/lib/docker -v /var/run/docker.sock:/var/run/docker.sock:ro quay.io/ibmz/docker:18.06.3-ce
	```

The `-v <your_volume>:/var/lib/docker` part of the command mounts the docker volume you've created from underlying host system as `/var/lib/docker` inside the container, where Docker by default will write its data files.

# License

View [license information](https://github.com/docker/docker/blob/eb7b2ed6bbe3fbef588116d362ce595d6e35fc43/LICENSE) for the software contained in this image.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

Some additional license information which was able to be auto-detected might be found in [the `repo-info` repository's `docker/` directory](https://github.com/docker-library/repo-info/tree/master/repos/docker).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
