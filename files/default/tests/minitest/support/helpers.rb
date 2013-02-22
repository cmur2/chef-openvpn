module Helpers
  module OpenVPN
    require 'chef/mixin/shell_out'
    include Chef::Mixin::ShellOut
    include MiniTest::Chef::Assertions
    include MiniTest::Chef::Context
    include MiniTest::Chef::Resources

    def config_file(config_name)
      file("/etc/openvpn/#{config_name}.conf")
    end

    def config_dir(config_name)
      directory("/etc/openvpn/#{config_name}")
    end
  end
end
