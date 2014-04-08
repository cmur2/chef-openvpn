class << self; include OpenvpnHelpers; end

directory "/etc/openvpn/autopki" do
  owner 'root'
  group 'root'
end

template "/etc/openvpn/autopki/pkitool" do
  source "pkitool.erb"
  owner 'root'
  group 'root'
  mode  00755
end

openvpn_process :configs, :client_configs do
  config_name = self.conf_name
  config = self.conf

  # Create PKI directory
  # ----
  pki_base = node['openvpn']['autopki']['basedir'] + "/#{config_name}"
  hash_pki = Mash.new(node['openvpn']['autopki']['default'])
  hash_pki.merge!(config[:autopki])

  directory pki_base do
    owner 'root'
    group 'root'
    mode  00755
  end

  file "#{pki_base}/index.txt" do
    owner 'root'
    group 'root'
    mode  00644
    action :touch
  end

  file "#{pki_base}/serial" do
    content "01"
    owner 'root'
    group 'root'
    mode  00644
    action :create_if_missing
  end

  %w(openssl.cnf vars).each do |f|
    template "#{pki_base}/#{f}" do
      variables :config_name => config_name, :config => hash_pki
      source "#{f}.erb"
      owner 'root'
      group 'root'
      mode  00755
    end
  end

  # Upload or generate CA files
  # ----
  if self.conf_type == :server
    base_path = "/etc/openvpn/#{config_name}/#{config_name}"
    ca_base = config_name
  else
    config[:user_name].nil? and raise RuntimeError, "config[:user_name] must be contain the remote side name"
    base_path = "/etc/openvpn/#{config_name}-#{config[:user_name]}"
    ca_base = config[:user_name]
  end

  begin
    %w(ca.crt ca.key).each do |fn|
      ca_file = "#{ca_base}-#{fn}"
      run_context.cookbook_collection[config[:file_cookbook] || cookbook_name].
      preferred_filename_on_disk_location(node, :files, ca_file)
    end

    cookbook_file "#{pki_base}/ca.key"  do
      source "#{ca_base}-ca.key"
      owner 'root'
      group 'root'
      mode  00600
      cookbook config[:file_cookbook] if config[:file_cookbook]
    end

    cookbook_file "#{pki_base}/ca.crt" do
      source "#{ca_base}-ca.crt"
      owner 'root'
      group 'root'
      mode  00644
      cookbook config[:file_cookbook] if config[:file_cookbook]
    end

  # handle automatic generation of CA key and cert
  rescue Chef::Exceptions::FileNotFound => e
    if self.conf_type == :client
      Chef::Log.error "OpenVPN CA key pair can be generated only on server"
      Chef::Log.error "Please include your CA key pair into a client wrapper cookbook"
      raise e
    end

    command = easy_rsa("--initca")
    execute "pkitool --initca" do
      cwd     pki_base
      command command
      not_if  "test -f #{pki_base}/ca.crt"
    end

    file "#{pki_base}/ca.key"  do
      owner 'root' and group 'root' and mode  00600
    end
    file "#{pki_base}/ca.crt" do
      owner 'root' and group 'root' and mode  00644
    end
  end

  # Generate key-pair for client or server using pkitool
  # ----
  str = (self.conf_type == :client) ? "" : "--#{self.conf_type} "
  str << config_name
  command = easy_rsa(str)

  execute "pkitool #{str}" do
    cwd     pki_base
    command command
    not_if  "test -f #{pki_base}/#{config_name}.crt"
  end

  # Link to the given configuration paths
  # ----

  %w(.crt .key).each do |ext|
    link "#{base_path}#{ext}" do
      to "#{pki_base}/#{config_name}#{ext}"
    end
  end
  link "#{base_path}-ca.crt" do
    to "#{pki_base}/ca.crt"
  end
end
