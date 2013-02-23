module Helpers
  module OpenVPN
    require 'chef/mixin/shell_out'
    include Chef::Mixin::ShellOut
    include MiniTest::Chef::Assertions
    include MiniTest::Chef::Context
    include MiniTest::Chef::Resources

    def configs
      ['test1', 'test2', 'test3']
    end

    def config_file(config_name)
      file("/etc/openvpn/#{config_name}.conf")
    end

    def config_dir(config_name)
      directory("/etc/openvpn/#{config_name}")
    end

    def config_sub_file(config_name, sub_file)
      file("/etc/openvpn/#{config_name}/#{sub_file}")
    end
  end
end
