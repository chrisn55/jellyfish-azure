require 'rails'
require 'ms_rest_azure'
require 'azure'
require 'azure_mgmt_storage'
require 'azure_mgmt_resources'
require 'json'
require 'waitutil'

require 'jellyfish_azure/engine'

require 'jellyfish_azure/deployment_template_parameter.rb'
require 'jellyfish_azure/deployment_template.rb'
require 'jellyfish_azure/validation_error.rb'
require 'jellyfish_azure/azure_deployment_error.rb'

require 'jellyfish_azure/cloud/deployment_client.rb'
require 'jellyfish_azure/cloud/resource_group_client.rb'
require 'jellyfish_azure/cloud/storage_client.rb'
require 'jellyfish_azure/cloud/azure_client.rb'
require 'jellyfish_azure/cloud/cloud_argument_error.rb'

require 'jellyfish_azure/definition/custom_private_template_definition.rb'
require 'jellyfish_azure/definition/custom_public_template_definition.rb'
require 'jellyfish_azure/definition/web_dev_environment_definition.rb'

require 'jellyfish_azure/operation/azure_deployment_errors.rb'
require 'jellyfish_azure/operation/azure_operation.rb'
require 'jellyfish_azure/operation/azure_provision_operation.rb'
require 'jellyfish_azure/operation/azure_deprovision_operation.rb'
require 'jellyfish_azure/operation/custom_private_provision.rb'
require 'jellyfish_azure/operation/custom_public_provision.rb'
require 'jellyfish_azure/operation/web_dev_environment_provision.rb'

module JellyfishAzure
end
