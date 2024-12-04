# About

Virtual Private LAN Services are common place in modern networking. 
This repository contains implementation of VPLS based on Host Identity Protocol.

# Introduction

Host Identity Protocol, or HIP, is layer 3.5 solution,
which was initially designed to split the dual role of the IP address: 
locator and identifier. Using HIP protocol one can solve not
only mobility problems, but also establish authenticated secure
channel. This repository contains simple implementation of HIP-VPLS.

At the moment the development is ongoing. Linux was selected as a target system and all the 
development currently done for this operating system.

We are going to test the implementation using Mininet simulation environment.

# Usage

At the moment the setup is simple. We have four routers, which form the HIP VPLS and five switches
connecting hosts and routers. There are also four hosts that are agnostic about the topology used.

First clone the repository:
```
$ cd ~
$ git clone https://github.com/Acksay/hip-vpls.git
```

After this step is done you can deploy the topology:

```
$ cd hip-vpls
$ sudo bash deploy.sh
```
The script should install Mininet and start the topology if it does not
run  the following command to start the topology:

```
$ cd ~
$ cd hip-vpls
$ sudo python3 hipls-mn.py
```

Base exchange should complete its execution in a few seconds. 

Once BEX is done, you should be able to ping hu2 from hu1 as follows (from the mininet):

```
mininet> hu1 ping hu2
```

You can view the progress of the BEX and other interaction in the logs:

```
$ tail -f spoke1/hipls.log
```
or
```
$ tail -f hub1/hipls.log
```
etc.

Other useful commands:

View ports' statuses
```
mininet> sw4 ovs-ofctl show "sw4"
```

Capture the packets between HIP switches:

```
mininet > hu2 tcpdump -n -i hu2-eth1 -w ipsec.pcap
```



