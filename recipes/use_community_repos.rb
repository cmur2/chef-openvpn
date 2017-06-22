
flavor = node[:openvpn][:community_repo_flavor]

case node[:platform]
when "debian"
  case node[:platform_version].to_i
  when 7
    apt_repository "openvpn-wheezy" do
      uri "http://build.openvpn.net/debian/openvpn/release/2.3"
      components ["wheezy", "main"]
      key "https://swupdate.openvpn.net/repos/repo-public.gpg"
    end
  when 8
    apt_repository "openvpn-jessie" do
      uri "http://build.openvpn.net/debian/openvpn/release/2.3"
      components ["jessie", "main"]
      key "https://swupdate.openvpn.net/repos/repo-public.gpg"
    end
  end
when "ubuntu"
  case node[:platform_version]
  when "12.04"
    apt_repository "openvpn-precise" do
      uri "http://build.openvpn.net/debian/openvpn/release/2.3"
      components ["precise", "main"]
      key "https://swupdate.openvpn.net/repos/repo-public.gpg"
    end
  when "14.04"
    apt_repository "openvpn-trusty" do
      uri "http://build.openvpn.net/debian/openvpn/release/2.3"
      components ["trusty", "main"]
      key "https://swupdate.openvpn.net/repos/repo-public.gpg"
    end
  when "16.04"
    apt_repository "openvpn-xenial" do
      uri "http://build.openvpn.net/debian/openvpn/release/2.3"
      components ["xenial", "main"]
      key "https://swupdate.openvpn.net/repos/repo-public.gpg"
    end
  end
end
