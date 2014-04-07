class << self; include OpenvpnHelpers; end

# Process server configurations
openvpn_process :configs do
  set_default_script_security

  config_name = self.conf_name
  config = self.conf

  if config[:use_client_connect]
    script_erb = config[:client_connect_script] || "client-connect.sh.erb"

    template "/etc/openvpn/#{config_name}/client-connect.sh" do
      source script_erb
      owner 'root'
      group 'root'
      mode  00755
      variables(:config_name => config_name, :config => config)
      cookbook config[:file_cookbook] if config[:file_cookbook]
    end
  end
end
