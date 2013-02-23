require File.expand_path('../support/helpers', __FILE__)

describe 'openvpn::default' do
  include Helpers::OpenVPN

  it 'installs openvpn' do
    package('openvpn').must_be_installed
  end

  it 'creates openvpn user and group' do
    user('openvpn').must_exist
    group('openvpn').must_exist
  end

  it 'creates log directory' do
    directory('/var/log/openvpn').must_exist
  end

  it 'starts openvpn service per configuration' do
    service('openvpn').must_be_running
  end

  it 'enables openvpn service' do
    service('openvpn').must_be_enabled
  end

  it 'creates .conf file per configuration' do
    configs.each do |config_name|
      config_file(config_name).must_exist
    end
  end

  it 'creates conf directory per configuration' do
    configs.each do |config_name|
      config_dir(config_name).must_exist
    end
  end

  it 'creates necessary cert/key files per configuration' do
    configs.each do |config_name|
      config_sub_file(config_name, "#{config_name}-dh.pem")
      config_sub_file(config_name, "#{config_name}-ca.crt")
      config_sub_file(config_name, "#{config_name}.crt")
      config_sub_file(config_name, "#{config_name}.key")
    end
  end

  it 'creates authentication script if needed' do
    config_sub_file('test1', 'auth.rb')
    config_sub_file('test2', 'auth.rb')
  end
end
