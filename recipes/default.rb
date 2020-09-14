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
    users: node['valkyrie']['users'],
  )
  sensitive true
  notifies :restart, 'systemd_unit[wg-quick@wg0]'
end

systemd_unit 'wg-quick@wg0' do
  action [:enable, :start]
end

directory '/etc/wireguard/users'

node['valkyrie']['users'].each do |i|
  template "/etc/wireguard/users/#{i['name']}.conf" do
    source 'user.conf.erb'
    variables(
      private: i['private'],
      address: i['ip'],
      srv_public: node['valkyrie']['server_pub_key'],
      srv_endpoint: node['valkyrie']['server_fqdn'],
      srv_port: node['valkyrie']['server_port'],
    )
    sensitive true
  end
end
