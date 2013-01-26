
# setup each config
configurtions = node[:openvpn][:configs]
configurtions.each do |config_name,config|

  directory "/etc/openvpn/#{config_name}/users" do
    owner "root"
    group "openvpn"
    mode 0770
  end

  users_databag_name = "#{config_name}-users".gsub(/\./, '_')
  data_bag(users_databag_name).each do |item|
    user = data_bag_item(users_databag_name, item)
    user_name = user['id']

    cookbook_file "/etc/openvpn/#{config_name}/users/#{config_name}-#{user_name}-ca.crt" do
      content "#{config_name}-ca.crt"
      owner "root"
      group "openvpn"
      mode 0660
    end

    if (config[:auth][:type] == "cert") or (config[:auth][:type] == "cert_passwd")
      file "/etc/openvpn/#{config_name}/users/#{config_name}-#{user_name}.crt" do
        content user['cert']
        owner "root"
        group "openvpn"
        mode 0660
      end

      file "/etc/openvpn/#{config_name}/users/#{config_name}-#{user_name}.key" do
        content user['key']
        owner "root"
        group "openvpn"
        mode 0660
      end
    end

    template "/etc/openvpn/#{config_name}/users/#{config_name}-#{user_name}.conf" do
      source "client.conf.erb"
      variables :config_name => config_name, :config => config, :user_name => user_name
      owner "root"
      group "openvpn"
      mode 0660
    end
  end
end
