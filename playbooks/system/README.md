# General System configuration

| Name                               | Description                                      | Require Root | Distribution   |
| ---------------------------------- | ------------------------------------------------ | ------------ | -------------- |
| `common/configure_apt.yml`         | Configure APT Mirror                             | Yes          | Debian         |
| `common/configure_zerotier.yml`    | Ensure ZeroTier is installed and join an network | Yes          | Debian/RedHat  |
| `common/install_docker.yml`        | Ensure Docker is installed                       | Yes          | Debian(Ubuntu) |
| `common/install_packages.yml`      | Install Dev Packages via APT Docker is installed | Yes          | Debian         |
| `server/configure_system.yml`      | Disable unattended upgrade                       | Yes          | Debian(Ubuntu) |
| `workstation/configure_system.yml` | Disable unattended upgrade and hibernation       | Yes          | Debian(Ubuntu) |
