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

  it 'creates .conf file per configuration' do
    config_file('test1').must_exist
  end

  it 'creates conf directory per configuration' do
    config_dir('test1').must_exist
  end

  it 'starts openvpn service per configuration' do
    service('openvpn').must_be_running
  end

  it 'enables openvpn service' do
    service('openvpn').must_be_enabled
  end
end
