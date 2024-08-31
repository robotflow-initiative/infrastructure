#!/bin/bash

# Detect if $ROS_DISTRO is set
if [ -z "$ROS_DISTRO" ]; then
    echo "ROS_DISTRO is not set. Please source a ROS workspace first."
    exit 1
fi

sudo apt-get install -y \
    python3-pip \
    ros-${ROS_DISTRO}-libfranka \
    ros-${ROS_DISTRO}-panda-moveit-config \
    ros-${ROS_DISTRO}-franka-ros \
    ros-${ROS_DISTRO}-moveit

rosdep install --from-path src --ignore-src --rosdistro ${ROS_DISTRO} -y --skip-keys libfranka