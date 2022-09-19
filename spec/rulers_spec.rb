# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Rulers do
  include Rack::Test::Methods

  let(:app) { Rulers::Application.new }

  it 'has a version number' do
    expect(Rulers::VERSION).not_to be_nil
  end

  it 'has a 200 reponse' do
    get '/'

    expect(last_response.ok?).to be true
  end

  it 'returns a body containing hello' do
    get '/'
    expect(last_response.body['Hello']).to be_truthy
  end
end
