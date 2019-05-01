require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
require 'simplecov'
require 'simplecov-console'

include RspecPuppetFacts

default_facts = {
  puppetversion: Puppet.version,
  facterversion: Facter.version,
}

default_fact_files = [
  File.expand_path(File.join(File.dirname(__FILE__), 'default_facts.yml')),
  File.expand_path(File.join(File.dirname(__FILE__), 'default_module_facts.yml')),
]

default_fact_files.each do |f|
  next unless File.exist?(f) && File.readable?(f) && File.size?(f)

  begin
    default_facts.merge!(YAML.safe_load(File.read(f), [], [], true))
  rescue => e
    RSpec.configuration.reporter.message "WARNING: Unable to load #{f}: #{e}"
  end
end

# Custom Facts
add_custom_fact :is_pe, 'true'
add_custom_fact :pe_version, nil
add_custom_fact :pe_server_version, '2019.0.2'
add_custom_fact :puppet_server, '35.175.94.167'
add_custom_fact :networking, {'ip' => '127.0.0.1'}
add_custom_fact :appenv, 'dev'
add_custom_fact :memory, {
  "system" => {
    "used" => "7.37 GiB",
    "total" => "15.51 GiB",
    "capacity" => "47.48%",
    "available" => "8.15 GiB",
    "used_bytes" => 7910199296,
    "total_bytes" => 16658804736,
    "available_bytes" => 8748605440
  }
}

if !Gem.win_platform?
  add_custom_fact :staging_http_get,    'curl'
  add_custom_fact :ssh_version,         'OpenSSH_6.6.1p1'
  add_custom_fact :ssh_version_numeric, '6.6.1'
  add_custom_fact :gogs_version,        '0.11.19'
  add_custom_fact :jenkins_plugins, nil
  add_custom_fact :root_home, '/root'
else
  add_custom_fact :choco_install_path,     'C:\ProgramData\chocolatey'
  add_custom_fact :chocolateyversion,      '0.10.7'
  add_custom_fact :archive_windir,         'C:\ProgramData\staging'
  add_custom_fact :staging_windir,         'C:\ProgramData\staging'
  add_custom_fact :operatingsystemversion, 'Windows Server 2012 R2 Standard'
  add_custom_fact :staging_http_get,       'powershell'
  add_custom_fact :iis_version,            '8.5'
  add_custom_fact :powershell_version,     '5.1.14409'
end


supported_os = on_supported_os.keys
if Gem.win_platform?
  SUPPORTED_OS = on_supported_os.delete_if { |k,v| !k.to_s.match(/windows/i) }
else
  SUPPORTED_OS = on_supported_os.delete_if { |k,v| k.to_s.match(/windows/i) }
end
puts "WARNING: Ommiting the following supported OS from this test run: #{(supported_os - SUPPORTED_OS.keys).join(',')}"

SimpleCov.start do
  add_filter '/spec'
  add_filter '/vendor'
  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::Console
  ])
end

base_dir = File.dirname(File.expand_path(__FILE__))

RSpec.configure do |c|
  # Readable test descriptions  
  c.formatter = :documentation
  c.color     = true
  c.manifest_dir    = File.join(base_dir, 'fixtures', 'modules', 'manifests')
  c.manifest        = File.join(base_dir, 'fixtures', 'modules', 'manifests', 'site.pp')
  c.mock_with :rspec
end

def ensure_module_defined(module_name)
  module_name.split('::').reduce(Object) do |last_module, next_module|
    last_module.const_set(next_module, Module.new) unless last_module.const_defined?(next_module, false)
    last_module.const_get(next_module, false)
  end
end



