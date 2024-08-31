# Franka Workspace

## Network Setup

Connect franka to a dedicated nic interface, do not use cheap ethernet switches that does not support Priority-based Flow Control(PFC) function. A direct RJ45 ethernet cable and GbE nic is sufficient in most cases.

Configure the interface as follows:

| Item    | Value         |
| ------- | ------------- |
| Address | 172.16.0.1    |
| Netmask | 255.255.255.0 |

Here is a [script](./setup_network.sh) that can be used to configure the interface:


The franka has a static IP `172.16.0.2`.

## Franka Operation Tips

Navigate to `172.16.0.2` in your browser, click the `Activate FCI` button to enable the force control interface.

## Franka ROS Setup

In order to operate franka, ROS1 must be installed. This workspace contains repo description for common Franka development. You can use vcstool to import them:

```shell
pip install vcstool
vcs import < franka.repo
```

The libraries will be imported to `src` directory

Install other dependencies via apt:

```shell
export ROS_DISTRO=noetic
sudo apt-get install -y \
    python3-pip \
    ros-${ROS_DISTRO}-libfranka \
    ros-${ROS_DISTRO}-panda-moveit-config \
    ros-${ROS_DISTRO}-franka-ros \
    ros-${ROS_DISTRO}-moveit
rosdep install --from-path src --ignore-src --rosdistro ${ROS_DISTRO} -y --skip-keys libfranka
```

> This [script](./setup_deps.sh) can be used to install the dependencies.

Compile the workspace:

```shell
catkin_make -DCMAKE_BUILD_TYPE=Release
```

> Note: the `azure_kinect_ros_driver` is depends on `k4a` library, which is not available in the default apt repository. You can install it via the [azure_kinect_k4a.yml](../../playbooks/driver/azure_kinect_k4a.yml) playbook.

## Example

Launch the moveit configuration:

```shell
roslaunch panda_moveit_config franka_control.launch robot_ip:=172.16.0.2 load_gripper:=true
```

### ROS works with conda

To use ROS1 with conda, all you need is to install `rospkg` `rospy` and `catkin_pkg` via pip:

```shell
pip install rospkg rospy catkin_pkg
```
