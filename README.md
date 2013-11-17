# chef-openvpn

[![Build Status](https://travis-ci.org/cmur2/chef-openvpn.png)](https://travis-ci.org/cmur2/chef-openvpn)

## Description

A multi-configuration OpenVPN client/server cookbook featuring IPv6 support and easy generation of client configuration files.

## Usage

Include `recipe[openvpn::default]` in your `run_list` and do further configuration via node attributes. To automatically generate client configuration file stubs include `recipe[openvpn::users]`. With `recipe[openvpn::logrotate]` your logs (of all OpenVPN configurations) will be automatically rotated if the logrotate cookbook is present. To setup one or multiple OpenVPN clients use `recipe[openvpn::client]`.

For full, out-of-the-box IPv6 support you will need OpenVPN 2.3 or higher which is not available on older versions of Debian and Ubuntu - therefore and for those who only want more recent OpenVPN packages on their system the `recipe[openvpn::use_community_repos]` registers new APT repositories maintained by the OpenVPN community (needs the apt cookbook).

## Requirements

### Platform

It should work on all OSes that provide a (recent, versions above 2.0) openvpn package.

For supported Chef/Ruby version see [Travis](https://travis-ci.org/cmur2/chef-openvpn).

## Recipes

### default

Configures and starts an OpenVPN server for each configuration (config_name => config_hash mappings) found in `node['openvpn']['configs']`. A configuration may contain several options (most of them being required as long as not stated otherwise) such as:

* `config['port']` - port number the server listens on
* `config['proto']` - 'udp' or 'tcp'
* `config['dev']` - 'tun', 'tap' or a specific device like 'tun0'
* `config['mode']` - 'routed' (uses server directive) or 'bridged' (uses server-bridge directive)
* `config['remote_host']` - host name that clients can use to reach the server
* `config['remote_port']` - port that clients can use to reach the server (may be omitted, defaults to `config['port']`)
* `config['subnet']` - the IPv4 subnet (*don't* use CIDR here) used for VPN addresses in 'routed' mode
* `config['subnet6']` - the IPv6 subnet (use CIDR here) used for VPN addresses in 'routed' mode - requires OpenVPN 2.3 or higher
* `config['server_ip']` - the server's VPN address in 'bridged' mode
* `config['dhcp_start']` - the lower bound for DHCP addresses in 'bridged' mode
* `config['dhcp_end']` - the upper bound for DHCP addresses in 'bridged' mode
* `config['netmask']` - the VPN internal IPv4 netmask, applies for 'routed' and 'bridged' mode
* `config['auth']['type']` - 'cert', 'cert_passwd' or 'passwd' - combines client certificates and/or user passwords if enabled
* `config['dh_keysize']` - may be omitted, if specified will be the number of bits generated for the Diffie Hellman key file, if missing a cookbook_file has to be provided
* `config['file_cookbook']` - may be omitted, if specified will be used as the name of a cookbook where certificates and key file will be loaded from instead of the current cookbook
* `config['redirect_gateway']` - may be omitted, if specified and true pushes redirect-gateway option to clients
* `config['push_dns_server']` - may be omitted, if specified pushes the DNS specified server to clients
* `config['allow_duplicate_cn']` - may be omitted, if specified and true allows duplicate common names of clients
* `config['allow_client_to_client']` - may be omitted, if specified and true allows client-to-client traffic
* `config['comp_lzo']` - may be omitted, if specified and true enables compression (must match client setting)
* `config['keepalive_interval']` - may be omitted, if specified together with `config['keepalive_timeout']` enables the keepalive setting with specified interval
* `config['keepalive_timeout']` - may be omitted, if specified together with `config['keepalive_interval']` enables the keepalive setting with specified timeout
* `config['cipher_algo']` - may be omitted, if specified sets the cipher, e.g. AES-256-CBC (must match client setting)
* `config['keysize']` - may be omitted, if specified sets the keysize for variable ciphers (must match client setting)
* `config['auth_algo']` - may be omitted, if specified sets the auth, e.g. SHA256 (must match client setting)
* `config['push']` - array of generic push directives to include into the config
* `config['routes']` - array of route specifications

There are no defaults for this attributes so missing specific attributes may lead to errors.

Example node configuration:

```ruby
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
      'allow_duplicate_cn': true,
      'push': [
        'route 192.168.10.0 255.255.255.0'
      ],
      'routes': [
        '192.168.40.128 255.255.255.248'
      ]
    }
  }
}
```

The certificate files needed for the server should be placed in the cookbook's files directory (or via an overlay site-cookbooks directory that leaves the original cookbook untouched) as follows:

* *config_name*-ca.crt - certificate authority (CA) file in .pem format
* *config_name*.crt - local peer's signed certificate in .pem format
* *config_name*.key - local  peer's private key in .pem format
* optional: *config_name*-dh.pem - file containing Diffie Hellman parameters in .pem format (needed only if config['dh_keysize'] is missing)

Each authentication mode requires you to specify your users database in a data_bag named *config_name*-users (dots transformed to underscores) that contains one item per user (id is the username). A user's password is stored at the 'pass' key.

Example data_bag:

```json
{
    "id": "foo",
    "pass": "secret"
}
```

The recipe also generates a `ccd` (client config directory) and populates it with per-client information found in the data_bag mentioned above. Supported data_bag keys:

* `'ifconfig-push'`: value is the ifconfig to push (varies between point-to-point and bridged modes!)
* `'push'`: value is either an array of push directives or a single push directive as a string
* `'push-reset'`: if true places a push-reset in the client config
* `'iroute'`: value is either an array of routes to announce or a single route as a string

Example data_bag:

```json
{
    "id": "foo",
    "ifconfig-push": "10.8.0.6 10.8.0.5",
    "iroute": "192.168.40.128 255.255.255.248",
    "push": [
      "redirect-gateway"
    ]
}
```

### users

Generates OpenVPN configuration stub files in a subdirectory of the configuration's directory on the server. All known options will be prefilled but in a client OS-independent manner (e.g. for windows clients some options are missing). Plans are to extend this to even generate Windows-specific or Tunnelblick-specific files.
Next to the configuration file all needed certificates and keys are stored.

This recipe will generate the user's configuration files in the *users* subdirectory of the server configuration directory it belongs to.
It requires a data_bag named *config_name*-users (dots transformed to underscores) that contains one item per user and the following cookbook files per user:

* *config_name*-ca.crt - server's CA certificate (may/should be present for the server config too)
* *config_name*-*user_name*.crt - client's signed certificate in .pem format
* *config_name*-*user_name*.key - client's private key in .pem format

The **username** comes from the 'name' property of each item if given, else the data_bag ID (which sufferes from some limitation, e.g. underscores are not allowed) will be used automatically as username.

### client

The is completely seperated from the default (server) recipe and can be used standalone. It configures and starts an OpenVPN client for each configuration (client_config_name => config_hash) found in `node['openvpn']['client_configs']`. A configuration may contain several options such as:

* `config['user_name']` - the user_name the server awaits (used for identifying need cert and key files)
* `config['auth']['type']` - 'cert', 'cert_passwd' or 'passwd' - combines client certificates with user passwords if enabled
* `config['file_cookbook']` - may be omitted, if specified will be used as the name of a cookbook where certificates and key file will be loaded from instead of the current cookbook
* `config['comp_lzo']` - may be omitted, if specified and true enables compression (must match server setting)
* `config['cipher_algo']` - may be omitted, if specified sets the cipher, e.g. AES-256-CBC (must match server setting)
* `config['keysize']` - may be omitted, if specified sets the keysize for variable ciphers (must match server setting)
* `config['auth_algo']` - may be omitted, if specified sets the auth, e.g. SHA256 (must match server setting)

The certificate files should be placed in the cookbook's files directory (or via an overlay site-cookbooks directory that leaves the original cookbook untouched) as follows:

* *config_name*-*user_name*.conf - configuration file for this client (manually crafted or generated via users recipe)
* *config_name*-ca.crt - server's CA certificate
* *config_name*-*user_name*.crt - client's signed certificate in .pem format
* *config_name*-*user_name*.key - client's private key in .pem format

### use_community_repos

When run on supported platforms (Debian, Ubuntu) adds a new APT repository that uses the OpenVPN community repos. For Debian Lenny and Ubuntu Lucid (2. gen, relying on the old [repos.openvpn.net](https://community.openvpn.net/openvpn/wiki/OpenvpnSoftwareRepos#Notesonoldaptyumrepositories)) you may choose between the two flavors stable (default) or snapshots, for newer OSes there is only one repository using the new, 3. gen [swupdate.openvpn.net](https://community.openvpn.net/openvpn/wiki/OpenvpnSoftwareRepos).

* `node['openvpn']['community_repo_flavor']` - 'stable' or 'snapshots' (default is 'snapshots')

### logrotate

Adds a OpenVPN specific logrotate configuration when logrotate cookbook is found. No attributes needed.

## License

chef-openvpn is licensed under the Apache License, Version 2.0. See LICENSE for more information.
