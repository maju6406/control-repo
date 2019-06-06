# @summary This profile installs unzip and git as part of the Windows baseline
class profile::windows_baseline {

  include chocolatey
  # PACKAGES
  Package {
    ensure   => installed,
    provider => chocolatey,
  }

  package { 'unzip': }
  package { 'Firefox': }
  package { 'git': }

  # FIREWALL
  windows_firewall::exception { 'TSErule':
    ensure       => present,
    direction    => 'in',
    action       => 'allow',
    enabled      => true,
    protocol     => 'TCP',
    local_port   => 8080,
    display_name => 'TSE PUPPET DEMO',
    description  => 'Inbound rule example for demo purposes',
  }

  # REG KEYS
  registry_key { 'HKEY_LOCAL_MACHINE\Software\Demonstration':
    ensure       => present,
    purge_values => true,
  }
  registry_value { 'HKEY_LOCAL_MACHINE\Software\Demonstration\value1':
    type => string,
    data => 'this is a value new from puppet intro',
  }
  registry_value { 'HKEY_LOCAL_MACHINE\Software\Demonstration\value2':
    type => dword,
    data => '0xFFFFFFFF',
  }

  # WINNTP
  class { 'winntp':
    servers => ['time.nist.gov', 'pool.ntp.org'],
  }
    # disable auto updating so machine doesnt start downloading / updating
    registry::value { 'disable updates':
      key   => 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU',
      value => 'NoAutoUpdate',
      data  => '1',
      type  => 'dword',
    }

    # Get WMF
    package { 'powershell':
      ensure   => latest,
      #install_options => ['-pre','--ignore-package-exit-codes'],
      provider => chocolatey,
    }

    reboot {'dsc_install':
      subscribe => Package['powershell'],
      apply     => 'immediately',
      timeout   => 0,
    }

  registry::value { 'enable insecure winrm':
    key    => 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service',
    value  => 'AllowUnencryptedTraffic',
    data   => '1',
    type   => 'dword',
    notify => Service['WinRM'],
  }

  service {'WinRM':
    ensure => 'running',
    enable => true,
  }

}
