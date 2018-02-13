require 'simplecov'
require 'coveralls'
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start('rails')

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

module ActiveSupport
  class TestCase
    # Setup all fixtures in test/fixtures/*.yml for all tests in alpha order.
    fixtures :all

    def mock_auth(user)
      OmniAuth.config.mock_auth[:saml] =
        OmniAuth::AuthHash.new(provider: 'saml',
                               uid: user.uid,
                               info: { uid: user.uid, email: user.email })

      get '/users/auth/saml/callback'
    end

    def auth_setup
      Rails.application.env_config['devise.mapping'] = Devise.mappings[:user]
      Rails.application.env_config['omniauth.auth'] =
        OmniAuth.config.mock_auth[:saml]
      OmniAuth.config.test_mode = true
    end

    def auth_teardown
      OmniAuth.config.test_mode = false
      OmniAuth.config.mock_auth[:saml] = nil
    end
  end
end

module ActionDispatch
  class IntegrationTest
    include Devise::Test::IntegrationHelpers
  end
end
