class << self; include OpenvpnHelpers; end

# setup each client_config
openvpn_process :client_configs do
  config_name = self.conf_name
  config = self.conf

  # user_name required for given vpn server/config
  user_name = config[:user_name]

  unless config[:autopki] && config[:autopki][:enabled]
    cookbook_file "/etc/openvpn/#{config_name}-#{user_name}-ca.crt" do
      source "#{config_name}-ca.crt"
      owner "root"
      group "openvpn"
      mode 00640
      cookbook config[:file_cookbook] if config[:file_cookbook]
    end

    if (config[:auth][:type] == "cert") or (config[:auth][:type] == "cert_passwd")
      cookbook_file "/etc/openvpn/#{config_name}-#{user_name}.crt" do
        source "#{config_name}-#{user_name}.crt"
        owner "root"
        group "openvpn"
        mode 00640
        cookbook config[:file_cookbook] if config[:file_cookbook]
      end

      cookbook_file "/etc/openvpn/#{config_name}-#{user_name}.key" do
        source "#{config_name}-#{user_name}.key"
        owner "root"
        group "openvpn"
        mode 00600  # not group or others accesible
        cookbook config[:file_cookbook] if config[:file_cookbook]
      end
    end
  end

  cookbook_file "/etc/openvpn/#{config_name}-#{user_name}.conf" do
    source "#{config_name}-#{user_name}.conf"
    owner "root"
    group "openvpn"
    mode 00640
    notifies :restart, "service[openvpn]"
    cookbook config[:file_cookbook] if config[:file_cookbook]
  end
end