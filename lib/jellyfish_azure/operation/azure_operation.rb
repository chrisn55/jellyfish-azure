module JellyfishAzure
  module Operation
    #
    #  abstract base class for operations on azure accounts
    class AzureOperation
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

      protected

      def log_error(message)
        entry = @service.logs.new
        entry.update_attributes(log_level: 'error', message: message) unless entry.nil?
      end

      def log_note(message)
        entry = @service.logs.new
        entry.update_attributes(log_level: 'info', message: message) unless entry.nil?
      end

      def handle_errors(messages)
        set_status :terminated, messages[0]
        messages.each do |msg|
          log_error msg
        end
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

      def handle_azure_error(error)
        msg = error.body.nil? ? error.message : error.body['error']['message']
        set_status :terminated, msg
        msg = error.body.nil? ? error.message : error.body['error']['message']
        log_error msg
      end

      def set_status(status, message)
        @service.update_attributes( status: status, status_msg: message )
      end
    end
  end
end