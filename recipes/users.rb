
# setup each config
configurtions = node[:openvpn][:configs]
configurtions.each do |config_name,config|

  directory "/etc/openvpn/#{config_name}/users" do
    owner "root"
    group "openvpn"
    mode 00750
  end

  users_databag_name = "#{config_name}-users".gsub(/\./, '_')
  data_bag(users_databag_name).each do |item|
    user = data_bag_item(users_databag_name, item)
    # use name property if given, else fall back to id
    user_name = user['name'] ? user['name'] : user['id']

    cookbook_file "/etc/openvpn/#{config_name}/users/#{config_name}-#{user_name}-ca.crt" do
      source "#{config_name}-ca.crt"
      owner "root"
      group "openvpn"
      mode 00640
      cookbook config[:file_cookbook] if config[:file_cookbook]
    end

    if config[:auth][:type] == "cert" || config[:auth][:type] == "cert_passwd"
      cookbook_file "/etc/openvpn/#{config_name}/users/#{config_name}-#{user_name}.crt" do
        source "#{config_name}-#{user_name}.crt"
        owner "root"
        group "openvpn"
        mode 00640
        cookbook config[:file_cookbook] if config[:file_cookbook]
      end

      cookbook_file "/etc/openvpn/#{config_name}/users/#{config_name}-#{user_name}.key" do
        source "#{config_name}-#{user_name}.key"
        owner "root"
        group "openvpn"
        mode 00600 # not group or others accesible
        cookbook config[:file_cookbook] if config[:file_cookbook]
      end
    end

    template "/etc/openvpn/#{config_name}/users/#{config_name}-#{user_name}.conf" do
      source "client.conf.erb"
      variables :config_name => config_name, :config => config, :user_name => user_name
      owner "root"
      group "openvpn"
      mode 00640
    end
  end
end
