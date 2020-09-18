directory '/opt/wireguard_exporter' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

unless File.exist?("/opt/wireguard_exporter/#{node['valkyrie']['wireguard_exporter']['version']}")
  remote_file 'wireguard_exporter' do
    path "#{Chef::Config[:file_cache_path]}/wireguard_exporter.tar.gz"
    owner 'root'
    group 'root'
    mode '0644'
    source "https://github.com/terrycain/wireguard_exporter/releases/download/v#{node['valkyrie']['wireguard_exporter']['version']}/wireguard_exporter-#{node['valkyrie']['wireguard_exporter']['version']}.linux-amd64.tar.gz"
    checksum node['valkyrie']['wireguard_exporter']['checksum']
  end

  archive_file 'wireguard_exporter' do
    path "#{Chef::Config[:file_cache_path]}/wireguard_exporter.tar.gz"
    destination '/tmp/wireguard_exporter'
  end

  remote_file "/opt/wireguard_exporter/#{node['valkyrie']['wireguard_exporter']['version']}" do
    source "file:///tmp/wireguard_exporter/wireguard_exporter-#{node['valkyrie']['wireguard_exporter']['version']}.linux-amd64/wireguard_exporter"
    owner 'root'
    group 'root'
    mode '0755'
  end

  directory '/tmp/wireguard_exporter' do
    recursive true
    action :delete
  end

  file "#{Chef::Config[:file_cache_path]}/wireguard_exporter.tar.gz" do
    action :delete
  end
end

link '/usr/local/sbin/wireguard_exporter' do
  to "/opt/wireguard_exporter/#{node['valkyrie']['wireguard_exporter']['version']}"
  notifies :restart, 'service[wireguard_exporter]'
end

options = [
  '--wireguard.friendly-name-file=/etc/wireguard/users.csv',
]

systemd_unit 'wireguard_exporter.service' do
  content(
    Unit: {
      Description: 'Prometheus exporter for wireguard metrics',
      Documentation: 'https://github.com/terrycain/wireguard_exporter',
      After: 'network.target',
    },
    Service: {
      Restart: 'always',
      User: 'root',
      Group: 'root',
      ExecStart: "/usr/local/sbin/wireguard_exporter #{options.join(" \\\n")}",
      WorkingDirectory: '/',
      RestartSec: '30s',
    },
    Install: {
      WantedBy: 'multi-user.target',
    }
  )
  action [:create, :enable]
  notifies :restart, 'service[wireguard_exporter]'
end

service 'wireguard_exporter' do
  action :nothing
end
