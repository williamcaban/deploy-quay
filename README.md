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
- Identify the internal IP Address of the `quay-mysql` and `quay-redis` containers. (Take note of these IPs for later use):
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
    # Execute the script to generate keys and certificates
    $ ./01_generate-ssl-cert.sh

    Creating root CA
    Generating RSA private key, 2048 bit long modulus (2 primes)
    ................................................................................................+++++
    ....................................................+++++
    e is 65537 (0x010001)
    Create CSR and private key
    Generating a RSA private key
    ......+++++
    .................+++++
    writing new private key to 'ssl.key'
    -----
    Signing the certificate
    Signature ok
    subject=C = US, ST = MD, L = Columbia, O = Quay Basic Lab, OU = Quay Registry, CN = registry.example.com
    Getting CA Private Key

    # Validate all keys certificates have been created
    $ ls -1
    01_generate-ssl-cert.sh
    openssl.cnf
    openssl-UPDATETHIS.cnf
    rootCA.key
    rootCA.pem
    rootCA.srl
    ssl.cert
    ssl.csr
    ssl.key
    ```
- Access the Quay configuration interfaces from `https://registry.example.com:8443`.
- Login using Username `quayconfig` with password `quayconfig`
- Follow the wizard to create a new configuration
    ```
    # Variables for Database connection
    Database Type: MySQL
    Database Server: <ip address of quay-mysql from previous step>
    Username: quayuser
    Password: quaypass
    Database Name: quaydb
    ```
    - Click "Verify Connection"
    - Setup the information and create a super user
    - Setup the Quay configuration providing the ssl keys certificates (Note: Rename `rootCA.pem` to `rootCA.crt` for the wizard to accept it)
    - Specify the redis server
    - Generate the configuration
-  Downlaod the resulting `quay-config.tar.gz` to the working directory (the one with the Ansible playbooks)
-  Stop and remove the quay config container
    ```
    sudo podman kill quay-config
    sudo podman rm quay-config
    ```
- Execute playbook to load configuration and run Quay registry
    ```
    ansible-playbook ./02_run-quay.yaml
    ```

## Credits

Thanks to Jay Cromer for support with the original Ansible Playbook.

## References

https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/building_running_and_managing_containers/using-systemd-with-containers_building-running-and-managing-containers#starting_containers_with_systemd
