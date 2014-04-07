name             "openvpn"
maintainer       "Christian Nicolai"
maintainer_email "cn@mycrobase.de"
license          "Apache 2.0"
description      "A multi-configuration OpenVPN server cookbook featuring IPv6 support and easy setup of client files."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "3.1.0"

suggests "logrotate" # for openvpn::logrotate
suggests "apt" # for openvpn::use_community_repos

supports "debian"
supports "ubuntu"
