module JellyfishAzure
  module Operation
    class AzureDeprovisionOperation
      WAIT_TIMEOUT = 14_400
      WAIT_DELAY = 15

      attr_accessor :deploy_timeout, :deploy_delay

      def initialize(cloud_client, provider, product, service)
        @cloud_client = cloud_client
        @provider = provider
        @product = product
        @service = service

        @deploy_timeout = WAIT_TIMEOUT
        @deploy_delay = WAIT_DELAY
      end

      def setup
      end

      def location
      end

      def execute
        setup

        promise = @cloud_client.resource_group.remove_resource_group  @service.resource_group_name

        set_status :deprovisioning, 'Deprovisioning service'

        wait_for_status @service.resource_group_name

        set_status :deprovisioned, 'Deprovision successful'

      rescue WaitUtil::TimeoutError
        handle_error 'The deprovisioning operation timed out.'
      rescue ValidationError => e
        handle_error e.to_s
      rescue AzureDeploymentErrors => e
        handle_error e.errors.map(&:error_message).join "\n"
      rescue MsRestAzure::AzureOperationError => e
        handle_azure_error e
      rescue => e
        handle_error "Unexpected error: #{e.class}: #{e.message}"
      end

      private

      def handle_error(message)
        set_status :terminated, message
      end

      def handle_azure_error(error)
        message = error.body.nil? ? error.message : error.body['error']['message']
        set_status :terminated, message
      end

      def set_status(status, message)
        @service.status = status
        @service.status_msg = message
        @service.save
      end

      def wait_for_status(resource_group_name)
        state = nil
        outputs = nil
        WaitUtil.wait_for_condition 'deprovision', timeout_sec: deploy_timeout, delay_sec: deploy_delay do
          rg= @cloud_client.resource_groups.get resource_group_name

          (rg.properties.provisioningState != 'Failed' && rg.properties.provisioningState != 'Deleted')
        end

        if (rg.properties.provisioningState == 'Failed')
          errors = AzureDeploymentError.new 'Unable to completely remove all resources in group'
          fail AzureDeploymentErrors, errors
        end

        outputs
      end
    end
  end
end
