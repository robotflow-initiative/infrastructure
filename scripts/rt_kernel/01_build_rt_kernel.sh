#!/bin/bash



# Function to prompt for input
prompt_input() {
    read -p "$1 [$2]: " input
    echo "${input:-$2}"
}

# Prompt for kernel version, RT kernel version, and secure boot
kernel_version=$(prompt_input "Enter the kernel version, this should match the version of the kernel you are running. (e.g. 5.15.113)" "")
rt_kernel_version=$(prompt_input "Enter the RT kernel subversion. (e.g. rt64)" "")
secure_boot=$(prompt_input "Is UEFI Secure Boot enabled? (yes/no)" "no")

# Abort if RT kernel version is not provided
if [[ -z "$rt_kernel_version" ]]; then
    echo "RT kernel version is required. Aborting."
    exit 1
fi

# Check if the current kernel is an RT kernel
current_kernel=$(uname -r)
if [[ "$current_kernel" == *rt* ]]; then
    echo "Current kernel is an RT kernel. Aborting."
    exit 1
fi

# Extract major version of the kernel
rt_kernel_major_version=$(echo "$kernel_version" | cut -d'.' -f1,2)

# Create directory for kernel source
mkdir -p /opt/kernel/src/${kernel_version}

# Install necessary dependencies
dependencies=(
    build-essential
    libncurses-dev
    bison
    flex
    libssl-dev
    libelf-dev
    libudev-dev
    libpci-dev
    libiberty-dev
    autoconf
    fakeroot
    mokutil
    openssl
    dkms
    zstd
    dwarves
)
apt-get update
apt-get install -y "${dependencies[@]}"

set -e

# Download kernel source if it doesn't exist
kernel_tarball="/opt/kernel/src/${kernel_version}/linux-${kernel_version}.tar.xz"
if [[ ! -f "$kernel_tarball" ]]; then
    wget -O "$kernel_tarball" "https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/linux-${kernel_version}.tar.xz"
fi

# Download RT patch
rt_patch="/opt/kernel/src/${kernel_version}/patch-${kernel_version}-${rt_kernel_version}.patch.xz"
if [[ ! -f "$rt_patch" ]]; then
    wget -O "$rt_patch" "https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/${rt_kernel_major_version}/patch-${kernel_version}-${rt_kernel_version}.patch.xz" || \
    wget -O "$rt_patch" "https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/${rt_kernel_major_version}/older/patch-${kernel_version}-${rt_kernel_version}.patch.xz"
fi

# Check if the RT patch exists
if [[ ! -f "$rt_patch" ]]; then
    echo "RT patch not found. Aborting."
    exit 1
fi
# Extract kernel source
rm -rf /opt/kernel/src/${kernel_version}/linux-${kernel_version} && tar -xf "$kernel_tarball" -C /opt/kernel/src/${kernel_version}


# Apply RT patch
cd "/opt/kernel/src/${kernel_version}/linux-${kernel_version}/" || exit
xzcat "$rt_patch" | patch -p1

# Copy the running config
cp /boot/config-$(uname -r) .config

# Configure the kernel
yes '' | make oldconfig

# Enable RT_PREEMPT
./scripts/config --enable CONFIG_PREEMPT
./scripts/config --enable CONFIG_PREEMPT_DYNAMIC
./scripts/config --enable CONFIG_HIGH_RES_TIMERS
./scripts/config --enable CONFIG_NO_HZ_FULL
./scripts/config --set-val CONFIG_HZ 1000
./scripts/config --enable CONFIG_HZ_1000
./scripts/config --disable CONFIG_DEBUG_INFO_BTF

# Optional: enable CPU_FREQ and CPU_FREQ_DEFAULT_GOV_PERFORMANCE
# ./scripts/config --enable CONFIG_CPU_FREQ
# ./scripts/config --enable CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE

# Optional: disable SYSTEM_TRUSTED_KEYS and SYSTEM_REVOCATION_KEYS
./scripts/config --disable SYSTEM_TRUSTED_KEYS
./scripts/config --disable SYSTEM_REVOCATION_KEYS


# Optional:  build the deb-pkg
make -j$(nproc) deb-pkg

echo "RT Kernel patching complete."
