control 'check_wireguard_installed' do
  impact 1.0
  title 'Check wireguard installation'

  describe file('/etc/wireguard/wg0.conf') do
    it { should exist }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('mode') { should cmp '0640' }
  end

  describe kernel_parameter('net.ipv4.ip_forward') do
    its('value') { should eq 1 }
  end

  describe interface('wg0') do
    it { should exist }
  end

  describe systemd_service('wg-quick@wg0') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
end

control 'check_wireguard_exporter' do
  impact 1.0
  title 'Check wireguard exporter'

  describe file('/etc/wireguard/users.csv') do
    it { should exist }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('mode') { should cmp '0640' }
  end

  describe file('/usr/local/sbin/wireguard_exporter') do
    it { should be_symlink }
  end

  describe systemd_service('wireguard_exporter') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end

  describe port(9586) do
    it { should be_listening }
  end
end
