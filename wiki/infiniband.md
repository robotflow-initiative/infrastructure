# Handful Command for Setting Up Infiniband

## Install MST tools

This is useful if using Mellanox NICs

```shell
apt update && apt install mstflint
```

## Get PCI port via lspci and set IB mode

```shell
lspci | grep Mel
mstconfig -d 05:00.00 set LINK_TYPE_P1=ETH LINK_TYPE_P2=ETH # or ETH IB VPI
```

## Load IB modules

```conf
# /etc/modules
ib_ipoib
ib_umad
```

```shell
modprobe ib_ipoib
modprobe ib_umad
```

## Confiugre an IB SSwitch

See this post [https://blog.xjn819.com/post/Upgrade-from-10Gbps-to-40Gbps-network.html](https://blog.xjn819.com/post/Upgrade-from-10Gbps-to-40Gbps-network.html)

## Install ib tools

```shell
apt install infiniband-diags
```

## Flash firmware

You can flash firmware via:

```shell
mstflint -d 86:00.00 -i fw-ConnectX3-rel-2_42_5000-MCX354A-FCB_A2-A5-FlexBoot-3.4.752.bin -allow_psid_change burn
```

where `86:00.00` is pcie port of nic, `-allow_psid_change` allow you to flash firmware from other OEM.

> [https://network.nvidia.com/support/firmware/firmware-downloads/](https://network.nvidia.com/support/firmware/firmware-downloads/)

## RDMA

```shell
sudo apt-get install rdma-core
sudo apt-get install libibverbs1 librdmacm1 libibmad5 libibumad3 librdmacm1 ibverbs-providers rdmacm-utils infiniband-diags libfabric1 ibverbs-utils
```

## qperf

qperf can test RDMA bandwidth

server side:

```shell
iperf -s -i 1 -f m
```

client:

```shell
iperf -c [server-ip] -i 1 -t 30 -f m 
```
