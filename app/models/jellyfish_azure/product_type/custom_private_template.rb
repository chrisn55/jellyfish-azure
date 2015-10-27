module JellyfishAzure
  module ProductType
    class CustomPrivateTemplate < ::ProductType
      def self.load_product_types
        return unless super

        transaction do
          [
            set('Custom template from private Blob Storage', '184480e8-7a51-4144-a0e6-a8564cfca752', provider_type: 'JellyfishAzure::Provider::Azure')
          ].each do |s|
            create! s.merge!(type: 'JellyfishAzure::ProductType::CustomPrivateTemplate')
          end
        end
      end

      def description
        'Uses an existing Azure Resource Manager Deployment template from either a public location or private Azure
blob storage'
      end

      def tags
        %w(storage cdn)
      end

      def product_questions
        [
          { label: 'Storage Account Name', name: :az_custom_name, value_type: :string, field: :text, required: true },
          { label: 'Storage Account Key', name: :az_custom_key, value_type: :string, field: :password, required: true },
          { label: 'Storage Account Container', name: :az_custom_container, value_type: :string, field: :text, required: true },
          { label: 'Storage Account Blob', name: :az_custom_blob, value_type: :string, field: :text, required: true }
        ]
      end

      def order_questions
        [
          { label: 'Location', name: :az_custom_location, value_type: :string, field: :az_custom_location, required: true },
          { label: 'dnsNameForPublicIP', name: 'az_custom_param_dnsNameForPublicIP', value_type: :string, field: :text, required: true },
          { label: 'adminUsername', name: 'az_custom_param_adminUsername', value_type: :string, field: :text, required: true },
          { label: 'adminPassword', name: 'az_custom_param_adminPassword', value_type: :string, field: :password, required: true }
        ]
      end

      def service_class
        'JellyfishAzure::Service::CustomPrivateTemplate'.constantize
      end
    end
  end
end