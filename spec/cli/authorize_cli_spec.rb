require 'spec_helper'

describe Tugboat::CLI do
  include_context 'spec'

  let(:tmp_path) { project_path + '/tmp/tugboat' }

  describe 'authorize' do
    before do
    end

    it 'asks the right questions and checks credentials' do
      stub_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=1').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplets'), headers: {})

      expect($stdin).to receive(:gets).and_return(access_token)
      expect($stdin).to receive(:gets).and_return(timeout)
      expect($stdin).to receive(:gets).and_return(ssh_key_path)
      expect($stdin).to receive(:gets).and_return(ssh_user)
      expect($stdin).to receive(:gets).and_return(ssh_port)
      expect($stdin).to receive(:gets).and_return(region)
      expect($stdin).to receive(:gets).and_return(image)
      expect($stdin).to receive(:gets).and_return(size)
      expect($stdin).to receive(:gets).and_return(ssh_key_id)
      expect($stdin).to receive(:gets).and_return(private_networking)
      expect($stdin).to receive(:gets).and_return(backups_enabled)
      expect($stdin).to receive(:gets).and_return(ip6)

      expect { cli.authorize }.to output(/Note: You can get your Access Token from https:\/\/cloud.digitalocean.com\/settings\/tokens\/new/).to_stdout

      config = YAML.load_file(tmp_path)

      expect(config['defaults']['image']).to eq image
      expect(config['defaults']['region']).to eq region
      expect(config['defaults']['size']).to eq size
      expect(config['ssh']['ssh_user']).to eq ssh_user
      expect(config['ssh']['ssh_key_path']).to eq ssh_key_path
      expect(config['ssh']['ssh_port']).to eq ssh_port
      expect(config['defaults']['ssh_key']).to eq ssh_key_id
      expect(config['defaults']['private_networking']).to eq private_networking
      expect(config['defaults']['backups_enabled']).to eq backups_enabled
      expect(config['defaults']['ip6']).to eq ip6
    end

    it 'sets defaults if no input given' do
      stub_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=1').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => %r{Bearer}, 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplets'), headers: {})

      expect($stdin).to receive(:gets).and_return('')
      expect($stdin).to receive(:gets).and_return('')
      expect($stdin).to receive(:gets).and_return('')
      expect($stdin).to receive(:gets).and_return('')
      expect($stdin).to receive(:gets).and_return('')
      expect($stdin).to receive(:gets).and_return('')
      expect($stdin).to receive(:gets).and_return('')
      expect($stdin).to receive(:gets).and_return('')
      expect($stdin).to receive(:gets).and_return('')
      expect($stdin).to receive(:gets).and_return('')
      expect($stdin).to receive(:gets).and_return('')
      expect($stdin).to receive(:gets).and_return('')

      expect { cli.authorize }.to output(/Note: You can get your Access Token from https:\/\/cloud.digitalocean.com\/settings\/tokens\/new/).to_stdout

      config = YAML.load_file(tmp_path)

      expect(config['defaults']['image']).to eq 'ubuntu-14-04-x64'
      expect(config['defaults']['region']).to eq 'nyc2'
      expect(config['defaults']['size']).to eq '512mb'
      expect(config['ssh']['ssh_user']).to eq 'root'
      expect(config['ssh']['ssh_key_path']).to eq '~/.ssh/id_rsa'
      expect(config['ssh']['ssh_port']).to eq '22'
      expect(config['defaults']['ssh_key']).to eq ''
      expect(config['defaults']['private_networking']).to eq 'false'
      expect(config['defaults']['backups_enabled']).to eq 'false'
      expect(config['defaults']['ip6']).to eq 'false'
    end
  end
end
