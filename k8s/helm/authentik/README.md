# Authentik Installation Guide

Add the authentik repo

```shell
helm repo add authentik https://charts.goauthentik.io
helm repo update
```

Pull the Chart

```shell
helm pull authentik/authentik
```

Replace the `values.yaml` with current version, replace `FIXME` with actual secret

```shell
helm upgrade --install authentik . -n authentik
```
