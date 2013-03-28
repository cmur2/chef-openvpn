require 'spec_helper'

describe 'openvpn::default' do
  let(:chef_runner) do
    runner = ChefSpec::ChefRunner.new(:cookbook_path => cb_path)
    runner.node.set['openvpn']['configs'] = configs
    runner
  end

  let(:chef_run) do
    chef_runner.converge 'openvpn::default'
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
  
  configs.keys.each do |config_name|
    context "for config #{config_name}" do
      it 'creates .conf file' do
        expect(chef_run).to create_file_with_content config_file(config_name), ""
      end
      
      it 'creates conf directory' do
        expect(chef_run).to create_directory config_dir(config_name)
      end
      
      it 'creates necessary cert/key files' do
        expect(chef_run).to create_file_with_content config_sub_file(config_name, "#{config_name}-dh.pem"), ""
        expect(chef_run).to create_file_with_content config_sub_file(config_name, "#{config_name}-ca.crt"), ""
        expect(chef_run).to create_file_with_content config_sub_file(config_name, "#{config_name}.crt"), ""
        expect(chef_run).to create_file_with_content config_sub_file(config_name, "#{config_name}.key"), ""
      end
      
      it 'creates authentication script if needed' do
        expect(chef_run).to create_file_with_content config_sub_file(config_name, 'auth.rb'), "" if config_name != "test3"
      end
    end
  end
end
