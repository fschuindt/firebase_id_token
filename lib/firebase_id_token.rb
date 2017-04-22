require 'firebase_id_token/version'
require 'firebase_id_token/exceptions/certificates/request_code_error'
require 'firebase_id_token/exceptions/certificates/time_to_live_error'
require 'firebase_id_token/configuration'
require 'firebase_id_token/certificates'
require 'firebase_id_token/signature'

# Those two may raise a error.
# FirebaseIdToken::Certificates.request
# FirebaseIdToken::Certificates.request_anyway

# boolean
# FirebaseIdToken::Certificates.present?

# Hash of certificates or a empty hash.
# FirebaseIdToken::Certificates.x509
# {}

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
