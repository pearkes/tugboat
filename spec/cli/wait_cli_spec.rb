require 'spec_helper'

describe Tugboat::CLI do
  include_context 'spec'

  describe 'wait' do
    it 'waits for a droplet with a fuzzy name' do
      stub_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=1').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplets'), headers: {})

      stub_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=200').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplets'), headers: {})

      stub_request(:get, 'https://api.digitalocean.com/v2/droplets/6918990?per_page=200').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplet'), headers: {})

      expected_string = <<-eos
Droplet fuzzy name provided. Finding droplet ID...done\e[0m, 6918990 (example.com)
Waiting for droplet to become active..done\e[0m (0s)
eos

      cli.options = cli.options.merge(state: 'active')
      expect { cli.wait('example.com') }.to output(expected_string).to_stdout
    end

    it 'loops whilst it waits for state' do
      stub_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=1').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplets'), headers: {})

      stub_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=200').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplets'), headers: {})

      stub_request(:get, 'https://api.digitalocean.com/v2/droplets/6918990?per_page=200').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(
          { status: 200, body: fixture('show_droplet_inactive'), headers: {} },
          status: 200, body: fixture('show_droplet'), headers: {}
        )

      expected_string = <<-eos
Droplet fuzzy name provided. Finding droplet ID...done\e[0m, 6918990 (example.com)
Waiting for droplet to become active...done\e[0m (2s)
eos

      cli.options = cli.options.merge(state: 'active')
      expect { cli.wait('example.com') }.to output(expected_string).to_stdout
    end

    it 'waits for a droplet with an id' do
      stub_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=1').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplets'), headers: {})

      stub_request(:get, 'https://api.digitalocean.com/v2/droplets/6918990?per_page=200').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplet'), headers: {})

      expected_string = <<-eos
Droplet id provided. Finding Droplet...done\e[0m, 6918990 (example.com)
Waiting for droplet to become active..done\e[0m (0s)
      eos

      cli.options = cli.options.merge(id: '6918990', state: 'active')
      expect { cli.wait }.to output(expected_string).to_stdout
    end

    it 'waits for a droplet with a name' do
      stub_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=1').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplets'), headers: {})

      stub_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=200').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplets'), headers: {})

      stub_request(:get, 'https://api.digitalocean.com/v2/droplets/6918990?per_page=200').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplet'), headers: {})

      expected_string = <<-eos
Droplet name provided. Finding droplet ID...done\e[0m, 6918990 (example.com)
Waiting for droplet to become active..done\e[0m (0s)
eos

      cli.options = cli.options.merge(name: 'example.com', state: 'active')
      expect { cli.wait }.to output(expected_string).to_stdout
    end
  end
end
