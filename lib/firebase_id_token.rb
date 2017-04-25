require 'redis'
require 'redis-namespace'
require 'httparty'
require 'jwt'

require 'firebase_id_token/version'
require 'firebase_id_token/exceptions/no_entities_error'
require 'firebase_id_token/exceptions/request_code_error'
require 'firebase_id_token/exceptions/time_to_live_error'
require 'firebase_id_token/configuration'
require 'firebase_id_token/certificates'
require 'firebase_id_token/signature'

# FirebaseIdToken::Certificates.request
# FirebaseIdToken::Certificates.request_anyway
# FirebaseIdToken::Certificates.present?
# FirebaseIdToken::Certificates.all
# FirebaseIdToken::Certificates.find(kid)
# FirebaseIdToken::Signature.verify(token)
module FirebaseIdToken
  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield configuration
  end
end
