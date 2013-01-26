
# TODO: pushing routes
# TODO: cert files as cookbook files
# TODO: better client configs

package "openvpn" do
  action :upgrade
end

# create openvpn user and group
user "openvpn"
group "openvpn" do
  members ["openvpn"]
end

directory "/var/log/openvpn" do
  owner "root"
  group "root"
  mode 0755
end

# setup each config
configurtions = node[:openvpn][:configs]
configurtions.each do |config_name,config|

  if config[:mode] == "routed" and config[:subnet6] and not config[:subnet]
    raise "OpenVPN configuration '#{config_name}': You need to specify an IPv4 subnet too when using an IPv6 subnet!"
  end

  directory "/etc/openvpn/#{config_name}" do
    owner "root"
    group "openvpn"
    mode 0770
  end

  cookbook_file "/etc/openvpn/#{config_name}/#{config_name}-dh.pem" do
    source "#{config_name}-dh.pem"
    owner "root"
    group "openvpn"
    mode 0660
  end

  cookbook_file "/etc/openvpn/#{config_name}/#{config_name}-ca.crt" do
    source "#{config_name}-ca.crt"
    owner "root"
    group "openvpn"
    mode 0660
  end

  cookbook_file "/etc/openvpn/#{config_name}/#{config_name}.crt" do
    source "#{config_name}.crt"
    owner "root"
    group "openvpn"
    mode 0660
  end

  cookbook_file "/etc/openvpn/#{config_name}/#{config_name}.key" do
    source "#{config_name}.key"
    owner "root"
    group "openvpn"
    mode 0600 # not group or others accesible
  end

  if (config[:auth][:type] == "cert_passwd") or (config[:auth][:type] == "passwd")
    # read users from data bag
    users = {}
    users_databag_name = "#{config_name}-users".gsub(/\./, '_')
    data_bag(users_databag_name).each do |item|
      user = data_bag_item(users_databag_name, item)
      users[user['id']] = user['pass']
    end

    template "/etc/openvpn/#{config_name}/auth.rb" do
      source "auth.rb.erb"
      variables :users => users
      owner "root"
      group "openvpn"
      mode 0770
    end
  end

  template "/etc/openvpn/#{config_name}.conf" do
    source "server.conf.erb"
    variables :config_name => config_name, :config => config
    owner "root"
    group "openvpn"
    mode 0660
    notifies :restart, "service[openvpn]"
  end
end

service "openvpn" do
  action [:enable, :start]
end
