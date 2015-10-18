module Tugboat
  module Middleware
    class DestroyImage < Base
      def call(env)
        ocean = env['barge']

        say "Queuing destroy image for #{env["image_id"]} #{env["image_name"]}...", nil, false

        response = ocean.image.destroy env["image_id"]

        unless response.success?
          say "Failed to destroy image: #{response.message}", :red
          exit 1
        else
          say 'Image deletion successful!', :green
        end

        @app.call(env)
      end
    end
  end
end

