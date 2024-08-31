# K8S documents

## Krew

[Krew](https://krew.sigs.k8s.io/) is the plugin manager for kubectl command-line tool.

Krew helps you:

discover kubectl plugins,
install them on your machine,
and keep the installed plugins up-to-date.
There are 269 kubectl plugins currently distributed on Krew.

Krew works across all major platforms, like macOS, Linux and Windows.

Install command:

```shell
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)
```

## DirectPV

```shell
kubectl krew install directpv
kubectl directpv install
```

```shell
kubectl directpv info
```

