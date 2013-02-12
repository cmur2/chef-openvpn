
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
  mode 00755
end

# setup each client_config
configurtions = node[:openvpn][:client_configs]
configurtions.each do |config_name,config|

  cookbook_file "/etc/openvpn/#{config_name}-#{user_name}-ca.crt" do
    source "#{config_name}-ca.crt"
    owner "root"
    group "openvpn"
    mode 00660
  end

  if (config[:auth][:type] == "cert") or (config[:auth][:type] == "cert_passwd")
    cookbook_file "/etc/openvpn/#{config_name}-#{user_name}.crt" do
      source "#{config_name}-#{user_name}.crt"
      owner "root"
      group "openvpn"
      mode 00660
    end

    cookbook_file "/etc/openvpn/#{config_name}-#{user_name}.key" do
      source "#{config_name}-#{user_name}.key"
      owner "root"
      group "openvpn"
      mode 00660
    end
  end

  cookbook_file "/etc/openvpn/#{config_name}-#{user_name}.conf" do
    source "#{config_name}-#{user_name}.conf"
    owner "root"
    group "openvpn"
    mode 00660
  end
end

service "openvpn" do
  action [:enable, :start]
end
