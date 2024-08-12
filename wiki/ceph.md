# Ceph Snippets

## Install

```shell
wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -
echo deb https://download.ceph.com/debian-quincy/ bullseye main | sudo tee /etc/apt/sources.list.d/ceph.list
```

## Knowledges

- First, remove the cache pool, then change its pg_num.
- Using disk classes can cause the pg autoscaler to fail.
- Older Ceph clients cannot mount new Ceph storage.
- Unmount all clients before removing CephFS.

## OSD

###  Remove OSD from Ceph

```shell
ceph osd out osd.2 # mark osd as out
ceph -w
ceph osd crush remove 2 # remove osd from crush map
```

### Destroy Ceph Initialized LVMs

First

```shell
vgs | grep ceph | awk '{print $1}' | xargs vgremove -y
```

Now remove disks with `pvremove`

```shell
cat disks.txt | pvremove
```

## Crush Ruls

### Create Replicated Rules

```shell
ceph osd crush rule create-replicated replicated_rule_osd default osd
```

Create other replicated rules accroding to device type:

```shell
ceph osd crush rule create-replicated replicated_rule_ssd_osd default osd ssd
ceph osd crush rule create-replicated replicated_rule_hdd_osd default osd hdd
ceph osd crush rule create-replicated replicated_rule_nvme_osd default osd nvme
ceph osd crush rule create-replicated replicated_rule_optane_osd default osd optane
```

### Create Erasure Rules

```shell
ceph osd erasure-code-profile set erasure-9-3-osd k=9 m=3 crush-device-class=hdd crush-failure-domain=osd
ceph osd erasure-code-profile set erasure-9-3-hdd-osd k=9 m=3 crush-device-class=hdd crush-failure-domain=osd
ceph osd erasure-code-profile set erasure-9-3-ssd-osd k=9 m=3 crush-device-class=ssd crush-failure-domain=osd
ceph osd erasure-code-profile set erasure-3-1-ssd-osd k=3 m=1 crush-device-class=ssd crush-failure-domain=osd

ceph osd erasure-code-profile set erasure-8-2-osd k=8 m=2 crush-device-class=hdd crush-failure-domain=osd
ceph osd erasure-code-profile set erasure-8-2-hdd-osd k=8 m=2 crush-device-class=hdd crush-failure-domain=osd
ceph osd erasure-code-profile set erasure-8-2-ssd-osd k=8 m=2 crush-device-class=ssd crush-failure-domain=osd

ceph osd erasure-code-profile set erasure-4-2-osd k=4 m=2 crush-failure-domain=osd
ceph osd erasure-code-profile set erasure-4-2-hdd-osd k=4 m=2 crush-device-class=hdd crush-failure-domain=osd
ceph osd erasure-code-profile set erasure-4-2-ssd-osd k=4 m=2 crush-device-class=ssd crush-failure-domain=osd
```

### Edit Erasure Rules

```shell
ceph osd erasure-code-profile set test-ec2 crush-device-class=ssd crush-failure-domain=host
crush-root=default jerasure-per-chunk-alignment=false k=2 m=1 plugin=jerasure
```

### Set Rule for a Poll

```shell
ceph osd pool set [pool-name] crush_rule [rule-name]
```

