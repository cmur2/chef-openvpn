
include_recipe "openvpn::common"
include_recipe "openvpn::config_client"
include_recipe "openvpn::autopki"

service "openvpn" do
  action [:enable, :start, :reload]
  reload_command "/etc/init.d/openvpn soft-restart"
end
