
# setup each config
configurtions = node[:openvpn][:configs]
configurtions.each do |config_name,config|
  # setting ccd to enabled by default
  if config[:mode] == "routed" and config[:subnet6] and not config[:subnet]
    raise "OpenVPN configuration '#{config_name}': You need to specify an IPv4 subnet too when using an IPv6 subnet!"
  end

  directory "/etc/openvpn/#{config_name}" do
    owner "root"
    group "openvpn"
    mode 00770
  end
  
  # client-config-directory
  directory "/etc/openvpn/#{config_name}/ccd" do
    owner "root"
    group "openvpn"
    mode 00770
  end

  if config[:dh_keysize]
    unless ::File.exists?("/etc/openvpn/#{config_name}/#{config_name}-dh.pem")
      require 'openssl'
      file "/etc/openvpn/#{config_name}/#{config_name}-dh.pem" do
        content OpenSSL::PKey::DH.new(config[:dh_keysize]).to_s
        owner "root"
        group "openvpn"
        mode 00640
      end
    end
  else
    cookbook_file "/etc/openvpn/#{config_name}/#{config_name}-dh.pem" do
      source "#{config_name}-dh.pem"
      owner "root"
      group "openvpn"
      mode 00640
      cookbook config[:file_cookbook] if config[:file_cookbook]
    end
  end

  # Don't generate key and certificate files if autopki is enabled
  unless config[:autopki] && config[:autopki][:enabled]
    cookbook_file "/etc/openvpn/#{config_name}/#{config_name}-ca.crt" do
      source "#{config_name}-ca.crt"
      owner "root"
      group "openvpn"
      mode 00640
      cookbook config[:file_cookbook] if config[:file_cookbook]
    end

    cookbook_file "/etc/openvpn/#{config_name}/#{config_name}.crt" do
      source "#{config_name}.crt"
      owner "root"
      group "openvpn"
      mode 00640
      cookbook config[:file_cookbook] if config[:file_cookbook]
    end

    cookbook_file "/etc/openvpn/#{config_name}/#{config_name}.key" do
      source "#{config_name}.key"
      owner "root"
      group "openvpn"
      mode 00600 # not group or others accesible
      cookbook config[:file_cookbook] if config[:file_cookbook]
    end
  end

  if (config[:auth][:type] == "cert_passwd") or (config[:auth][:type] == "passwd")
    # read users from data bag
    users = {}
    users_databag_name = "#{config_name}-users".gsub(/\./, '_')
    data_bag(users_databag_name).each do |item_name|
      user = data_bag_item(users_databag_name, item_name)
      # use name property if given, else fall back to id
      user_name = user['name'] ? user['name'] : user['id']
      users[user_name] = user['pass']
    end

    template "/etc/openvpn/#{config_name}/auth.rb" do
      source "auth.rb.erb"
      variables :users => users
      owner "root"
      group "openvpn"
      mode 00750
    end
  end

  template "/etc/openvpn/#{config_name}.conf" do
    source "server.conf.erb"
    variables :config_name => config_name, :config => config
    owner "root"
    group "openvpn"
    mode 00640
    notifies :restart, "service[openvpn]"
  end
end
