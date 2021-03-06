#!/usr/bin/env perl

use File::Basename;
use IO::Socket::INET;
use Net::DHCP::Packet;
use Net::DHCP::Constants;

$usage = "usage: ".basename($0)." <mac> <ip> <domain> <name>\n";

$mac = shift or die $usage;
$ip = shift or die $usage;
$domain = shift or die $usage;
$name = shift or die $usage;

$request = Net::DHCP::Packet->new(
	Xid => 0x11111111,
	Flags => 0x0000,
	Chaddr => $mac,
	DHO_DHCP_MESSAGE_TYPE() => DHCPREQUEST(),
	DHO_HOST_NAME() => $name,
	DHO_VENDOR_CLASS_IDENTIFIER() => $mac,
	DHO_DHCP_REQUESTED_ADDRESS() => $ip,
	DHO_DOMAIN_NAME() => $domain,
	DHO_DHCP_CLIENT_IDENTIFIER() => $mac
);

$ack = Net::DHCP::Packet->new(
	Xid => 0x11111111,
	Flags => 0x0000,
	Chaddr => $mac,
	DHO_DHCP_MESSAGE_TYPE() => DHCPACK(),
);

$handle = IO::Socket::INET->new(
	Proto => 'udp',
	Broadcast => 1,
	PeerPort => '67',
	LocalPort => '68',
	PeerAddr => '255.255.255.255'
) or die "Socket: $@";

$handle->send($request->serialize()) or die "Error sending broadcast request:$!\n";
$handle->send($ack->serialize()) or die "Error sending broadcast act:$!\n";
