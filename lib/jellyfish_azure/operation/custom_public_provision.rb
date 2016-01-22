require 'open-uri'

module JellyfishAzure
  module Operation
    class CustomPublicProvision < AzureProvisionOperation
      def initialize(cloud_client, provider, product, service)
        super cloud_client, provider, product, service

        @definition = JellyfishAzure::Definition::CustomPublicTemplateDefinition.new cloud_client, product
      end

      def setup
        @definition.template
      end

      def template_url
        @product.settings[:az_custom_template_uri]
      end

      def location
        @service.settings[:az_location]
      end

      def template_parameters
        template_parameters = @definition.template.apply_parameters 'az_custom_param_', @service.settings

        base_parameters = {
          templateBaseUrl: { value: URI.join(template_url, '.').to_s },
          serviceName: { value: @service.resource_group_name }
        }

        base_parameters.merge template_parameters
      end
    end
  end
end
