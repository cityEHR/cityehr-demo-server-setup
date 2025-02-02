# cityEHR Demo Server Setup

The following instructions will enable you to setup a cityEHR Demo Server.

## Obtaining Servers

This can be setup either in [AWS EC2](https://aws.amazon.com/ec2/), or another Virtual Environment such as KVM running on a Linux Server.
The environment (which provided 1x cityEHR Demo Server Virtual Machine) and that was Ubuntu 24.04 running on a bare-metal server leased via [Evolved Binary](https://www.evolvedbinary.com) from [Hetzner](https://www.hetzner.com/) in Germany, with the following configuration:
* Xeon E5-1650 v3 @ 3.50GHz (6 Cores / 12 Threads)
* 128 GB RAM
* 2x 480GB SSD in RAID 1

Below we detail two options for setting up Virtual Machines: 1. Hetzner bare-metal server, and 2. AWS EC2.

### 1. Setting up a new Linux KVM VM (optional)

If you have leased a server from someone like Hetzner with Ubuntu 24.04 installed and wish to set this all up using KVM to host your VMs, then on the server (KVM host) you should run the following commands (assuming an Evolved Binary Server in Hetzner):

```shell
git clone --single-branch --branch hetzner https://github.com/adamretter/soyoustart hetzner
cd ~/hetzner

sudo uvt-simplestreams-libvirt sync --source=http://cloud-images.ubuntu.com/minimal/releases arch=amd64 release=noble
```

As IPv4 addresses are becoming less available and therefore more expensive, you can setup either:

	1. A VM with a Public IPv6 Address and Private IPv4
		This can be directly accessible over IPv6 and on the Internet.
		If you wish to access it via IPv4 over the Internet you will need to setup some sort of NAT and/or Port Forwarding, or a reverse web-proxy from another machine that has a Public IPv4 address.

	2. A VM with a Public IPv6 Address and Public IPv4
		This can be directly accessible over IPv6 and IPv4 on the Internet.

#### Option 1 - VM with Public IPv6 and Private IPv4

```shell
./create-uvt-kvm.sh --hostname cityehr-demo --release noble --memory 8192 --disk 30 --cpu-model host-passthrough --cpu 4 --bridge virbr1 --ip6 2a01:4f8:140:91f0::220 --gateway6 2a01:4f8:140:91f0::2 --dns 2a01:4ff:ff00::add:1 --dns 2a01:4ff:ff00::add:2 --dns-search evolvedbinary.com --private-1-bridge virbr0 --private-1-ip 192.168.122.220 --private-1-next-network 0.0.0.0/0 --private-1-gateway 192.168.122.1 --private-1-dns 185.12.64.1 --private-1-dns 185.12.64.2 --private-1-dns-search evolvedbinary.com --private-2-bridge virbr2 --private-2-ip 10.0.55.220 --private-2-next-network 10.0.1.254/32 --private-2-gateway 10.0.55.254 --auto-start
```

**NOTE**: The VM specific settings are:
* `--hostname` `cityehr-demo`
* `--ip6` `2a01:4f8:140:91f0::220`
* `--private-1-ip` `192.168.122.220` (IANA Private)

**NOTE**: The network settings specific to the host are:
* `--bridge` `virbr1`
* `--gateway6` `2a01:4f8:140:91f0::2`
* `--private-1-bridge` `virbr0`
* `--gateway` `192.168.122.1` (IANA Private)

**NOTE**: The network settings specific to the hosting provider are:
* `--dns 2a01:4ff:ff00::add:1`, `--dns 2a01:4ff:ff00::add:2`
* `--dns 185.12.64.1`, `--dns 185.12.64.2`

#### Option 2 - VM with Public IPv6 and Public IPv4

```shell
./create-uvt-kvm.sh --hostname cityehr-demo --release noble --memory 8192 --disk 30 --cpu-model host-passthrough --cpu 4 --bridge virbr1 --ip 188.40.179.162 --ip6 2a01:4f8:140:91f0::162 --gateway 46.4.100.114 --gateway6 2a01:4f8:140:91f0::2 --dns 2a01:4ff:ff00::add:1 --dns 2a01:4ff:ff00::add:2 --dns 185.12.64.1 --dns 185.12.64.2 --dns-search evolvedbinary.com  --private-1-bridge virbr0 --private-1-ip 192.168.122.161 --private-2-bridge virbr2 --private-2-ip 10.0.55.161 --private-2-next-network 10.0.1.254/32 --private-2-gateway 10.0.55.254 --auto-start
```

**NOTE**: The VM specific settings are:
* `--hostname` `cityehr-demo`
* `--ip6` `2a01:4f8:140:91f0::161`
* `--ip` `188.40.179.161`
* `--private-1-ip` `192.168.122.161` (IANA Private)

**NOTE**: The network settings specific to the host are:
* `--bridge` `virbr1`
* `--gateway6` `2a01:4f8:140:91f0::2`
* `--gateway` `46.4.100.114`

**NOTE**: The network settings specific to the hosting provider are:
* `--dns 2a01:4ff:ff00::add:1`, `--dns 2a01:4ff:ff00::add:2`
* `--dns 185.12.64.1`, `--dns 185.12.64.2`


### 2. Setting up a new AWS EC2 Instance (optional)

If you wish to set this up in AWS EC2, then for each Virtual Machine you need should setup a new EC2 instance with the following properties:

1. Name the instance 'cityehr-demo'. (change the `cityehr-demo` as needed for more machines).

2. Select the `Ubuntu Server 24.04 LTS (HVM), SSD Volume Type` AMI image, and the Architecture `amd64`.

3. Select `m6a.large` instance type. (i.e.: 2vCPU, 8GB Memory, 1x237 NVMe SSD, $0.0999 / hour).

4. Select the `cityehr` keypair.

5. Select the `cityehr-demo vm` Security Group.

6. Set the default Root Volume as an `EBS` `30 GiB` volume on `GP3` at `3000 IOPS` and `125 MiB throughput`.


## Installing an cityEHR Demo Server

You can install one or more cityEHR Demo Servers, each should be configured within its own virtual (or physical) machine. We expect to start from a clean Ubuntu Server, or Ubuntu Cloud Image install. This has been tested with Ubuntu version 24.04 LTS (x86_64).

### cityEHR Demo Server Software Environment

The following software will be configured:

* Java Development Environment
	* JDK 11
	* Apache Maven 3
	* Apache Tomcat 9

* cityEHR

* Miscellaneous Tools
	* Nullmailer
	* Zsh and OhMyZsh
	* Git
	* cURL
	* wget
	* Screen
	* tar, gzip, bzip2, zstd, zip (and unzip)


### Installing a cityEHR Demo Server

Each cityEHR Demo Server should be run in its own virtual machine. To install a cityEHR Demo Server run the following commands on a new VM:

```shell
git clone https://github.com/cityehr/cityehr-demo-server-setup.git
cd cityehr-demo-server-setup
sudo ./install-puppet-agent.sh

cd demo-server

sudo /opt/puppetlabs/bin/puppet apply 01-locale-gb.pp

sudo FACTER_default_user_password=mixturedanceexcitingseparate \
    /opt/puppetlabs/bin/puppet apply 02-base.pp
```

**NOTE:** you should set your own passwords appropriately above!

* `default_user_password` this is the password to set for the default linux user on this machine (typically the user is named `ubuntu` on Ubuntu Cloud images).

We have to restart the system after the above as it may install a new Kernel and make changes to settings that require a system reboot. So:

```shell
sudo shutdown -r now
```

After the system restarts and you have logged in, you need to resume from the `cityehr-demo-server-setup/demo-server` repo checkout:

```shell
cd cityehr-demo-server-setup/demo-server
sudo FACTER_default_user_password=mixturedanceexcitingseparate \
     /opt/puppetlabs/bin/puppet apply .
```

**NOTE:** you should set your own passwords appropriately above!

* `default_user_password` this is the password to set for the default linux user on this machine (typically the user is named `ubuntu` on Ubuntu Cloud images).

After installation Tomcat's Web Server should be accessible from: [http://localhost:8080](http://localhost:8080) only on the localhost, and it should be accessible (via an nginx reverse proxy) from: [https://localhost](https://localhost) on the localhost or [https://cityehr-demo.evolvedbinary.com](https://cityehr-demo.evolvedbinary.com) on the Internet.
