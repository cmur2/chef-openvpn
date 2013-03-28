
def cb_path
  [Pathname.new(File.join(File.dirname(__FILE__), '..', '..', '..')).cleanpath.to_s, 'spec/support/cookbooks', 'spec/support/my-cookbooks']
end

def config_file(config_name)
  "/etc/openvpn/#{config_name}.conf"
end

def config_dir(config_name)
  "/etc/openvpn/#{config_name}"
end

def config_sub_file(config_name, sub_file)
  "/etc/openvpn/#{config_name}/#{sub_file}"
end

def configs
  {
    'test1' => {
      :port => 1194,
      :proto => 'udp',
      :dev => 'tun',
      :mode => 'routed',
      :remote_host => 'localhost',
      :subnet => '10.8.0.0',
      :netmask => '255.255.255.0',
      :auth => {
        :type => 'passwd'
      },
      :file_cookbook => 'openvpn-files'
    },
    'test2' => {
      :port => 1195,
      :proto => 'udp',
      :dev => 'tun',
      :mode => 'routed',
      :remote_host => 'localhost',
      :subnet => '10.9.0.0',
      :netmask => '255.255.255.0',
      :auth => {
        :type => 'cert_passwd'
      },
      :file_cookbook => 'openvpn-files'
    },
    'test3' => {
      :port => 1196,
      :proto => 'udp',
      :dev => 'tun',
      :mode => 'routed',
      :remote_host => 'localhost',
      :subnet => '10.10.0.0',
      :netmask => '255.255.255.0',
      :auth => {
        :type => 'cert'
      },
      :file_cookbook => 'openvpn-files'
    }
  }
end

def client_configs
  {
    'test11' => {
      :user_name => 'foo',
      :auth => {
        :type => 'passwd'
      },
      :file_cookbook => 'openvpn-files'
    },
    'test12' => {
      :user_name => 'foo',
      :auth => {
        :type => 'cert_passwd'
      },
      :file_cookbook => 'openvpn-files'
    },
    'test13' => {
      :user_name => 'foo',
      :auth => {
        :type => 'cert'
      },
      :file_cookbook => 'openvpn-files'
    }
  }
end
