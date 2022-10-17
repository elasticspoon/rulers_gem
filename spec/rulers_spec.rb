# frozen_string_literal: true

require 'spec_helper'
class TestController < Rulers::Controller
  def index
    'Hello'
  end

  def test_instance_vars
    @test_var = 'test_var'
  end
end

RSpec.describe Rulers do
  include Rack::Test::Methods

  let(:app) { Rulers::Application.new }
  let(:controller_action) { [TestController, 'index'] }

  before { allow(app).to receive(:get_controller_and_action).and_return(controller_action) }
  context 'testing controller' do
    it 'has a version number' do
      expect(Rulers::VERSION).not_to be_nil
    end

    it 'TestApp has a 200 reponse' do
      get '/word/word'

      expect(last_response.ok?).to be true
    end

    it 'TestApp returns a body containing hello' do
      get '/word/word'

      expect(last_response.body['Hello']).to be_truthy
    end
  end

  context 'instance var tests' do
    let(:controller_action) { [TestController, 'test_instance_vars'] }
    xit 'has access to @test_var that is set in controller' do
      get '/word/word'

      expect
    end
  end
end
