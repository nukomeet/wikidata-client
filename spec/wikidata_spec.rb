require 'spec_helper'

describe Wikidata do
  let(:options) do
    { request: { timeout: 10 } }
  end
  let(:builder) do
    -> (builder) { builder.use :excon }
  end
  it 'should be configurable' do
    Wikidata.configure do |c|
      c.options = options
      c.faraday = builder
    end
    Wikidata.options.should be options
    Wikidata.faraday.should be builder
  end
end
