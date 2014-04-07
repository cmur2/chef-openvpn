configurtions = node[:openvpn][:configs]
configurtions.each do |config_name,config|
  # don't manage ccd directory, since we are using client connect script
  next if config[:use_client_connect]

  # try to find client config information in data bag
  users_databag_name = "#{config_name}-users".gsub(/\./, '_')
  data_bag(users_databag_name).each do |item_name|
    user = data_bag_item(users_databag_name, item_name)
    # use name property if given, else fall back to id
    user_name = user['name'] ? user['name'] : user['id']
    
    lines = []

    lines << "ifconfig-push #{user['ifconfig-push']}" if user.key? 'ifconfig-push'

    if user.key? 'push'
      if user['push'].is_a? Array
        user['push'].each do |directive| lines << "push #{directive}" end
      else
        lines << "push #{user['push'].to_s}"
      end
    end

    lines << "push-reset" if user['push-reset']

    if user.key? 'iroute'
      if user['iroute'].is_a? Array
        user['iroute'].each do |rotue| lines << "iroute #{route}" end
      else
        lines << "iroute #{user['iroute'].to_s}"
      end
    end
    
    # force trailing newline
    lines << ''
    
    file "/etc/openvpn/#{config_name}/ccd/#{user_name}" do
      content lines.join("\n")
      owner "root"
      group "openvpn"
      mode 00640
      notifies :restart, "service[openvpn]"
      only_if { lines.size > 1 }
    end
  end
end
