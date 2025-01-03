#!/usr/bin/python

from mininet.topo import Topo
from mininet.net import Mininet
from mininet.node import Node, OVSController, OVSKernelSwitch
from mininet.log import setLogLevel, info
from mininet.cli import CLI


class LinuxRouter( Node ):
    "A Node with IP forwarding enabled."

    def config( self, **params ):
        super( LinuxRouter, self).config( **params )
        # Enable forwarding on the router
        self.cmd( 'sysctl net.ipv4.ip_forward=1' )

    def terminate( self ):
        self.cmd( 'sysctl net.ipv4.ip_forward=0' )
        super( LinuxRouter, self ).terminate()


class NetworkTopo( Topo ):
    def build( self, **_opts ):
        hup_pe_1 = self.addNode( 'hub1', cls=LinuxRouter )
        hup_pe_2 = self.addNode( 'hub2', cls=LinuxRouter )
        hup_pe_3 = self.addNode( 'hub3', cls=LinuxRouter )
        s1, s2, s3, s4 = [ self.addSwitch( s, cls=OVSKernelSwitch ) for s in ( 's1', 's2', 's3', 's4' ) ]
        self.addLink( s1, hup_pe_1, intfName2='hub1-eth0',
                      params2={ 'ip' : '192.168.1.1/24' } )
        self.addLink( s2, hup_pe_2, intfName2='hub2-eth0',
                params2={ 'ip' : '192.168.1.2/24' } )
        self.addLink( s3, hup_pe_3, intfName2='hub3-eth0',
                params2={ 'ip' : '192.168.1.3/24' } )
        self.addLink( s4, hup_pe_1,
                intfName2='hub1-eth1',
                params2={ 'ip' : '192.168.3.1/29' } )
        self.addLink( s4, hup_pe_2,
                intfName2='hub2-eth1',
                params2={ 'ip' : '192.168.3.2/29' } )
        self.addLink( s4, hup_pe_3,
                intfName2='hub3-eth1',
                params2={ 'ip' : '192.168.3.3/29' } )

 
        h1 = self.addHost( 'h1', ip='192.168.1.100/24',
                           defaultRoute='via 192.168.1.1' )
        h2 = self.addHost( 'h2', ip='192.168.1.101/24',
                           defaultRoute='via 192.168.1.2' )
        for h, s in [ (h1, s1), (h2, s2)]:
            self.addLink( h, s )

def run():
    topo = NetworkTopo()
    net = Mininet(topo=topo, switch=OVSKernelSwitch, controller = OVSController)
    net.start()
    info( net[ 'hub1' ].cmd( 'ifconfig hub1-eth1 192.168.3.1 netmask 255.255.255.248' ) )
    info( net[ 'hub2' ].cmd( 'ifconfig hub2-eth1 192.168.3.2 netmask 255.255.255.248' ) )
    info( net[ 'hub3' ].cmd( 'ifconfig hub3-eth1 192.168.3.3 netmask 255.255.255.248' ) )


    info( net[ 'hub1' ].cmd( '/sbin/ethtool -K hub1-eth0 rx off tx off sg off' ) )
    info( net[ 'hub1' ].cmd( '/sbin/ethtool -K hub1-eth1 rx off tx off sg off' ) )
    info( net[ 'hub2' ].cmd( '/sbin/ethtool -K hub2-eth0 rx off tx off sg off' ) )
    info( net[ 'hub2' ].cmd( '/sbin/ethtool -K hub2-eth1 rx off tx off sg off' ) )
    info( net[ 'hub3' ].cmd( '/sbin/ethtool -K hub3-eth0 rx off tx off sg off' ) )

    info( net[ 'h1' ].cmd( '/sbin/ethtool -K h1-eth0 rx off tx off sg off' ) )
    info( net[ 'h2' ].cmd( '/sbin/ethtool -K h2-eth0 rx off tx off sg off' ) )

    info( net[ 'h1' ].cmd( 'ifconfig h1-eth0 mtu 1400' ) )
    info( net[ 'h2' ].cmd( 'ifconfig h2-eth0 mtu 1400' ) )


    info( net[ 's1' ].cmd( 'ovs-vsctl set bridge s1 stp_enable=true' ) )
    info( net[ 's2' ].cmd( 'ovs-vsctl set bridge s2 stp_enable=true' ) )
    info( net[ 's3' ].cmd( 'ovs-vsctl set bridge s3 stp_enable=true' ) )
    info( net[ 's4' ].cmd( 'ovs-vsctl set bridge s4 stp_enable=true' ) )

    for h in net.hosts:
        info( '*** Disable IPv6 on hosts:\n' )
        h.cmd("sysctl -w net.ipv6.conf.all.disable_ipv6=1")
        h.cmd("sysctl -w net.ipv6.conf.default.disable_ipv6=1")
        h.cmd("sysctl -w net.ipv6.conf.lo.disable_ipv6=1")

    for sw in net.switches:
        info( '*** Disable IPv6 on SWs:\n' )
        sw.cmd("sysctl -w net.ipv6.conf.all.disable_ipv6=1")
        sw.cmd("sysctl -w net.ipv6.conf.default.disable_ipv6=1")
        sw.cmd("sysctl -w net.ipv6.conf.lo.disable_ipv6=1")
    info( '*** Routing Table on Router:\n' )
    info( net[ 'hub1' ].cmd( 'route' ) )
    info( '*** Routing Table on Router:\n' )
    info( net[ 'hub2' ].cmd( 'route' ) )
    info( '*** Running HIPLS on Hub 1 *** \n')
    info( net[ 'hub1' ].cmd( 'cd hub1 && python3 switchd.py &' ) )
    info( '*** Running HIPLS on Hub 2 *** \n')
    info( net[ 'hub2' ].cmd( 'cd hub2 && python3 switchd.py &' ) )
    info( '*** Running HIPLS on Hub 3 *** \n')
    info( net[ 'hub3' ].cmd( 'cd hub3 && python3 switchd.py &' ) )
    CLI( net )
    net.stop()
    

if __name__ == '__main__':
    setLogLevel( 'info' )
    run()
