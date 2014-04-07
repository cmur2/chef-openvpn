
# TODO: pushing routes
# TODO: cert files as cookbook files
# TODO: better client configs

include_recipe "openvpn::common"
include_recipe "openvpn::config"

service "openvpn" do
  action [:enable, :start]
end
