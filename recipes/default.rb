
# TODO: pushing routes
# TODO: cert files as cookbook files
# TODO: better client configs

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

include_recipe "openvpn::autopki"
include_recipe "openvpn::config"
include_recipe "openvpn::populate_ccd"

service "openvpn" do
  action [:enable, :start]
end
