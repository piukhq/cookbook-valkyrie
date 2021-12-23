apt_update

package 'wireguard'

execute 'reload_sysctl' do
  command 'sysctl --system'
  action :nothing
end

file '/etc/sysctl.d/99-wireguard.conf' do
  content "net.ipv4.ip_forward = 1\n"
  notifies :run, 'execute[reload_sysctl]', :immediately
end

template '/etc/wireguard/wg0.conf' do
  source 'wg0.conf.erb'
  variables(
    server_private_key: node['valkyrie']['server_pri_key'],
    users: node['valkyrie']['users']
  )
  owner 'root'
  group 'root'
  mode '0640'
  sensitive true
  notifies :restart, 'systemd_unit[wg-quick@wg0]'
end

template '/etc/wireguard/users.csv' do
  source 'users.csv.erb'
  variables(
    users: node['valkyrie']['users']
  )
  owner 'root'
  group 'root'
  mode '0640'
  sensitive true
end

systemd_unit 'wg-quick@wg0' do
  action [:enable, :start]
end

apt_update 'cifs-utils'

directory '/mount/binkuksouthwireguard'
directory '/mount/binkuksouthwireguard/users'

systemd_unit 'mount-binkuksouthwireguard-users.mount' do
  content(
    Mount: {
      What: '//binkuksouthwireguard.file.core.windows.net/users',
      Where: '/mount/binkuksouthwireguard/users',
      Options: 'username=binkuksouthwireguard,password=Tn4R5RcvTK/NZnV80XhWwCJQc4aNukFAyYL7SVM73wFKoCzFIATdElBNnO/76FQ4zUjs4aZBQjHrQTCnPyf2UA==,file_mode=0644,serverino',
      Type: 'cifs',
    }
  )
  action :create
end

systemd_unit 'mount-binkuksouthwireguard-users.automount' do
  content(
    Unit: {
      Requires: 'remote-fs-pre.target',
      After: 'remote-fs-pre.target',
    },
    Install: {
      WantedBy: 'remote-fs.target',
    }
  )
  action [:create, :enable, :start]
end

node['valkyrie']['users'].each do |i|
  template "/mount/binkuksouthwireguard/users/#{i['name']}.conf" do
    source 'user.conf.erb'
    variables(
      private: i['private'],
      address: i['ip'],
      srv_public: node['valkyrie']['server_pub_key'],
      srv_endpoint: node['valkyrie']['server_fqdn'],
      srv_port: node['valkyrie']['server_port']
    )
    owner 'root'
    group 'root'
    mode '0644'
    sensitive true
  end
end

# Remove legacy wireguard_users directory
directory '/etc/wireguard_users' do
  recursive true
  action :delete
end

include_recipe 'valkyrie::exporter'
