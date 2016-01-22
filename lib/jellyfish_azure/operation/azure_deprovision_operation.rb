module JellyfishAzure
  module Operation
    class AzureDeprovisionOperation < AzureOperation
      def execute
        log_note 'Deprovision started'
        set_status :stopping,'Deprovision started'
        @cloud_client.resource_group.remove_resource_group  @service.resource_group_name

        check_status @service.resource_group_name

        set_status :terminated, 'Deprovision successful'
        log_note 'Deprovision completed successfully'
      rescue WaitUtil::TimeoutError
        handle_errors ['The deprovisioning operation timed out.']
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

      def check_status(resource_group_name)
        rg = @cloud_client.resource_group.get resource_group_name
        if (rg.properties.provisioning_state == 'Failed')
          errors = AzureDeploymentError.new 'Unable to completely remove all resources in group'
          fail AzureDeploymentErrors, errors
        end
      rescue MsRestAzure::AzureOperationError => e
        # if resource group not found then delete was successful
        # otherwise some error occurred.
        if  e.body['error']['code'] != 'ResourceGroupNotFound'
          msg = e.body.nil? ? e.message : e.body['error']['message']
          handle_errors [msg]
        end
      end
    end
  end
end
