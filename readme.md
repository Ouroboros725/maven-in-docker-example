1. Build an image with the Dockerfile.
  + e.g. `docker build --build-arg USE_PROXY=true --build-arg PROXY_HOST=http://proxy.ouroboros.com --build-arg PROXY_PORT=8080 --build-arg MAVEN_VERSION=3.3.9 --build-arg DOCKER_VERSION=1.11.2 --build-arg DOCKER_COMPOSE_VERSION=1.7.1 -t build-image .`
  + `--build-arg USE_PROXY=true` set whether to use proxy.
  + `--build-arg PROXY_HOST=http://proxy.ouroboros.com` set the proxy host.
  + `--build-arg PROXY_PORT=8080` set proxy port.
  + `--build-arg MAVEN_VERSION=3.3.9` set version of maven to install.
  + `--build-arg DOCKER_VERSION=1.11.2` set version of the docker to install.
  + `--build-arg DOCKER_COMPOSE_VERSION=1.7.1` set version of the docker-compose to install.
  + It installs docker, docker-compose, jdk, maven and git.
  + It adds settings.xml and build.sh to the image.

2. Run the build.sh script inside the docker container.
  + e.g. `docker run -v maven-repo:/root/.m2 -v /var/run/docker.sock:/var/run/docker.sock -it build-image`
  + `-v maven-repo:/root/.m2/` map the maven local repository inside the docker container to a volume.
  + `-v /var/run/docker.sock:/var/run/docker.sock` map the docker daemon inside the docker container to the docker daemon running on the host.
   (i.e. There is not docker daemon running inside the docker container. Only docker client is running inside the docker container.)
  + `build-image` is the docker image created in step 1.
  + The build.sh script is executed as entry point. It can take parameters.

