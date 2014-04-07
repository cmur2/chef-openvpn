class << self; include OpenvpnHelpers; end

package "openvpn"

# create openvpn user and group
user "openvpn"
group "openvpn" do
  members ["openvpn"]
end

directory "/var/log/openvpn" do
  owner "root"
  group "root"
  mode 00755
end

openvpn_process :configs, :client_configs do
  config_name = self.conf_name
  config = self.conf
  set_default_script_security # we set default attributes in here, so move carefully

  if self.conf_type == :server
    # setting ccd to enabled by default
    if config[:mode] == "routed" and config[:subnet6] and not config[:subnet]
      raise "OpenVPN configuration '#{config_name}': You need to specify an IPv4 subnet too when using an IPv6 subnet!"
    end
   
    directory "/etc/openvpn/#{config_name}" do
      owner "root"
      group "openvpn"
      mode 00770
    end
  end
end
