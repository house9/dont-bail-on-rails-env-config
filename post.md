# credentials.yml or environment variables when deploying Ruby on Rails applications

Deploying a Ruby on Rails application involves making crucial decisions about how to manage sensitive information and configuration settings. One of the pivotal choices you'll encounter is whether to rely on Rails' built-in `credentials.yml` file or opt for the simplicity and flexibility of environment variables (`ENV`).

Both approaches have their strengths and considerations, and the choice you make can significantly impact your application's security, deployment workflow, and maintenance.

## credentials.yml

By default Rails assumes you will be using `credentials.yml` and a master key to decrypt this file. There are many tutorials out on the interwebs for managing credentails file, I recommend this one:

[The Complete Guide to Ruby on Rails Encrypted Credentials](https://web-crunch.com/posts/the-complete-guide-to-ruby-on-rails-encrypted-credentials)

## Environment variables

To manage your secrets and configuration using environment variables (`ENV`) in your Ruby on Rails application I recommend the following steps:

- delete the credentials file and master.key if it exists
  - `rm config/credentials.yml.enc config/master.key`
- manage your development ENV with [direnv](https://direnv.net/) or the [dotenv-rails](https://github.com/bkeepers/dotenv) gem
- use `DATABASE_URL` in your database.yml file:

```
production:
  <<: *default
  url: <%= ENV['DATABASE_URL'] %>
```

- set `SECRET_KEY_BASE` in your staging and production environments
  - you can generate a new key base for each environment `bin/rails secret`
  - this is not needed in the development env

Most Platform as a service (PaaS) allow you to manage ENV values via web portal or cli tools, i.e. [render.com](https://render.com/), [heroku.com](https://www.heroku.com/home) and [fly.io](https://fly.io/).

```sh
heroku config:set SECRET_KEY_BASE=`bin/rails secret`
```

```sh
flyctl secrets set SECRET_KEY_BASE=`bin/rails secret`
```

## Why ENV instead of credentials file

**Simplicity:**
Storing sensitive information in environment variables is a straightforward and easy-to-understand approach. There's no need to deal with the complexities of encryption or managing a credentials.yml.enc file, making it more accessible for developers who are new to Rails.

**Portability:**
Environment variables can work across different deployment environments (development, production, staging, etc.) without the need for separate credential files for each environment. This can simplify the deployment process, especially in containerized environments.

**Compatibility with Hosting Services:**
Some hosting services and cloud platforms provide built-in support for managing environment variables, making it a convenient choice when deploying to platforms like Heroku, AWS, or Google Cloud.

**Security Best Practices:**
Storing secrets as environment variables aligns with the "Twelve-Factor App" methodology, which emphasizes using environment variables for configuration. It promotes the separation of configuration from code and enhances security.

**Ease of Rotation:**
When you need to rotate or change secrets (e.g., API keys, tokens), updating environment variables can be simpler than re-encrypting and managing credentials in the credentials.yml.enc file.

**External Configuration Management:**
Organizations that have established configuration management systems and tools may prefer managing configuration through environment variables as part of their existing processes.

**Access Control:**
Access control for environment variables can be managed through the hosting platform or server environment, allowing administrators to control who has access to sensitive data more easily.

## Why use the credentials file instead of ENV

TODO: add reasons

## Which to choose

Use the right technique for your organization.

I prefer using ENV, especially if deploying to PaaS platforms.

TODO: expand

## Etc

### git and secrets

TODO: notes about not checking `.env` or `master.key` into your source code repository

### Missing `secret_key_base` for 'production' environment

So your rails app is running on localhost and everything is working great; now it is time to deploy to production:

```
ArgumentError: Missing `secret_key_base` for 'production' environment, set this string with `bin/rails credentials:edit`
```

The fix will differ depending on the way you are managing secrets:

- credentails file:
  - set the `RAILS_MASTER_KEY` environment varible on your server or PaaS
  - must be set the value of the `master.key` that was used to encrypt the credentails file
  - NOTE: all new rails app have an entry in the credentails file for the `secret_key_base`
- ENV:
  - set the `SECRET_KEY_BASE` environment variable on your server or Paas
  - it can be set to a new value per environment, `bin/rails secret`
