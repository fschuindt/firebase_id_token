# Ruby Firebase ID Token verifier

[![Actions Status](https://github.com/fschuindt/firebase_id_token/workflows/Test/badge.svg?branch=master)](https://github.com/fschuindt/firebase_id_token/actions?query=workflow%3ATest)
[![Test Coverage](https://codeclimate.com/github/fschuindt/firebase_id_token/badges/coverage.svg)](https://codeclimate.com/github/fschuindt/firebase_id_token/coverage)
[![Code Climate](https://codeclimate.com/github/fschuindt/firebase_id_token/badges/gpa.svg)](https://codeclimate.com/github/fschuindt/firebase_id_token)
[![Issue Count](https://codeclimate.com/github/fschuindt/firebase_id_token/badges/issue_count.svg)](https://codeclimate.com/github/fschuindt/firebase_id_token)
[![Inline docs](http://inch-ci.org/github/fschuindt/firebase_id_token.svg?branch=master)](http://inch-ci.org/github/fschuindt/firebase_id_token)

A Ruby gem to verify the signature of Firebase ID Tokens (JWT). It uses Redis to store Google's x509 certificates and manage their expiration time, so you don't need to request Google's API in every execution and can access it as fast as reading from memory.

It also checks the JWT payload parameters as recommended [here](https://firebase.google.com/docs/auth/admin/verify-id-tokens) by Firebase official documentation.

Feel free to open any issue or to [contact me](https://fschuindt.github.io/blog/about/) directly.  
Any contribution is welcome.

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
gem 'firebase_id_token', '~> 3.0.0'
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
  config.redis = Redis.new
  config.project_ids = ['your-firebase-project-id']
end
```

- `redis` with a `Redis` instance must be supplied. You can configure your Redis details here. Example: `Redis.new(host: '10.0.1.1', port: 6380, db: 15)`.
- `project_ids` must be an Array.

*If you want to verify signatures from more than one Firebase project, just add more Project IDs to the list.*

## Usage

You can get a glimpse of it by reading our RSpec output on your machine. It's
really helpful. But here is a complete guide:

### Downloading Certificates

Before verifying tokens, you need to download Google's x509 certificates.

To do it, simply:
```ruby
FirebaseIdToken::Certificates.request
```

It will download the certificates and save it in Redis, but only if the Redis certificates database is empty. To force download and override of the Redis database, use:
```ruby
FirebaseIdToken::Certificates.request!
```

Google give us information about the certificates' expiration time, it's used to set a Redis TTL (Time-To-Live) when saving it. By doing so, the certificates will be automatically deleted after its expiration.

#### Certificates Info

Checks the presence of certificates in the Redis database.
```ruby
FirebaseIdToken::Certificates.present?
=> true
```

How many seconds until the certificate's expiration.
```ruby
FirebaseIdToken::Certificates.ttl
=> 22352
```

Lists all certificates in the database.
```ruby
FirebaseIdToken::Certificates.all
=> [{"ec8f292sd30224afac5c55540df66d1f999d" => <OpenSSL::X509::Certificate: [...]]
```

Finds the respective certificate of a given Key ID (`kid`).
```ruby
FirebaseIdToken::Certificates.find('ec8f292sd30224afac5c55540df66d1f999d')
=> <OpenSSL::X509::Certificate: subject=<OpenSSL::X509 [...]>
```

#### Downloading in Rails

If you are using Rails, it's clever to download certificates in a cron task, you can use [whenever](https://github.com/javan/whenever).

**Example**

*Read whenever's guide on how to set it up.*

Create your task in `lib/tasks/firebase.rake`:
```ruby
namespace :firebase do
  namespace :certificates do
    desc "Request Google's x509 certificates when Redis is empty"
    task request: :environment do
      FirebaseIdToken::Certificates.request
    end

    desc "Request Google's x509 certificates and override Redis"
    task force_request: :environment do
      FirebaseIdToken::Certificates.request!
    end
  end
end
```

And in your `config/schedule.rb` you might have:
```ruby
every 1.hour do
  rake 'firebase:certificates:force_request'
end
```

Then:
```
$ whenever --update-crontab
```

I recommend running it once every hour or every 30 minutes, it's up to you. Normally the certificates expiration time is around 4 to 6 hours, but it's good to perform it in a small fraction of this time.

When developing, you should just run the task:
```
$ rake firebase:certificates:request
```

*You need Redis to be running.*

### Verifying Tokens

Pass the Firebase ID Token to `FirebaseIdToken::Signature.verify` and it will return the token payload if everything is ok:

```ruby
FirebaseIdToken::Signature.verify(token)
=> {"iss"=>"https://securetoken.google.com/firebase-id-token", "name"=>"Bob Test", [...]}
```

When either the signature is false or the token is invalid, it will return `nil`:
```ruby
FirebaseIdToken::Signature.verify(fake_token)
=> nil

FirebaseIdToken::Signature.verify('aaaaaa')
=> nil
```

#### WARNING!

##### Expired tokens can point to long gone certificates

Notice that often when the token have expired, the Firebase certificate can be already missing from the Firebase servers. In these cases, `verify` will return `nil`.

If you want to take specific actions in such cases, here's a solution suggested by the user [cfanpnk](https://github.com/fschuindt/firebase_id_token/issues/29#issuecomment-751137511):

1. Use `verify!` to raise an exception.
2. Rescue `FirebaseIdToken::Exceptions::CertificateNotFound` and return `401`.
3. The client app will refresh the token if expired.

More details [here](https://github.com/fschuindt/firebase_id_token/issues/29).

##### Trying to verify tokens without downloaded certificates will raise an error

If you try to verify a signature without any certificates in Redis database, it will raise a `FirebaseIdToken::Exceptions::NoCertificatesError`.

##### "I keep on getting `nil` on `verify`"

Poorly synchronized clocks will sometimes make the server think the token's `iat` is on the future, which will render the token as invalid. Make sure your server's or development system's clock is correctly set. On macOS, some people reported success by unchecking and checking the "Set date and time automatically" configuration checkbox. See [here](https://github.com/fschuindt/firebase_id_token/issues/21#issuecomment-623133926).

#### Payload Structure

In case you need, here's a example of the payload structure from a Google login in JSON.
```json
{  
   "iss":"https://securetoken.google.com/{{YOUR_FIREBASE_APP_ID}}",
   "name":"Ugly Bob",
   "picture":"https://someurl.com/photo.jpg",
   "aud":"{{YOUR_FIREBASE_APP_ID}}",
   "auth_time":1492981192,
   "user_id":"theUserID",
   "sub":"theUserID",
   "iat":1492981200, // needs to be in the past
   "exp":33029000017, // needs to be in the future
   "email":"uglybob@emailurl.com",
   "email_verified":true,
   "firebase":{  
      "identities":{  
         "google.com":[  
            "1010101010101010101"
         ],
         "email":[  
            "uglybob@emailurl.com"
         ]
      },
      "sign_in_provider":"google.com"
   }
}

```

If you're using this snippet for testing, make sure you check the comments in it.

## Testing

```
bundle exec rake rspec
```

### Testing Mode

Just run:
```
FirebaseIdToken.test!
```

By using this mode, the following methods become available.

```ruby
# RSA PRIVATE KEY
FirebaseIdToken::Testing::Certificates.private_key

# CERTIFICATE
FirebaseIdToken::Testing::Certificates.certificate
```

`certificate` will always return the same value. No external HTTP call is performed.

#### Example: Testing in Rails

Describes the following in `test_helper.rb`.

```ruby
class ActiveSupport::TestCase
  setup do
    FirebaseIdToken.test!
  end
end
```

Test example:

```ruby
require 'test_helper'

module Api
  module V1
    module UsersControllerTest < ActionController::TestCase
      setup do
        @routes = Engine.routes
        @user = users(:one)
      end
        
      def create_token(sub: nil)
        _payload = payload.merge({sub: sub})
        JWT.encode _payload, OpenSSL::PKey::RSA.new(FirebaseIdToken::Testing::Certificates.private_key), 'RS256'
      end

      def payload
        # payload.json
      end

      test 'should success get api v1 users ' do
        get :show, headers: create_token(@user.id)
        assert_response :success
      end
    end
  end
end
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
