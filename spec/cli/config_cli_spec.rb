require 'spec_helper'

describe Tugboat::CLI do
  include_context 'spec'

  describe 'config' do
    it 'shows the full config' do
      expected_string = <<-eos
Current Config\x20
Path: #{Dir.pwd}/tmp/tugboat
---
authentication:
  access_token: foo
connection:
  timeout: '15'
ssh:
  ssh_user: baz
  ssh_key_path: ~/.ssh/id_rsa2
  ssh_port: '33'
defaults:
  region: nyc2
  image: ubuntu-14-04-x64
  size: 512mb
  ssh_key: '1234'
  private_networking: 'false'
  backups_enabled: 'false'
  ip6: 'false'
      eos

      expect { cli.config }.to output(expected_string).to_stdout
    end

    it 'hides sensitive data if option given' do
      cli.options = cli.options.merge(hide: true)

      expected_string = <<-eos
Current Config (Keys Redacted)
Path: #{Dir.pwd}/tmp/tugboat
---
authentication:
  access_token:\x20\x20[REDACTED]
connection:
  timeout: '15'
ssh:
  ssh_user: baz
  ssh_key_path: ~/.ssh/id_rsa2
  ssh_port: '33'
defaults:
  region: nyc2
  image: ubuntu-14-04-x64
  size: 512mb
  ssh_key: '1234'
  private_networking: 'false'
  backups_enabled: 'false'
  ip6: 'false'
      eos

      expect { cli.config }.to output(expected_string).to_stdout
    end
  end
end
