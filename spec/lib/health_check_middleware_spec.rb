require 'rails_helper'
require 'health_check_middleware'

describe HealthCheckMiddleware do
  let(:env) { {} }
  let(:app) { double }
  subject { HealthCheckMiddleware.new(app) }

  context 'when the PATH_INFO is /health-check' do
    let(:checkup_data) { {} }
    before do
      env['PATH_INFO'] = '/health-check'
      allow(HealthCheck).to receive(:checkup).with(env).and_return checkup_data
    end

    it 'renders the result of the checkup as JSON' do
      checkup_data['hats'] = 'OK'
      checkup_data['cheese-board'] = ['cheddar', 'roquefort', 'casu-marzu']
      status, headers, body = subject.call(env)

      expect(status).to eq 200
      expect(headers['Content-Type']).to eq 'application/json'
      expect(body.first).to eq checkup_data.to_json
    end
  end

  context 'when the PATH_INFO is not /health-check' do
    before { env['PATH_INFO'] = '/petitions/1' }

    it 'calls through to the wrapped app and returns its response' do
      app_response = double
      expect(app).to receive(:call).with(env).and_return app_response
      expect(subject.call(env)).to eq app_response
    end
  end
end
