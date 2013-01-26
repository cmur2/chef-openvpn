# chef-openvpn

## Description

A multi-configuration OpenVPN server cookbook featuring IPv6 support and easy generation of client configuration files.

## Usage

Include the openvpn::default target to your runlist and do further configuration via node's attributes. To automatically generate client configuration file stubs include the openvpn::users target. With openvpn::logrotate your logs (of all configurations) will be automatically rotated if the logrotate cookbook is present.

For full, out-of-the-box IPv6 support you will need OpenVPN 2.3 or higher which is not available on older versions of Debian and Ubuntu - therefore and for those who only want more recent OpenVPN packages on their system the openvpn::use_community_repos target registers new APT repositories maintained by the OpenVPN community (needs the apt cookbook).

## Requirements

### Platform

It should work on all OSes that provide a (recent, versions above 2.0) openvpn package.

## Recipes

### default

Configures and starts an OpenVPN for each configuration (config name => config hash) found in 'node[:openvpn][:configs]'. A configuration may contain several options such as:

* config[:port] - port number the server listens on
* config[:proto] - 'udp' or 'tcp'
* config[:dev] - 'tun', 'tap' or a specific device like 'tun0'
* config[:mode] - 'routed' (uses server directive) or 'bridged' (uses server-bridge directive)
* config[:remote_host] - host name that clients can use to reach the server
* config[:remote_port] - port that clients can use to reach the server (may be omitted, defaults to config[:port])
* config[:subnet] - the IPv4 subnet (*don't* use CIDR here) used for VPN addresses in 'routed' mode
* config[:subnet6] - the IPv6 subnet (use CIDR here) used for VPN addresses in 'routed' mode - requires OpenVPN 2.3 or higher
* config[:server_ip] - the server's VPN address in 'bridged' mode
* config[:dhcp_start] - the lower bound for DHCP addresses in 'bridged' mode
* config[:dhcp_end] - the upper bound for DHCP addresses in 'bridged' mode
* config[:netmask] - the VPN internal IPv4 netmask, applies for 'routed' and 'bridged' mode
* config[:auth][:type] - 'cert', 'cert_passwd' or 'passwd' - combines client certificates with user passwords if enabled
* config[:redirect_gateway] - may be omitted, if specified and true pushes redirect-gateway option to clients
* config[:push_dns_server] - may be omitted, if specified and true pushes the DNS server from 'config[:push_dns]' to clients
* config[:push_dns] - DNS server to be pushed to clients if enabled
* config[:allow_duplicate_cn] - may be omitted, if specified and true allows duplicate common names of clients
* config[:allow_client_to_client] - may be omitted, if specified and true allows client-to-client traffic

There are no defaults for this attributes so missing specific attributes may lead to errors.

Example:

	'openvpn': {
      'community_repo_flavor': 'snapshots',
      'configs': {
        'openvpn6': {
          'port': 1194,
          'proto': 'udp',
          'dev': 'tun',
          'mode': 'routed',
          'remote_host': 'vpn.example.org',
          'subnet': '10.8.0.0',
          'subnet6': '2001:0db8:0:0::0/64',
          'netmask': '255.255.0.0',
          'auth': {
            'type': 'passwd'
          },
          'allow_duplicate_cn': true
        }
      }
    }

Each authentication mode requires you to specify your users database in a databag named '<config_name>-users' (dots transformed to underscores) that contains one item per user (id is the username). A user's password is stored at the 'pass' key. A user's certificate and key are stored at the 'cert' and 'key' keys in the databag item.

### users

Generates OpenVPN configuration stub files in a subdirectory of the configuration's directory on the server. All known options will be prefilled but in a client OS-independent manner (e.g. for windows clients some options are missing). Plans are to extend this to even generate Windows-specific or Tunnelblick-specific files.
Next to the configuration file all needed certificates and keys are stored.

### use_community_repos

When run on supported platforms (Debian, Ubuntu) adds a new APT repository that uses the OpenVPN community repos. Most times you may choose between the two flavors stable (default) or snapshots (later is needed for OpenVPN 2.3 on Debian Squeeze).

* node[:openvpn][:community_repo_flavor] - 'stable' or 'snapshots' (default is 'snapshots')

### logrotate

Adds a OpenVPN specific logrotate configuration when logrotate cookbook is found. No attributes needed.

## License

chef-openvpn is licensed under the Apache License, Version 2.0. See LICENSE for more information.
