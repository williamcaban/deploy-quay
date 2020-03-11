# Deploying Basic Quay Registry

Simplify systemd podman containers dpeloying a Basic Quay Registry

## Prerequisites

The documented steps assumes:
- New RHEL 8.1 server with a valid subscription
- Enable repo for Ansible Core
  ```
  sudo subscription-manager repos --enable ansible-2.9-for-rhel-8-x86_64-rpms
  ```
- Install Ansible
  ```
  sudo yum -y install ansible
  ```
- Git clone this repo
  ```
  git clone https://github.com/williamcaban/deploy-quay.git
  ```

## Steps

- Obtain JSON `config.json` for Red Hat Quay v3 from https://access.redhat.com/solutions/3533201
- Save the config.json pull secret as `quay-v3-config.json` in the working directory
- Execute playbook to deploy prerequisites for Quay and run Quay in config mode:
    ```
    ansible-playbook ./01_deploy-quay.yaml
    ```
- Identify the internal IP Address of the `quay-mysql` and `quay-redis` containers:
    ```
    sudo podman inspect quay-mysql --format {{.NetworkSettings.IPAddress}}
    sudo podman inspect quay-redis --format {{.NetworkSettings.IPAddress}}
    ```
- Go into the `./ssl` directory to configure SSL parameters
    ```
    cd ./ssl
    ```
- Copy the openssl configuration to `openssl.cnf`
    ```
    cp openssl-UPDATETHIS.cnf openssl.cnf
    ```
- Edit the CN, DNS.1 and IP.1 entries in `openssl.cnf` to match the environment:
    ```
    ...
    CN=registry.example.com
    ...
    [alt_names]
    DNS.1 = registry.example.com
    #DNS.2 = node123.example.com
    IP.1 = 192.168.1.25
    ```
- Generate SSL cert for Quay:
    ```
    ./01_generate-ssl-cert.sh
    ```
- Access the Quay configuration interfaces from `https://<your-vm-ip-or-fqdn>:8443`. Username `quayconfig` with password `quayconfig`
- Follow the wizard to create a new configuration and downlaod the resulting `quay-config.tar.gz` to the working directory (the one with the Ansible playbooks)
- Execute playbook to configure and run Quay registry
    ```
    ansible-playbook ./02-run-quay.yaml
    ```

## Credits

Thanks to Jay Cromer for support with the original Ansible Playbook.

## References

https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/building_running_and_managing_containers/using-systemd-with-containers_building-running-and-managing-containers#starting_containers_with_systemd
