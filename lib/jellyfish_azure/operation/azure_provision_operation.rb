
module JellyfishAzure
  module Operation
    class AzureProvisionOperation
      DEPLOYMENT_NAME = 'Deployment'
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

      def template_url
      end

      def template_parameters
      end

      def execute
        setup

        @cloud_client.resource_group.create_resource_group @service.resource_group_name, location

        @cloud_client.deployment.create_deployment @service.resource_group_name, DEPLOYMENT_NAME, template_url, template_parameters

        set_status :provisioning, 'Provisioning service'

        outputs = wait_for_deployment DEPLOYMENT_NAME

        save_outputs outputs

        set_status :available, 'Deployment successful'

      rescue WaitUtil::TimeoutError
        handle_error ['The provisioning operation timed out.']
      rescue ValidationError => e
        handle_error [e.to_s]
      rescue AzureDeploymentErrors => e
        handle_error e.errors
      rescue MsRestAzure::AzureOperationError => e
        handle_azure_error e
      rescue => e
        handle_error ["Unexpected error: #{e.class}: #{e.message}"]
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
        @service.status = status
        @service.status_msg = message
        @service.save
      end

      def save_outputs(outputs)
        outputs.each do |key, value|
          service_output = get_output(key) || @service.service_outputs.new(name: key)
          service_output.update_attributes(value: value[:value], value_type: :string) unless service_output.nil?
        end
      end

      def get_output(name)
        @service.service_outputs.where(name: name).first
      end

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
