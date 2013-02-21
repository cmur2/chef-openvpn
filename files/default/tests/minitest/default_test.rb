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
end
