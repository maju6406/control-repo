# @summary This role installs a sample website
class role::webserver {

  case $::kernel {
    'windows': {  
      include profile::windows_baseline
      include profile::iis
      include profile::sample_website    
    }
    'Linux':   {   
      include profile::linux_baseline
      include profile::apache
      include profile::sample_website
    }
    default:   {
      include profile::linux_baseline
      include profile::apache
      include profile::sample_website    
    }
  }

}
