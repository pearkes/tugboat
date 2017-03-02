require 'spec_helper'

describe Tugboat::CLI do
  include_context 'spec'

  describe 'droplets' do
    it 'shows a list when droplets exist' do
      stub_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=1').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplets'), headers: {})

      stub_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=200').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplets'), headers: { 'Content-Type' => 'application/json' })

      cli.droplets

      expect($stdout.string).to eq <<-eos
example.com (ip: 104.236.32.182, status: \e[32mactive\e[0m, region: nyc3, id: 6918990)
example2.com (ip: 104.236.32.172, status: \e[32mactive\e[0m, region: nyc3, id: 3164956)
example3.com (ip: 104.236.32.173, status: \e[31moff\e[0m, region: nyc3, id: 3164444)
      eos

      expect(a_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=200')).to have_been_made
    end

    it 'shows a private IP if droplet in list has private IP' do
      stub_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=1').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplets'), headers: {})

      stub_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=200').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplets_private_ip'), headers: { 'Content-Type' => 'application/json' })

      cli.droplets

      expect($stdout.string).to eq <<-eos
exampleprivate.com (ip: 104.236.32.182, private_ip: 10.131.99.89, status: \e[32mactive\e[0m, region: nyc3, id: 6918990)
example2.com (ip: 104.236.32.172, status: \e[32mactive\e[0m, region: nyc3, id: 3164956)
example3.com (ip: 104.236.32.173, status: \e[31moff\e[0m, region: nyc3, id: 3164444)
      eos

      expect(a_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=200')).to have_been_made
    end

    it 'returns an error message when no droplets exist' do
      stub_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=1').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplets'), headers: {})

      stub_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=200').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplets_empty'), headers: { 'Content-Type' => 'application/json' })

      cli.droplets

      expect($stdout.string).to eq <<-eos
You don't appear to have any droplets.
Try creating one with \e[32m`tugboat create`\e[0m
      eos

      expect(a_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=200')).to have_been_made
    end

    it 'shows no output when --quiet is set' do
      stub_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=1').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplets'), headers: {})

      stub_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=200').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplets'), headers: { 'Content-Type' => 'application/json' })

      cli.options = cli.options.merge(quiet: true)
      cli.droplets

      # Should be /dev/null not stringIO
      expect($stdout).to be_a File

      expect(a_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=200')).to have_been_made
    end

    it 'includes urls when --include-urls is set' do
      stub_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=1').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplets'), headers: {})

      stub_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=200').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplets'), headers: { 'Content-Type' => 'application/json' })

      cli.options = cli.options.merge('include_urls' => true)
      cli.droplets

      expect($stdout.string).to eq <<-eos
example.com (ip: 104.236.32.182, status: \e[32mactive\e[0m, region: nyc3, id: 6918990, url: 'https://cloud.digitalocean.com/droplets/6918990')
example2.com (ip: 104.236.32.172, status: \e[32mactive\e[0m, region: nyc3, id: 3164956, url: 'https://cloud.digitalocean.com/droplets/3164956')
example3.com (ip: 104.236.32.173, status: \e[31moff\e[0m, region: nyc3, id: 3164444, url: 'https://cloud.digitalocean.com/droplets/3164444')
      eos

      expect(a_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=200')).to have_been_made
    end

    it 'paginates when multiple pages are returned' do
      stub_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=1').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplets'), headers: {})

      stub_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=200').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplets_paginated_first'), headers: { 'Content-Type' => 'application/json' })

      stub_request(:get, 'https://api.digitalocean.com/v2/droplets?page=2&per_page=200').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplets_paginated_last'), headers: { 'Content-Type' => 'application/json' })

      cli.options = cli.options.merge('include_urls' => true)
      cli.droplets

      expect($stdout.string).to eq <<-eos
page1example.com (ip: 104.236.32.182, status: \e[32mactive\e[0m, region: nyc3, id: 6918990, url: 'https://cloud.digitalocean.com/droplets/6918990')
page1example2.com (ip: 104.236.32.172, status: \e[32mactive\e[0m, region: nyc3, id: 3164956, url: 'https://cloud.digitalocean.com/droplets/3164956')
page1example3.com (ip: 104.236.32.173, status: \e[31moff\e[0m, region: nyc3, id: 3164444, url: 'https://cloud.digitalocean.com/droplets/3164444')
page2example.com (ip: 104.236.32.182, status: \e[32mactive\e[0m, region: nyc3, id: 6918990, url: 'https://cloud.digitalocean.com/droplets/6918990')
page2example2.com (ip: 104.236.32.172, status: \e[32mactive\e[0m, region: nyc3, id: 3164956, url: 'https://cloud.digitalocean.com/droplets/3164956')
page2example3.com (ip: 104.236.32.173, status: \e[31moff\e[0m, region: nyc3, id: 3164444, url: 'https://cloud.digitalocean.com/droplets/3164444')
      eos

      expect(a_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=200')).to have_been_made
    end
  end
end
