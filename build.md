# Build luet packages for kairos

kairos uses github action to build packages and push it to quay.io/kairos/packages(amd64 version) or quay.io/kairos/packages-arm64 (arm64 version),
in case you wanna build it manually, e.g. testing a new added package locally, or create your own repo to serve it offline/privately, it can be done with this steps:

## build packages

To build all packages, go to the repo root dir, and issue commands like this (note, you need to run as root user, otherwise you will get some permission issues):

```shell
sudo luet build --all --tree packages
```

To build an individual package, e.g. k8s/k3s-openrc from amd64

```shell
sudo luet build --values=values/amd64.yaml k8s/k3s-openrc
```

for arm64 version, the additional args `--backend-args` are needed, e.g.

```shell
sudo luet --backend-args --load --backend-args --platform --backend-args linux/arm64 build --values=values/arm64.yaml  k8s/k3s-systemd
```

## Create repo

After packages are build, you may create your repo using luet command, e.g. to create a docker repo for hosting your packages,

```shell
luet create-repo --type=docker  --output=myorg.org/packages --push-images
```

After that, you need to push all popluated package into your registry, in this myorg.org

## Consuming the packages

When package is available in registry, it can be used via enabling Kairos add in /etc/luet/luet.yaml as the following:

```yaml
repositories:
  - name: "Kairos"
    type: "docker"
    enable: true
    urls:
    - "myorg.org/packages"
```
