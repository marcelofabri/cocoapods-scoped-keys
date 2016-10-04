require File.expand_path('../../spec_helper', __FILE__)

describe ScopedKeys::Parser do
  options = {
    project: 'Emergence',
    targets: 'Artsy Shows',
    keys: [
      'ArtsyAPIClientSecret',
      'ArtsyAPIClientKey'
    ],
    config: {
      name: 'Country',
      options: ['UK', 'US', 'BR'],
      keys: [
        'InstabugToken'
      ],
      config: {
        name: 'Environment',
        options: ['Production', 'Staging'],
        keys: [
          'ImportantAPIKey'
        ]
      }
    }
  }

  let(:parser) { described_class.new }

  it 'maps options from scoped format to cocoapods-keys' do
    expected = {
      project: 'PrivateEmergence',
      targets: 'Artsy Shows',
      keys: [
        'ArtsyAPIClientSecret',
        'ArtsyAPIClientKey',
        'InstabugToken__UK',
        'InstabugToken__US',
        'InstabugToken__BR',
        'ImportantAPIKey__Production__UK',
        'ImportantAPIKey__Staging__UK',
        'ImportantAPIKey__Production__US',
        'ImportantAPIKey__Staging__US',
        'ImportantAPIKey__Production__BR',
        'ImportantAPIKey__Staging__BR'
      ]
    }

    expect(parser.map_to_cocoapods_keys(options)).to eq(expected)
  end

  it 'parses enums' do
    expect(parser.enums_from_config(options)).to eq([
                                                      ScopedKeys::Enum.new('Country', ['UK', 'US', 'BR']),
                                                      ScopedKeys::Enum.new('Environment', ['Production', 'Staging'])
                                                    ])
  end

  it 'returns all keys' do
    expect(parser.all_keys(options)).to eq([
                                             'ArtsyAPIClientSecret',
                                             'ArtsyAPIClientKey',
                                             'InstabugToken',
                                             'ImportantAPIKey'
                                           ])
  end

  it 'returns camelcased keys' do
    expect(parser.camelcased_keys(options)).to eq([
                                                    'artsyAPIClientSecret',
                                                    'artsyAPIClientKey',
                                                    'instabugToken',
                                                    'importantAPIKey'
                                                  ])
  end

  it 'returns all keys with conditions' do
    expected = {
      'ArtsyAPIClientKey' => [],
      'ArtsyAPIClientSecret' => [],
      'ImportantAPIKey__Production__BR' => [
        { key: 'country', value: 'BR' },
        { key: 'environment', value: 'Production' }
      ],
      'ImportantAPIKey__Production__UK' => [
        { key: 'country', value: 'UK' },
        { key: 'environment', value: 'Production' }
      ],
      'ImportantAPIKey__Production__US' => [
        { key: 'country', value: 'US' },
        { key: 'environment', value: 'Production' }
      ],
      'ImportantAPIKey__Staging__BR' => [
        { key: 'country', value: 'BR' },
        { key: 'environment', value: 'Staging' }
      ],
      'ImportantAPIKey__Staging__UK' => [
        { key: 'country', value: 'UK' },
        { key: 'environment', value: 'Staging' }
      ],
      'ImportantAPIKey__Staging__US' => [
        { key: 'country', value: 'US' },
        { key: 'environment', value: 'Staging' }
      ],
      'InstabugToken__BR' => [{ key: 'country', value: 'BR' }],
      'InstabugToken__UK' => [{ key: 'country', value: 'UK' }],
      'InstabugToken__US' => [{ key: 'country', value: 'US' }]
    }
    expect(parser.keys_and_conditions_from_config(options)).to eq(expected)
  end
end
