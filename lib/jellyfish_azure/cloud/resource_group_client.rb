module JellyfishAzure
  module Cloud
    class ResourceGroupClient
      def initialize(credentials, subscription_id)
        @client = ::Azure::ARM::Resources::ResourceManagementClient.new credentials
        @client.subscription_id = subscription_id
      end

      def get(resource_group_name)
        promise = @client.resource_groups.get(resource_group_name)
        promise.value!
      end

      def create_resource_group(resource_group_name, location)
        resource_group = ::Azure::ARM::Resources::Models::ResourceGroup.new
        resource_group.location = location

        promise = @client.resource_groups.create_or_update(resource_group_name, resource_group)
        promise.value!
      end

      def remove_resource_group(resource_group_name)
        promise = @client.resource_groups.delete(resource_group_name)
        promise.value!
      end
    end
  end
end
