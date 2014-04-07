module OpenvpnHelpers
  attr_reader :conf, :conf_name, :conf_type

  def openvpn_process(*args, &block)
    return if block.nil?
    if args.any? {|t| ![:configs, :client_configs].include?(t)}
      Chef::Log.error("OpenVPN process_configs wrong arguments: #{args.join(', ')}")
      raise ArgumentError, "list is expected - :configs[, :client_configs]"
    end
    args.each {|a| _process(a, &block)}
  end

  private

  # Process config key with a few attr readers assigned
  def _process(key, &block)
    @conf_type = (key == :configs ? :server : :client)
    node[:openvpn][key].each do |n,c|
      @conf_name = n
      @conf = c
      block.call
    end
  end

  def easy_rsa(cmd)
    %Q(bash -c "source ./vars; #{node['openvpn']['autopki']['basedir']}/pkitool #{cmd}")
  end
end
