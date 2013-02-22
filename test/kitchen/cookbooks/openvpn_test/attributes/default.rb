
# configure the openvpn cookbook from here
default[:openvpn][:configs] = {
  'test1' => {
    :port => 1194,
    :proto => 'udp',
    :dev => 'tun',
    :mode => 'routed',
    :remote_host => 'localhost',
    :subnet => '10.8.0.0',
    :netmask => '255.255.255.0',
    :auth => {
      :type => :passwd
    },
    :dh_keysize => 1024,
    # load cert/key files from here too
    :file_cookbook => 'openvpn_test'
  }
}

default[:openvpn][:client_configs] = {}
