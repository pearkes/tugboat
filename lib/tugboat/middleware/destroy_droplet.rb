module Tugboat
  module Middleware
    class DestroyDroplet < Base
      def call(env)
        ocean = env['barge']

        say "Queuing destroy for #{env["droplet_id"]} #{env["droplet_name"]}...", nil, false

        response = ocean.droplet.destroy env["droplet_id"]

        unless response.success?
          say "Failed to destroy Droplet: #{response.message}", :red
          exit 1
        else
          say "Deletion Successful!", :green
        end

        @app.call(env)
      end
    end
  end
end

