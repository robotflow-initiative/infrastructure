# Minio K8S Setup Guide

## Setup Direct PV

```shell
kubectl krew install directpv
kubectl directpv install
```

```shell
kubectl directpv info
```

```shell
kubectl directpv discover
```

This will create a `drives.yaml`

## Single-Node Multi-Drive

Assume we are depolying a 6 disk MinIO instance on a single node. The namespace is `minio-dev`.

```yml
# Deploys a new Namespace for the MinIO Pod
apiVersion: v1
kind: Namespace
metadata:
  name: minio-dev # Change this value if you want a different namespace name
  labels:
    name: minio-dev # Change this value to match metadata.name
```

Create PVC of type `directpv-min-io`, we are using 6 disks of 320GB each, so we are creating DirectPV claims of 280GiB.

> If you plan to not to use the entire disk, manuall create the PV.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: minio-pv-0
  namespace: minio-dev
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 280Gi
  storageClassName: directpv-min-io
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: minio-pv-1
  namespace: minio-dev
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 280Gi
  storageClassName: directpv-min-io
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: minio-pv-2
  namespace: minio-dev
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 280Gi
  storageClassName: directpv-min-io
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: minio-pv-3
  namespace: minio-dev
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 280Gi
  storageClassName: directpv-min-io
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: minio-pv-4
  namespace: minio-dev
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 280Gi
  storageClassName: directpv-min-io
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: minio-pv-5
  namespace: minio-dev
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 280Gi
  storageClassName: directpv-min-io
```

Service and Statefuleset are created as follows, `9000` is the API port and `9090` is the console port:

```yml
kind: Service
apiVersion: v1
metadata:
  name: minio
  namespace: minio-dev
  labels:
    app: minio
spec:
  selector:
    app: minio
  type: NodePort
  ports:
    - name: api
      port: 9000
      protocol: TCP
      targetPort: 9000
      nodePort: 39000
    - name: webui
      port: 9090
      protocol: TCP
      targetPort: 9090
      nodePort: 39090
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: minio
  namespace: minio-dev
  labels:
    app: minio
spec:
  serviceName: "minio"
  replicas: 1
  selector:
    matchLabels:
      app: minio
  template:
    metadata:
      labels:
        app: minio
        directpv.min.io/organization: minio
        directpv.min.io/app: minio-example
        directpv.min.io/tenant: tenant-1
    spec:
      containers:
      - name: minio
        image: rekcod.robotflow.ai/minio/minio
        env:
        - name: MINIO_ACCESS_KEY
          value: minio
        - name: MINIO_SECRET_KEY
          value: minio123
        volumeMounts:
        - name: data0
          mountPath: /data0
        - name: data1
          mountPath: /data1
        - name: data2
          mountPath: /data2
        - name: data3
          mountPath: /data3
        - name: data4
          mountPath: /data4
        - name: data5
          mountPath: /data5
        args:
        - "server"
        - "data0"
        - "data1"
        - "data2"
        - "data3"
        - "data4"
        - "data5"
        - "--console-address"
        - ":9090"
      volumes:
        - name: data0
          persistentVolumeClaim:
            claimName: minio-pv-0
        - name: data1
          persistentVolumeClaim:
            claimName: minio-pv-1
        - name: data2
          persistentVolumeClaim:
            claimName: minio-pv-2
        - name: data3
          persistentVolumeClaim:
            claimName: minio-pv-3
        - name: data4
          persistentVolumeClaim:
            claimName: minio-pv-4
        - name: data5
          persistentVolumeClaim:
            claimName: minio-pv-5
```
