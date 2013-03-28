require 'spec_helper'

describe 'openvpn::logrotate' do
  let(:chef_runner) do
    ChefSpec::ChefRunner.new(:cookbook_path => cb_path, :step_into => ['logrotate_app'])
  end

  let(:chef_run) do
    chef_runner.converge 'openvpn::logrotate'
  end

  it 'creates openvpn logrotate config' do
    expect(chef_run).to create_file_with_content "/etc/logrotate.d/openvpn", ""
  end
end