> [https://stackoverflow.com/questions/63456581/1-pg-undersized-health-warn-in-rook-ceph-on-single-node-clusterminikube](https://stackoverflow.com/questions/63456581/1-pg-undersized-health-warn-in-rook-ceph-on-single-node-clusterminikube)

### Customize OSD class

```shell
ceph osd crush class create optane
ceph osd crush rm-device-class osd.2
ceph osd crush set-device-class optane osd.2
```

## Pool

### Create Replicated Pool

```shell
ceph osd pool create public-metadata replicated replicated_rule_ssd_osd
```

### Create Erasure Pool

```shell
ceph osd pool create public-data erasure erasure-9-3-osd
```

## EC OVERWRITES

A erasure pool must allow ec_overwrites before being used in cephfs

```shell
ceph osd pool set my_ec_pool allow_ec_overwrites true
```

## Cache Rules

For large cache drive (ssd) and small memory:

```conf
hit_set_count = 1
hit_set_period = 3600
hit_set_fpp = 0.05
min_write_recency_for_promote = 0
min_read_recency_for_promote = 0
```

For small cache drive and large memory:

```conf
hit_set_count = 12
hit_set_period = 14400
hit_set_fpp = 0.01
min_write_recency_for_promote = 2
min_read_recency_for_promote = 2
```

## CephFS

A ceph fs need two pools, one for metadata(replicated) and one for data(could be erasure)

### Create a CephFS

```shell
ceph osd pool create public-data erasure erasure-4-2-hdd-osd
ceph osd pool create public-metadata replicated replicated_rule_ssd_osd
ceph osd pool set public-data allow_ec_overwrites true
ceph fs new public public-metadata public-data --force
ceph osd pool set public-data pg_num 32
```

### Add cache tier to a CephFS

```shell
ceph osd pool create public-cache replicated replicated_rule_ssd_osd
ceph osd tier add public-data public-cache
ceph osd tier cache-mode public-cache writeback
ceph osd tier set-overlay public-data public-cache
ceph osd pool set public-cache hit_set_type bloom
ceph osd pool set public-cache target_max_bytes 2199023255552
ceph osd pool set public-cache cache_target_full_ratio 0.6
ceph osd pool set public-cache hit_set_count 12
ceph osd pool set public-cache hit_set_period 14400
ceph osd pool set public-cache hit_set_fpp 0.01
ceph osd pool set public-cache min_write_recency_for_promote 3
ceph osd pool set public-cache min_read_recency_for_promote 3
```

### Remove cache tier from a CephFS

```shell
ceph osd tier cache-mode public-cache readproxy
rados -p public-cache cache-flush-evict-all
ceph osd tier cache-mode public-cache none
ceph osd tier remove-overlay public-data
ceph osd tier remove public-data public-cache
ceph osd pool delete public-cache public-cache --yes-i-really-really-mean-it
```

### Multiple Ceph fs

To run multiple cephfs in one cluster, create more MDS

```shell
pveceph mds create --name <name>
```

### Mount CephFS

User Space:

```shell
mount -t ceph client.robotflow@8835849f-db7f-44a0-94ac-f27108bc47a5.public=/ /mnt/public.ceph -o mon_addr=100.99.96.250:6789,secret=xxxxxxxxxxxxxxxxxx
```

Kernel Space

```shell
mount -t ceph :/ /mnt/public.ceph -o name=robotflow,fs=public,mon_addr=100.99.96.250:6789,secret=xxxxxxxxxxxxxxxxxx
```

`/etc/fstab`:

```shell
100.99.96.250:6789:/     /mnt/public.ceph    ceph    name=robotflow,fs=public,mon_addr=100.99.96.250:6789,secret=xxxxxxxxxxxxxxxxxx,noatime,_netdev    0       2
```

### Snapshot FS

Enable

```shell
ceph mgr module enable snap_schedule
```

Add schedule

```shell
ceph fs snap-schedule add / 3h '2023-05-22T02:00:00' homes
```

Start schedule

```shell
ceph fs snap-schedule activate /
```

Set Retention

```shell
ceph fs snap-schedule retention add / - 0h3d4w homes
```

Check Status

```shell
ceph fs snap-schedule status / - homes
```

## RBD

Create RBD pool (must be replicated pool)

```shell
ceph osd pool create rbd replicated replicated_rule_ssd_osd
```

Load rbd module:

```shell
modprobe rbd
```

### RBD usage

Create Image

```shell
rbd create datasets --size=192T --pool public-metadata --data-pool public-data
```

Remove Image

```shell
rbd rm --pool public-metadata --image datasets
```

Client Map Image to Block Device

```shell
sudo rbd -n client.robotflow map --image datasets --pool public-metadata
```

Client Eject Image
```shell
sudo rbd unmap -n client.robotflow /dev/rbd0
```

## Authenticate

```shell
ceph fs authorize public client.robotflow / *
ceph auth get client.robotflow
```

You can modify the user's capabilities

```shell
ceph auth caps client.robotflow mon 'allow * fsname=public' mds 'allow * fsname=public' osd 'allow * tag cephfs data=public'
```

## PVE

### Ceph dashboard

```shell
apt-get install ceph-mgr-dashboard
ceph mgr module enable dashboard
echo "xxx.1234" > pass.txt
ceph dashboard ac-user-create admin -i pass.txt administrator
```

## Rados Gateway

Enable rados gateway access

```shell
ceph-authtool --create-keyring /etc/ceph/ceph.client.radosgw.keyring
ceph-authtool /etc/ceph/ceph.client.radosgw.keyring -n client.radosgw.mvig-storage-pve-1 --gen-key
ceph-authtool -n client.radosgw.mvig-storage-pve-1 --cap osd 'allow rwx' --cap mon 'allow rwx' /etc/ceph/ceph.client.radosgw.keyring
ceph -k /etc/pve/priv/ceph.client.admin.keyring auth add client.radosgw.mvig-storage-pve-1 -i /etc/ceph/ceph.client.radosgw.keyring

cp /etc/ceph/ceph.client.radosgw.keyring /etc/pve/priv
```

Add the following lines to /etc/ceph/ceph.conf:

```conf
[client.radosgw.mvig-storage-pve-1]
         host = mvig-storage-pve-1
         keyring = /etc/pve/priv/ceph.client.radosgw.keyring
         log file = /var/log/ceph/client.rados.$host.log
         rgw_nds_name = s3.hpc.robotflow.ai
```

Install radosgw

```shell
apt install radosgw
systemctl start radosgw
```

Test Readiness

```shell
curl -k localhost:7480
```

Create an user

```shell
radosgw-admin user create --uid=rgw-dashboard --display-name=rgw-dashboard --system
```

This will return a json. Create a access|secret.key paire file with only access_key and secret_key

```shell
ceph dashboard set-rgw-api-access-key -i acceess.key # file-content
ceph dashboard set-rgw-api-secret-key -i secret.key # file-content
ceph dashboard set-rgw-api-ssl-verify False
```

> [https://pve.proxmox.com/wiki/User:Grin/Ceph_Object_Gateway](https://pve.proxmox.com/wiki/User:Grin/Ceph_Object_Gateway)

## Misc

### Set crush rule for device_health_metrics

```shell
ceph osd pool set device_health_metrics crush_rule replicated_rule_osd
```

### Configure Kernel

Kernel parameters need to be tuned.

```shell
echo fs.inotify.max_user_instances=81920 >> /etc/sysctl.conf && sysctl -p
echo fs.aio-max-nr=1048576 >> /etc/sysctl.conf && sysctl -p
```

### Single Node Patches

```shell
ceph osd set noout # no osd out
ceph osd set nobackfill # no osd backfill
ceph osd set norecover # no osd recover
ceph osd set norebalance # no osd rebalance
```

###  Backfill control

Backfill could be controled:

```shell
ceph daemon mon.mvig-storage-pve-1 config show | grep osd_recovery
ceph tell 'osd.*' injectargs --osd_recovery_op_priority 3
```

### CEPH CONF (For reference)

```conf
[global]
         auth_client_required = cephx
         auth_cluster_required = cephx
         auth_service_required = cephx
         cluster_network = 100.99.96.0/24
         fsid = 8835849f-db7f-44a0-94ac-f27108bc47a5
         mon_allow_pool_delete = true
         mon_host = 100.99.96.250
         ms_bind_ipv4 = true
         ms_bind_ipv6 = false
         osd_pool_default_min_size = 2
         osd_pool_default_size = 3
         public_network = 100.99.96.0/24
         rgw_override_bucket_index_max_shards = 100

[client]
         keyring = /etc/ceph/ceph.client.robotflow.keyring

[client.radosgw.mvig-storage-pve-1]
         host = mvig-storage-pve-1
         keyring = /etc/pve/priv/ceph.client.radosgw.keyring
         log file = /var/log/ceph/client.rados.$host.log
         rgw_nds_name = s3.hpc.robotflow.ai

[client.rgw.mvig-storage-pve-1]
         rgw_host = mvig-storage-pve-1
         rgw_frontends = civetweb
         rgw_override_bucket_index_max_shards = 100

[mds]
         keyring = /var/lib/ceph/mds/ceph-$id/keyring

[mds.mvig-storage-pve-1]
         host = mvig-storage-pve-1
         mds_standby_for_name = pve

[mds.mvig-storage-pve-1-1]
         host = mvig-storage-pve-1
         mds_standby_for_name = pve

[mds.mvig-storage-pve-1-2]
         host = mvig-storage-pve-1
         mds_standby_for_name = pve
         mds_standby_replay = true

[mds.mvig-storage-pve-1-3]
         host = mvig-storage-pve-1
         mds standby for name = pve
         mds standby replay = true

[mon.mvig-storage-pve-1]
         public_addr = 100.99.96.250
```

> pay attention to cluster_network
