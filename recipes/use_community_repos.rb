
flavor = node[:openvpn][:community_repo_flavor]

case node[:platform]
when "debian"
  case node[:platform_version].to_i
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
  when 7
    apt_repository "openvpn-wheezy" do
      uri "http://swupdate.openvpn.net/repos/apt/wheezy-#{flavor}"
      components ["wheezy", "main"]
      key "http://swupdate.openvpn.net/repos/repo-public.gpg"
    end
  end
when "ubuntu"
  case node[:platform_version]
  when "10.04", "10.10", "11.04", "11.10"
    apt_repository "openvpn-lucid" do
      uri "http://repos.openvpn.net/repos/apt/lucid-#{flavor}"
      components ["lucid", "main"]
      key "http://repos.openvpn.net/repos/repo-public.gpg"
    end
  when "12.04"
    apt_repository "openvpn-precise" do
      uri "http://swupdate.openvpn.net/repos/apt/precise-#{flavor}"
      components ["precise", "main"]
      key "http://swupdate.openvpn.net/repos/repo-public.gpg"
    end
  when "12.10"
    apt_repository "openvpn-quantal" do
      uri "http://swupdate.openvpn.net/repos/apt/quantal-#{flavor}"
      components ["quantal", "main"]
      key "http://swupdate.openvpn.net/repos/repo-public.gpg"
    end
  when "13.04"
    apt_repository "openvpn-raring" do
      uri "http://swupdate.openvpn.net/repos/apt/raring-#{flavor}"
      components ["raring", "main"]
      key "http://swupdate.openvpn.net/repos/repo-public.gpg"
    end
  end
end
