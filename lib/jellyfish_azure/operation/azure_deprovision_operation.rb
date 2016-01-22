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

        @cloud_client.resource_group.remove_resource_group  @service.resource_group_name

        check_status @service.resource_group_name

        set_status :terminated, 'Deprovision successful'

      rescue WaitUtil::TimeoutError
        handle_error ['The deprovisioning operation timed out.']
      rescue ValidationError => e
        handle_error [e.to_s]
      rescue AzureDeploymentErrors => e
        handle_error e.errors.map(&:error_message)
      rescue MsRestAzure::AzureOperationError => e
        handle_azure_error e
      rescue => e
        handle_error "Unexpected error: #{e.class}: #{e.message}"
      end

      private

      def handle_error(messages)
        set_status :terminated, messages[0]
        messages.each do |msg|
          entry = @service.logs.new
          entry.update_attributes(log_level: 'error', message: msg) unless entry.nil?
        end
      end

      def handle_azure_error(error)
        msg = error.body.nil? ? error.message : error.body['error']['message']
        set_status :terminated, msg
        msg = error.body.nil? ? error.message : error.body['error']['message']
        entry = @service.logs.new
        entry.update_attributes(log_level: 'error', message: msg) unless entry.nil?
      end

      def set_status(status, message)
        @service.update_attributes( status: status, status_msg: message )
      end

      def check_status(resource_group_name)
        rg = @cloud_client.resource_group.get resource_group_name
        if (rg.properties.provisioning_state == 'Failed')
          errors = AzureDeploymentError.new 'Unable to completely remove all resources in group'
          fail AzureDeploymentErrors, errors
        end
      rescue AzureDeploymentErrors => e
        handle_azure_error e
      rescue MsRestAzure::AzureOperationError => e
        # if resource group not found then delete was successful
        if  e.body['error']['code'] != 'ResourceGroupNotFound'
          msg = e.body.nil? ? e.message : e.body['error']['message']
          handle_error [msg]
        end
      rescue => e
        handle_error ["Unexpected error: #{e.class}: #{e.message}"]
      end
    end
  end
end
