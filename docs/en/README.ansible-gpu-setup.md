# NVIDIA Driver and Docker GPU Setup

This module installs NVIDIA drivers and configures Docker to work with GPUs.
It ensures a unified driver set and consistent Docker configuration across all GPU-enabled servers.

## Tasks

1. Add the NVIDIA Container Toolkit repository
2. Update the package list
3. Install the NVIDIA driver
4. Reboot the server
5. Install `nvidia-docker2`
6. Copy the Docker GPU configuration ([daemon.json](../../src/ansible-gpu-setup/nvidia-docker-conf/daemon.json))
7. Restart Docker

## Docker daemon configuration ([daemon.json](../../src/ansible-gpu-setup/nvidia-docker-conf/daemon.json))

The main `daemon.json` parameters are described
here: [README.ansible-docker-install.md](README.ansible-docker-install.md)

| Key        | Value                              | Description                                                                       |
|------------|------------------------------------|-----------------------------------------------------------------------------------|
| `runtimes` | Object with custom Docker runtimes | Allows defining alternative runtimes for containers.                              |
| `nvidia`   | Имя runtime                        | Defines a runtime named nvidia. It can be used in containers via --runtime=nvidia |
| `path`     | `nvidia-container-runtime`         | Specifies the path to the runtime binary used to run GPU-enabled containers.      |

### Run Instructions

1. In the `hosts` file, add target servers to the `need_gpu_setup` group
   where the drivers will be installed.
2. ПIf needed, change the NVIDIA driver version in [gpu-setup.yml](../../src/ansible-gpu-setup/playbooks/gpu-setup.yml)
   (default is nvidia-driver-535).
3. Run the command:

```bash
make docker-setup
```

4. Verify GPU availability on the server:

```bash
nvidia-smi
```

5. Verify GPU support in Docker:

```bash
docker run --rm --gpus all nvidia/cuda:12.2.0-base nvidia-smi
```

## Recommendations and Verification

- Make sure the server is equipped with a compatible NVIDIA GPU.
- Use this playbook as the standard for all GPU servers to maintain a consistent driver version and Docker configuration.

