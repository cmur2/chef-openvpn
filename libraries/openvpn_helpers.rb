module OpenvpnHelpers
  attr_reader :conf, :conf_name, :conf_type, :conf_key

  def openvpn_process(*args, &block)
    return if block.nil?
    if args.any? {|t| ![:configs, :client_configs].include?(t)}
      Chef::Log.error("OpenVPN process_configs wrong arguments: #{args.join(', ')}")
      raise ArgumentError, "list is expected - :configs[, :client_configs]"
    end
    args.each {|a| _process(a, &block)}
  end

  def set_default_script_security
    if using_scripts?
      ss = node['openvpn'][self.conf_key][self.conf_name][:script_security]
      node.default['openvpn'][self.conf_key][self.conf_name][:script_security] = 2 unless ss
    end
  end

  private

  # Process config key with a few attr readers assigned
  def _process(key, &block)
    @conf_type = (key == :configs ? :server : :client)
    @conf_key  = key
    node[:openvpn][key].each do |n,c|
      @conf_name = n
      @conf = c
      block.call
    end
  end

  def easy_rsa(cmd)
    %Q(bash -c "source ./vars; #{node['openvpn']['autopki']['basedir']}/pkitool #{cmd}")
  end

  def using_scripts?
    config = self.conf
    use = config[:auth][:type] == "cert_passwd" || config[:auth][:type] == "passwd"
    use = use || config[:use_client_connect] || config[:use_route_up]
  end
end
