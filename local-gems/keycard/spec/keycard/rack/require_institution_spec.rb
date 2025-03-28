# frozen_string_literal: true

require 'keycard/rack/require_institution'

RSpec.describe Keycard::Rack::RequireInstitution do
  let(:app) { ->(_) { [200, {}, ['OK']] } }
  let(:middleware) { described_class.new(app, institution) }
  let(:response) { middleware.call(env) }
  let(:response_status) { response.first }

  context "when matching any institution" do
    let(:institution) { :any }
    describe "#call" do
      context 'with an empty env' do
        let(:env) { {} }

        it 'denies access' do
          expect(response_status).to be(403)
        end
      end

      context 'with an env that includes institution 1' do
        let(:env) { { 'dlpsInstitutionId' => [1] } }
        it 'allows access' do
          expect(response_status).to be(200)
        end
      end
    end
  end

  context "when matching institution 1" do
    let(:institution) { 1 }
    describe "#call" do
      context 'with an empty env' do
        let(:env) { {} }

        it 'denies access' do
          expect(response_status).to be(403)
        end
      end

      context 'with an env that includes institution 1' do
        let(:env) { { 'dlpsInstitutionId' => [1] } }

        it 'allows access' do
          expect(response_status).to be(200)
        end
      end

      context 'with an env that includes institution 2' do
        let(:env) { { 'dlpsInstitutionId' => [2] } }

        it 'denies access' do
          expect(response_status).to be(403)
        end
      end
    end
  end
end
