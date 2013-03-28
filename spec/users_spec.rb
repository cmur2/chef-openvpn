require 'spec_helper'

describe 'openvpn::users' do
  let(:chef_runner) do
    runner = ChefSpec::ChefRunner.new(:cookbook_path => cb_path)
    runner.node.set['openvpn']['configs'] = {
      'test1' => {
        :port => 1194,
        :proto => 'udp',
        :dev => 'tun',
        :mode => 'routed',
        :remote_host => 'localhost',
        :subnet => '10.8.0.0',
        :netmask => '255.255.255.0',
        :auth => {
          :type => 'passwd'
        },
        :file_cookbook => 'openvpn-files'
      },
      'test2' => {
        :port => 1195,
        :proto => 'udp',
        :dev => 'tun',
        :mode => 'routed',
        :remote_host => 'localhost',
        :subnet => '10.9.0.0',
        :netmask => '255.255.255.0',
        :auth => {
          :type => 'cert_passwd'
        },
        :file_cookbook => 'openvpn-files'
      },
      'test3' => {
        :port => 1196,
        :proto => 'udp',
        :dev => 'tun',
        :mode => 'routed',
        :remote_host => 'localhost',
        :subnet => '10.10.0.0',
        :netmask => '255.255.255.0',
        :auth => {
          :type => 'cert'
        },
        :file_cookbook => 'openvpn-files'
      }
    }
    runner
  end

  let(:chef_run) do
    chef_runner.converge 'openvpn::users'
  end
  
  before do
    Chef::Config[:data_bag_path] = 'spec/support/data_bags'
  end
  
  configs.each do |config_name|
    context "for config #{config_name}" do
      it 'creates users directory' do
        expect(chef_run).to create_directory "/etc/openvpn/#{config_name}/users"
      end
      
      it 'creates .conf file' do
        expect(chef_run).to create_file_with_content config_sub_file(config_name, "users/#{config_name}-foo.conf"), ""
      end
      
      it 'creates necessary cert/key files if needed' do
        if config_name == 'test2' or config_name == 'test3'
          expect(chef_run).to create_file_with_content config_sub_file(config_name, "users/#{config_name}-foo.crt"), ""
          expect(chef_run).to create_file_with_content config_sub_file(config_name, "users/#{config_name}-foo.key"), ""
        end
      end
    end
  end
end
