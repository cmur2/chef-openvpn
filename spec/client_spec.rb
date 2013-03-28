require 'spec_helper'

describe 'openvpn::client' do
  let(:chef_runner) do
    cb_path = [Pathname.new(File.join(File.dirname(__FILE__), '..', '..')).cleanpath.to_s, 'spec/support/cookbooks', 'spec/support/my-cookbooks']
    runner = ChefSpec::ChefRunner.new(:cookbook_path => cb_path)
    runner.node.set['openvpn']['client_configs'] = {
      'test11' => {
        :user_name => 'foo',
        :auth => {
          :type => 'passwd'
        },
        :file_cookbook => 'openvpn-files'
      },
      'test12' => {
        :user_name => 'foo',
        :auth => {
          :type => 'cert_passwd'
        },
        :file_cookbook => 'openvpn-files'
      },
      'test13' => {
        :user_name => 'foo',
        :auth => {
          :type => 'cert'
        },
        :file_cookbook => 'openvpn-files'
      }
    }
    runner
  end
  
  let(:chef_run) do
    chef_runner.converge 'openvpn::client'
  end
  
  before do
    Chef::Config[:data_bag_path] = 'spec/support/data_bags'
  end
  
  it 'installs openvpn' do
    expect(chef_run).to install_package 'openvpn'
  end

  it 'creates openvpn user and group' do
    expect(chef_run).to create_user 'openvpn'
    expect(chef_run).to create_group 'openvpn'
  end

  it 'creates log directory' do
    expect(chef_run).to create_directory '/var/log/openvpn'
  end

  it 'enables and starts openvpn' do
    expect(chef_run).to start_service 'openvpn'
    expect(chef_run).to set_service_to_start_on_boot 'openvpn'
  end

  client_configs.each do |config_name|
    context "for config #{config_name}" do
      it 'creates .conf file' do
        expect(chef_run).to create_file_with_content "/etc/openvpn/#{config_name}-foo.conf", ""
      end
      
      it 'creates necessary cert/key files' do
        if config_name == 'test12' or config_name == 'test13'
          expect(chef_run).to create_file_with_content "/etc/openvpn/#{config_name}-foo-ca.crt", ""
          expect(chef_run).to create_file_with_content "/etc/openvpn/#{config_name}-foo.crt", ""
          expect(chef_run).to create_file_with_content "/etc/openvpn/#{config_name}-foo.key", ""
        end
      end
    end
  end
end
