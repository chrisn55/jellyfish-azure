module JellyfishAzure
  module Operation
    class WebDevEnvironmentProvision < AzureProvisionOperation
      def initialize(cloud_client, provider, product, service)
        super cloud_client, provider, product, service
      end

      def setup
        available, message = @cloud_client.storage.check_name_availability @service.settings[:az_dev_dns]

        unless available
          fail ValidationError, message
        end
      end

      def template_url
        'https://raw.githubusercontent.com/projectjellyfish/jellyfish-azure/master/templates/web-dev-environment/azuredeploy.json'
      end

      def location
        @service.settings[:az_location]
      end

      def template_parameters
        {
          serviceName: { value: @service.resource_group_name },
          webTechnology: { value: @product.settings[:az_dev_web] },
          dbTechnology: { value: @product.settings[:az_dev_db] },
          dnsNameForPublicIP: { value: @service.settings[:az_dev_dns] },
          adminUsername: { value: @service.settings[:az_username] },
          adminPassword: { value: @service.settings[:az_password] }
        }
      end
    end
  end
end
