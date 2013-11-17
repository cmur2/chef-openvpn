require 'spec_helper'

describe 'openvpn::use_community_repos' do
  let(:chef_runner) do
    ChefSpec::ChefRunner.new(:cookbook_path => cb_path, :step_into => ['apt_repository'])
  end

  let(:chef_run) do
    chef_runner.converge 'apt', 'openvpn::use_community_repos'
  end

  {
    '5.0.0' => 'openvpn-lenny',
    '6.0.0' => 'openvpn-squeeze',
    '7.0.0' => 'openvpn-wheezy'
  }.each do |version, repo|
    context "on Debian #{version}" do
      it "creates #{repo} list" do
        chef_runner.node.automatic_attrs['platform'] = 'debian'
        chef_runner.node.automatic_attrs['platform_version'] = version
        chef_run = chef_runner.converge 'apt', 'openvpn::use_community_repos'
        expect(chef_run).to create_file "/etc/apt/sources.list.d/#{repo}.list"
      end
    end
  end
  
  {
    '10.04' => 'openvpn-lucid',
    '10.10' => 'openvpn-lucid',
    '11.04' => 'openvpn-lucid',
    '11.10' => 'openvpn-lucid',
    '12.04' => 'openvpn-precise',
    '13.04' => 'openvpn-raring',
    '13.10' => 'openvpn-saucy'
  }.each do |version, repo|
    context "on Ubuntu #{version}" do
      it "creates #{repo} list" do
        chef_runner.node.automatic_attrs['platform'] = 'ubuntu'
        chef_runner.node.automatic_attrs['platform_version'] = version
        chef_run = chef_runner.converge 'apt', 'openvpn::use_community_repos'
        expect(chef_run).to create_file "/etc/apt/sources.list.d/#{repo}.list"
      end
    end
  end
end
