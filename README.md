# Ruby Firebase ID Token verifier (pre-release)

![Alt text](https://api.travis-ci.org/fschuindt/firebase_id_token.svg?branch=master)
[![Code Climate](https://codeclimate.com/github/fschuindt/firebase_id_token/badges/gpa.svg)](https://codeclimate.com/github/fschuindt/firebase_id_token)
[![Issue Count](https://codeclimate.com/github/fschuindt/firebase_id_token/badges/issue_count.svg)](https://codeclimate.com/github/fschuindt/firebase_id_token)
[![Test Coverage](https://codeclimate.com/github/fschuindt/firebase_id_token/badges/coverage.svg)](https://codeclimate.com/github/fschuindt/firebase_id_token/coverage)

A Ruby gem to verify the signature of Firebase ID Tokens. It uses Redis to store Google's x509 certificates and manage their expiration time, so you don't need to request Google's API in every execution and can access it as fast as reading from memory.

It also checks the JWT payload parameters as recommended [here](https://firebase.google.com/docs/auth/admin/verify-id-tokens) by Firebase official documentation.

## Pre-release Notes

**This gem was developed recently and needs real world feedback.**

If you are going to use it in production environment, please note that I am still testing it. It has realistc RSpec examples that uses real X509 certificates and signed JWT to perform tests and I can say it's working great. But as it's working implies in security risks you should be aware.

Feel free to open any issue or to [contact me](https://fschuindt.github.io/blog/about/) regarding it's performance.

## Docs

 + http://www.rubydoc.info/gems/firebase_id_token

## Requirements

+ Redis

## Installing

```
gem install firebase_id_token
```

or in your Gemfile
```
gem 'firebase_id_token'
```
then
```
bundle install
```

## Configuration

It's needed to set up your Firebase Project ID.

If you are using Rails, this should probably go into `config/initializers/firebase_id_token.rb`.

```ruby
FirebaseIdToken.configure do |config|
  config.project_ids = ['your-firebase-project-id']
end
```

`project_ids` must be a Array.

*If you want to verify signatures from more than one Firebase project, just add more Project IDs to the list.*

You can also pass a Redis instance to `config` if you are not using Redis defaults.  
In this case you must have the gem `redis` in your `Gemfile`.
```ruby
FirebaseIdToken.configure do |config|
  config.project_ids = ['your-firebase-project-id']
  congig.redis = Redis.new(:host => "10.0.1.1", :port => 6380, :db => 15)
end
```

Otherwise it will use just `Redis.new` as the instance.

## Usage

### Downloading Certificates

Before verifying tokens, you need to download Google's x509 certificates.

To do it simply:
```ruby
FirebaseIdToken::Certificates.request
```

It will download the certificates and save it in Redis, but only if Redis certificates database is empty. To force download and override Redis database, use:
```ruby
FirebaseIdToken::Certificates.request_anyway
```

Google give us information about the certificates expiration time, it's used to set a Redis TTL (Time-To-Live) when saving it. By doing so, the certificates will be automatically deleted after it's expiration.

You can access informations about it:
```ruby
# Boolean representing the presence of certificates in Redis database.
FirebaseIdToken::Certificates.preset?
=> true

# How many seconds until the certificates expiration.
FirebaseIdToken::Certificates.ttl
=> 22352

# List of all certificates in database.
FirebaseIdToken::Certificates.all
=> [{"ec8f292sd30224afac5c55540df66d1f999d" => <OpenSSL::X509::Certificate: [...]

# Returns the respective certificate of a given Key ID.
FirebaseIdToken::Certificates.find('ec8f292sd30224afac5c55540df66d1f999d')
=> <OpenSSL::X509::Certificate: subject=<OpenSSL::X509 [...]

```

### Downloading in Rails

If you are using Rails it's preferred that you download the certificates in a background job, you can use [ActiveJob](http://guides.rubyonrails.org/active_job_basics.html) in this case.
```ruby
class RequestCertificatesJob < ApplicationJob
  queue_as :default

  def perform
    FirebaseIdToken::Certificates.request_anyway
  end
end
```

Then set it as a cron job, I recommend running it once every hour or every 30 minutes, you choose it. Normally the certificates expiration time is around 5 to 6 hours, but it's good to perform it in a small fraction of this time.

You can use [whenever](https://github.com/javan/whenever) to do this.

### Verifying Tokens

Pass the Firebase ID Token to `FirebaseIdToken::Signature.verify` and it will return the token payload if everything is ok:

```ruby
# The returning values are just for illustration.
FirebaseIdToken::Signature.verify(token)
=> {"iss"=>"https://securetoken.google.com/firebase-id-token", "name"=>"Bob Test", "picture"=>"https://lh3.googleusercontent.com/some_picture.jpg", "aud"=>"firebase-id-token", "auth_time"=>1493176176, "user_id"=>"lOcoO3p3iH4lZ2k5oqw3t5e6poUm2", "sub"=>"lOcoO3p3iH4lZ2k5oqw3t5e6poUm2", "iat"=>1493176179, "exp"=>1493179779, "email"=>"bob@email.com", "email_verified"=>true, "firebase"=>{"identities"=>{"google.com"=>["109058030492384365"], "email"=>["bob@email.com"]}, "sign_in_provider"=>"google.com"}}
```

When either the signature is false or the token is invalid, it will return `nil`:
```ruby
FirebaseIdToken::Signature.verify(fake_token)
=> nil

FirebaseIdToken::Signature.verify('aaaaaa')
=> nil
```

**WARNING:** If you try to verify a signature without any certificates in Redis database it will raise a `FirebaseIdToken::Exceptions::NoCertificatesError`.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
