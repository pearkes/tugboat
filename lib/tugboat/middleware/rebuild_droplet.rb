module Tugboat
  module Middleware
    class RebuildDroplet < Base
      def call(env)
        ocean = env['barge']

        say "Queuing rebuild for droplet #{env["droplet_id"]} #{env["droplet_name"]} with image #{env["image_id"]} #{env["image_name"]}...", nil, false

        response = ocean.droplet.rebuild env["droplet_id"],
        :image_id => env["image_id"]

        unless response.success?
          say "Failed to rebuild Droplet: #{response.message}", :red
          exit 1
        else
          say "Rebuild complete", :green
        end

        @app.call(env)
      end
    end
  end
end