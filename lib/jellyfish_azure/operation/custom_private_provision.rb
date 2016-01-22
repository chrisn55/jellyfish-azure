module JellyfishAzure
  module Operation
    class CustomPrivateProvision < AzureProvisionOperation
      def initialize(cloud_client, provider, product, service)
        super cloud_client, provider, product, service

        @definition = JellyfishAzure::Definition::CustomPrivateTemplateDefinition.new cloud_client, product
      end

      def setup
        @definition.template
      end

      def template_url
        @template_url ||= @cloud_client.storage.get_blob_sas_uri(
          @product.settings[:az_custom_name],
          @product.settings[:az_custom_key],
          @product.settings[:az_custom_container],
          @product.settings[:az_custom_blob],
          30)
      end

      def location
        @service.settings[:az_location]
      end

      def template_parameters
        template_parameters = @definition.template.apply_parameters 'az_custom_param_', @service.settings

        base_parameters = {
          templateBaseUrl: { value: URI.join(template_url, '.').to_s },
          sasToken: { value: URI(template_url).query },
          serviceName: { value: @service.resource_group_name }
        }

        base_parameters.merge template_parameters
      end
    end
  end
end
