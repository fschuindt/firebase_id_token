# Ruby Firebase ID Token verifier (pre-release)

![Alt text](https://api.travis-ci.org/fschuindt/firebase_id_token.svg?branch=master)
[![Code Climate](https://codeclimate.com/github/fschuindt/firebase_id_token/badges/gpa.svg)](https://codeclimate.com/github/fschuindt/firebase_id_token)
[![Issue Count](https://codeclimate.com/github/fschuindt/firebase_id_token/badges/issue_count.svg)](https://codeclimate.com/github/fschuindt/firebase_id_token)
[![Test Coverage](https://codeclimate.com/github/fschuindt/firebase_id_token/badges/coverage.svg)](https://codeclimate.com/github/fschuindt/firebase_id_token/coverage)
[![Inline docs](http://inch-ci.org/github/fschuindt/firebase_id_token.svg?branch=master)](http://inch-ci.org/github/fschuindt/firebase_id_token)

A Ruby gem to verify the signature of Firebase ID Tokens. It uses Redis to store Google's x509 certificates and manage their expiration time, so you don't need to request Google's API in every execution and can access it as fast as reading from memory.

It also checks the JWT payload parameters as recommended [here](https://firebase.google.com/docs/auth/admin/verify-id-tokens) by Firebase official documentation.

## Pre-release Notes

**This gem was developed recently and needs real world feedback.**

If you are going to use it in production environment, please note that I am still testing it. It has realistc RSpec examples that uses real X509 certificates and signed JWT to perform tests and I can say it's working great. But using it implies in security risks, you should be aware.

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
gem 'firebase_id_token', '~> 1.2.2'
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
  config.redis = Redis.new(host: '10.0.1.1', port: 6380, db: 15)
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

#### Certificates Info

Checks the presence of certificates in Redis database.
```ruby
FirebaseIdToken::Certificates.present?
=> true
```

How many seconds until the certificates expiration.
```ruby
FirebaseIdToken::Certificates.ttl
=> 22352
```

Lists all certificates in database.
```ruby
FirebaseIdToken::Certificates.all
=> [{"ec8f292sd30224afac5c55540df66d1f999d" => <OpenSSL::X509::Certificate: [...]]
```

Finds the respective certificate of a given Key ID.
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
    task request_anyway: :environment do
      FirebaseIdToken::Certificates.request_anyway
    end
  end
end
```

And in your `config/schedule.rb` you might have:
```ruby
every 1.hour do
  rake 'firebase:certificates:request_anyway'
end
```

Then:
```
$ whenever --update-crontab
```

I recommend running it once every hour or every 30 minutes, it's up to you. Normally the certificates expiration time is around 4 to 6 hours, but it's good to perform it in a small fraction of this time.

When developing and testing you should just run the task:
```
$ rake firebase:certificates:request
```

*And remember, you need the Redis server to be running.*

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

**WARNING:** If you try to verify a signature without any certificates in Redis database it will raise a `FirebaseIdToken::Exceptions::NoCertificatesError`.

#### Payload Structure

In case you need, here's a example of the payload structure from a Google login in JSON.
```json
{  
   "iss":"https://securetoken.google.com/firebase-id-token",
   "name":"Ugly Bob",
   "picture":"https://someurl.com/photo.jpg",
   "aud":"firebase-id-token",
   "auth_time":1492981192,
   "user_id":"theUserID",
   "sub":"theUserID",
   "iat":1492981200,
   "exp":33029000017,
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

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
