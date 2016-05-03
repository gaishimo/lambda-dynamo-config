require "lambda_dynamo_config/version"

module LambdaDynamoConfig
  class Table
    def initialize(awsOption = nil, table_name = 'lambda_configurations')
      awsOption ||= { region: 'ap-northeast-1' }
      Aws.config.update(awsOption)
      @table_name = table_name
    end

    def client
      @client ||= Aws::DynamoDB::Client.new
    end

    def create!
      client.create_table({
        table_name: @table_name,
        attribute_definitions: [
          { attribute_name: 'function_name', attribute_type: 'S' },
          { attribute_name: 'version', attribute_type: 'S' }
        ],
        key_schema: [
          { attribute_name: 'function_name', key_type: 'HASH' },
          { attribute_name: 'version', key_type: 'RANGE' }
        ],
        provisioned_throughput: {
          read_capacity_units: 1,
          write_capacity_units: 1
        },
        stream_specification: {
          stream_enabled: false,
        }
      });
      p client.describe_table(table_name: @table_name)
    end

    def drop!
      client.delete_table(table_name: @table_name)
    end

    def set_config(function_name, config)
      client.put_item({
        table_name: @table_name,
        item: {
          function_name: function_name,
          config: config
        }
      })
    end
  end
end
