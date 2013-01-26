# chef-openvpn

## Description

A multi-configuration OpenVPN server cookbook featuring IPv6 support and easy setup of client files.

## Usage

Include the openvpn::default target to your runlist and do further configuration via node's attributes. To automatically generate client configuration file stubs include the openvpn::users target. With openvpn::logrotate your logs (of all configurations) will be automatically rotated if the logrotate cookbook is present.

For full, out-of-the-box IPv6 support you will need OpenVPN 2.3 or higher which is not available on older versions of Debian and Ubuntu - therefore and for those who only want more recent OpenVPN packages on their system the openvpn::use_community_repos target registers new APT repositories maintained by the OpenVPN community (needs the apt cookbook).

## Requirements

### Platform

It should work on all OSes that provide a (recent, versions above 2.0) openvpn package.

## Recipes

### default

### users

### use_community_repos

### logrotate

## License

chef-openvpn is licensed under the Apache License, Version 2.0. See LICENSE for more information.
