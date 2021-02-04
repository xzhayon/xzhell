# xzhell
A set of utilities for the modern developer, to deal with everyday's virtualization.

## Installation
A remote script must be executed by hand:
```
$ sh -c "$(curl -fsSL https://raw.githubusercontent.com/xzhavilla/xzhell/master/tools/install.sh)"
```
From now on, `xzh up` can be used to get new updates.

## Tools
- [dock](#dock)
- [overdose](#overdose)

### dock
Easy-to-use synthesis of the [`docker run`](https://docs.docker.com/engine/reference/run/) command.
```
usage: dock [OPTIONS] IMAGE [COMMAND [ARGS]]

options:
  -C                              Do not remove the image
  -n                              Show commands without executing them
  -v [SOURCE:]TARGET[:OPTIONS]    Bind mount a volume (can be used multiple times)
```
`dock` can be used both with image tags...
```
$ dock alpine
Unable to find image 'alpine:latest' locally
latest: Pulling from library/alpine
4c0d98bf9879: Pull complete
Digest: sha256:08d6ca16c60fe7490c03d10dc339d9fd8ea67c6466dea8d558526b1330a85930
Status: Downloaded newer image for alpine:latest
/ #
```
...and with local builds...
```
$ ls docker
Dockerfile ...
$ dock docker
[+] Building...
/ #
```
When invoked without a command (and its args) it runs an interactive shell, but it can also be used to execute a command inside the container:
```
$ dock alpine uname -a
Unable to find image 'alpine:latest' locally
latest: Pulling from library/alpine
4c0d98bf9879: Pull complete
Digest: sha256:08d6ca16c60fe7490c03d10dc339d9fd8ea67c6466dea8d558526b1330a85930
Status: Downloaded newer image for alpine:latest
Linux ebec4767628b 4.19.121-linuxkit #1 SMP Tue Dec 1 17:50:32 UTC 2020 x86_64 Linux
Untagged: alpine:latest
Untagged: alpine@sha256:08d6ca16c60fe7490c03d10dc339d9fd8ea67c6466dea8d558526b1330a85930
Deleted: sha256:e50c909a8df2b7c8b92a6e8730e210ebe98e5082871e66edd8ef4d90838cbd25
```

### overdose
As the name suggests, this is [`docker-compose`](https://docs.docker.com/compose/reference/) on steroids (<b>over Do</b><i>cker Compo</i><b>se</b>). The tool is also available as `uberdose`, for those preferring a Kubernetes-like vibe (as a bonus point, "über" is the German word for "over").  
It proxies `docker-compose` commands, offering some handy addition and a bit of help with configuring the execution path.
```
usage: overdose [OPTIONS] COMMAND [ARGS]

options:
  -D DOCKERDIR            Home to docker-compose.yaml [working directory]
  -K K8SPOD               Optional Kubernetes pod to interact with [none]
  -n                      Show commands without executing them
  -p [NAMESPACE:]PLUGIN   Map commands in file PLUGIN to NAMESPACE (can be used multiple times)

commands:
  help                                            List Docker Compose commands
  shell|sh [-u USER] CONTAINER                    Log into a running container
                                                  -u Username or UID
  exec|x [-d] [-u USER] CONTAINER COMMAND [ARGS]  Execute a command inside a container
                                                  -d Run command in the background
                                                  -u Username or UID
  services                                        List services
```
The tool is extremely helpful to access virtual environments from any path.
```
$ ls $appDir
docker-compose.yaml ...
$ alias app='overdose -D$appDir'
$ cd /
$ app up -d --build
...
$ app sh -uroot $container
```

#### Plugins
`overdose` can be extended via plugins (_doses_). Apart from those shipped with the tool (`dose/node`, `dose/symfony`), _doses_ can be written to fulfill any kind of task.
```
$ alias app='overdose -D$appDir -pdose/node -Nweb -papp:$appDir/dose.sh'
$ app
usage: overdose [OPTIONS] COMMAND [ARGS]

options:
  -D DOCKERDIR            Home to docker-compose.yaml [$appDir]
  -K K8SPOD               Optional Kubernetes pod to interact with [none]
  -n                      Show commands without executing them
  -p [NAMESPACE:]PLUGIN   Map commands in file PLUGIN to NAMESPACE (can be used multiple times)
  -N CONTAINER            Docker container running Node [web]

commands:
  help                                                    List Docker Compose commands
  services                                                List services
  shell|sh [-u USER] [CONTAINER]                          Log into a container [Node's]
                                                          -u Username or UID
  exec|x [-d] [-c CONTAINER] [-u USER] COMMAND [ARGS]     Execute a command inside a container [Node's]
                                                          -c Choose a different container
                                                          -d Run command in the background
                                                          -u Username or UID
  npm [COMMAND [ARGS]]                                    Run NPM into Node container
  yarn [COMMAND [ARGS]]                                   Run Yarn into Node container
  app:fixtures                                            Load database fixtures
  app:...
$ app npm update
...
$ app app:fixtures
```

#### Kubernetes (experimental)
Most commands can be run on a Kubernetes pod specifying (at least) part of its name via the `-K` option. If the name is ambiguous, `overdose` will show a list of choices.
```
$ overdose -Kapp sh $container
Searching for pod "app"... 

overdose: too many pods: app-staging app-test
$ overdose -Kapp-t sh $container
Searching for pod "app-t"... 
Searching for pod "app-t": app-test
$ uberdose -Kapp-t x $container uname -a
Searching for pod "app-t"... 
Searching for pod "app-t": app-test
Linux app-test 4.19.121-linuxkit #1 SMP Tue Dec 1 17:50:32 UTC 2020 x86_64 Linux
/ $
```
