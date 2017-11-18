require 'spec_helper'

describe Tugboat::CLI do
  include_context 'spec'

  describe 'regions' do
    it 'shows a list' do
      stub_request(:get, 'https://api.digitalocean.com/v2/regions?page=1&per_page=20').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_regions'), headers: { 'Content-Type' => 'application/json' })

      expected_string =   <<-eos
Regions:
Amsterdam 1 (slug: ams1)
Amsterdam 2 (slug: ams2)
Amsterdam 3 (slug: ams3)
London 1 (slug: lon1)
New York 1 (slug: nyc1)
New York 2 (slug: nyc2)
New York 3 (slug: nyc3)
San Francisco 1 (slug: sfo1)
Singapore 1 (slug: sgp1)
      eos

      expect { cli.regions }.to output(expected_string).to_stdout

      expect(a_request(:get, 'https://api.digitalocean.com/v2/regions?page=1&per_page=20')).
        to have_been_made
    end
  end
end
