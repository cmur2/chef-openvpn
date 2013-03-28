require 'spec_helper'

describe 'openvpn::users' do
  let(:chef_runner) do
    runner = ChefSpec::ChefRunner.new(:cookbook_path => cb_path)
    runner.node.set['openvpn']['configs'] = configs
    runner
  end

  let(:chef_run) do
    chef_runner.converge 'openvpn::users'
  end
  
  before do
    Chef::Config[:data_bag_path] = 'spec/support/data_bags'
  end
  
  configs.keys.each do |config_name|
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
