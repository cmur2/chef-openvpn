
flavor = node[:openvpn][:community_repo_flavor]

case node.platform
when "debian"
  case node.platform_version.to_i
  when 5
    apt_repository "openvpn-lenny" do
      uri "http://repos.openvpn.net/repos/apt/lenny-#{flavor}"
      components ["lenny", "main"]
      key "http://repos.openvpn.net/repos/repo-public.gpg"
    end
  when 6
    apt_repository "openvpn-squeeze" do
      uri "http://repos.openvpn.net/repos/apt/squeeze-#{flavor}"
      components ["squeeze", "main"]
      key "http://repos.openvpn.net/repos/repo-public.gpg"
    end
  end
when "ubuntu"
  case node.platform_version
  when "10.04", "10.10", "11.04", "11.10"
    apt_repository "openvpn-lucid" do
      uri "http://repos.openvpn.net/repos/apt/lucid-#{flavor}"
      components ["lucid", "main"]
      key "http://repos.openvpn.net/repos/repo-public.gpg"
    end
  when "12.04"
    # No stable releases available for 12.04!
    apt_repository "openvpn-precise" do
      uri "http://repos.openvpn.net/repos/apt/precise-snapshots"
      components ["precise", "main"]
      key "http://repos.openvpn.net/repos/repo-public.gpg"
    end
  end
end
