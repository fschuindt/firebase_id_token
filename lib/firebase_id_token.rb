require 'firebase_id_token/version'
require 'firebase_id_token/configuration'
require 'firebase_id_token/certificates'
require 'firebase_id_token/signature'

# FirebaseIdToken::Certificates.download
# FirebaseIdToken::Certificates.download!
# FirebaseIdToken::Certificates.x509
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
