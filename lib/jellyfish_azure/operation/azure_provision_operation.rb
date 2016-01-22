module JellyfishAzure
  module Operation
    class AzureProvisionOperation < AzureOperation
      DEPLOYMENT_NAME = 'Deployment'

      def setup
      end

      def location
      end

      def template_url
      end

      def template_parameters
      end

      def execute
        setup

        set_status :provisioning, 'Provisioning service'

        @cloud_client.resource_group.create_resource_group @service.resource_group_name, location

        @cloud_client.deployment.create_deployment @service.resource_group_name, DEPLOYMENT_NAME, template_url, template_parameters

        outputs = wait_for_deployment DEPLOYMENT_NAME

        save_outputs outputs

        set_status :available, 'Deployment successful'

      rescue WaitUtil::TimeoutError
        handle_errors ['The provisioning operation timed out.']
      rescue ValidationError => e
        handle_errors [e.to_s]
      rescue AzureDeploymentErrors => e
        handle_errors e.errors
      rescue MsRestAzure::AzureOperationError => e
        handle_azure_error e
      rescue => e
        handle_errors ["Unexpected error: #{e.class}: #{e.message}"]
      end

      private

      def wait_for_deployment(deployment_name)
        state = nil
        outputs = nil
        WaitUtil.wait_for_condition 'deployment', timeout_sec: deploy_timeout, delay_sec: deploy_delay do
          state, outputs = @cloud_client.deployment.get_deployment_status @service.resource_group_name, deployment_name

          (state != 'Accepted' && state != 'Running')
        end

        if (state == 'Failed')
          errors = @cloud_client.deployment.get_deployment_errors @service.resource_group_name, deployment_name

          fail AzureDeploymentErrors, errors
        end

        outputs
      end
    end
  end
end
