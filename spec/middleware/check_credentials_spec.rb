require 'spec_helper'

describe Tugboat::Middleware::CheckCredentials do
  include_context 'spec'

  describe '.call' do
    it 'raises SystemExit with no configuration' do
      stub_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=1').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(headers: { 'Content-Type' => 'application/json' }, status: 401, body: fixture('401'))

      # Inject the client.
      env['barge'] = ocean

      expect { described_class.new(app).call(env) }.to raise_error(SystemExit).and output(%r{Failed to connect to DigitalOcean. Reason given from API: unauthorized - Unable to authenticate you.}).to_stdout
      expect(a_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=1')).
        to have_been_made
    end
  end
end
