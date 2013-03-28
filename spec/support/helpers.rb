
def configs
  ["test1", "test2", "test3"]
end

def config_file(config_name)
  "/etc/openvpn/#{config_name}.conf"
end

def config_dir(config_name)
  "/etc/openvpn/#{config_name}"
end

def config_sub_file(config_name, sub_file)
  "/etc/openvpn/#{config_name}/#{sub_file}"
end

def client_configs
  ["test11", "test12", "test13"]
end
