module JellyfishAzure
  module Cloud
    class DeploymentClient
      def initialize(credentials, subscription_id)
        @client = ::Azure::ARM::Resources::ResourceManagementClient.new credentials
        @client.subscription_id = subscription_id
      end

      def create_deployment(resource_group_name, deployment_name, template_url, template_parameters)
        properties = ::Azure::ARM::Resources::Models::DeploymentProperties.new
        properties.mode = 'Incremental'
        properties.parameters = template_parameters

        properties.template_link = ::Azure::ARM::Resources::Models::TemplateLink.new
        properties.template_link.uri = template_url

        params = ::Azure::ARM::Resources::Models::Deployment.new
        params.properties = properties

        promise = @client.deployments.create_or_update(resource_group_name, deployment_name, params)
        promise.value!
      end

      def get_resource_group_status(resource_group_name)
        promise = @client.resource_groups.get resource_group_name
        result = promise.value!

        [result.body.properties.provisioning_state, result.body.properties.outputs || {}]
      end

      def get_deployment_status(resource_group_name, deployment_name)
        promise = @client.deployments.get resource_group_name, deployment_name
        result = promise.value!

        [result.body.properties.provisioning_state, result.body.properties.outputs || {}]
      end

      def get_deployment_errors(resource_group_name, deployment_name)
        promise = @client.deployment_operations.list resource_group_name, deployment_name
        result = promise.value!

        result.body.value
          .select { |item| item.properties.provisioning_state == 'Failed' }
          .map { |item| AzureDeploymentError.new item.properties.status_message['error']['message'] }
      end
    end
  end
end
