module JellyfishAzure
  module Service
    class AzureService < ::Service
      def resource_group_name
        @_resource_group_name ||= begin
          safe_uuid = uuid.tr '-', ''
          safe_name = name.gsub(/[^0-9a-zA-Z_]/i, '')

          "jf#{safe_uuid}_#{safe_name}"
        end
      end

      def deprovision
        credentials = product.provider.credentials
        @cloud_client = JellyfishAzure::Cloud::AzureClient.new credentials, product.provider.subscription_id

        operation = JellyfishAzure::Operation::AzureDeprovisionOperation.new @cloud_client, product.provider, product, self
        operation.execute
      end
    end
  end
end
