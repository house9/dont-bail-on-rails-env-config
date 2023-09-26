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

**Encryption & Security:** credentials.yml.enc is an encrypted file, ensuring that even if the file is accessed, the secrets contained within remain safe.

**Centralized Configuration:** Having a single file for credentials provides a centralized location, making it easier to understand where sensitive configuration lives.

**Version Control Friendly:** Since credentials.yml.enc is encrypted, it can be safely checked into version control systems. This aids in change tracking and sharing a common setup without exposing the actual secrets.

**Built-in Rails Support:** As part of the Rails framework, developers can leverage Rails' native support and documentation for managing encrypted credentials.

## Which to choose

Choosing between `credentials.yml` and environment variables largely depends on the deployment strategy, security considerations, and personal preference. Here are a few pointers:

**Cloud-based deployments:** If you're deploying to a cloud service that natively supports environment variable configuration (like Heroku or AWS), using ENV might be more straightforward.

**Containerized environments:** For Docker or Kubernetes deployments, environment variables can offer more flexibility and fit better with the infrastructure's ethos.

**On-premises or traditional hosting:** If you're deploying on traditional servers or on-premises, the Rails credentials.yml approach can offer a more consolidated and familiar way of managing secrets.

Ultimately, the choice should align with your team's comfort level, deployment strategy, and security requirements.

## Etc...

### git and secrets

Always ensure that sensitive information is kept out of version control:

For environment variables, never check in the `.env` file. You can add `.env` to your `.gitignore` file to prevent it from being accidentally committed.

For Rails' `credentials.yml`, the `master.key` file should never be checked into version control. Again, make sure `master.key` is in your `.gitignore` file.

By following these practices, you help prevent sensitive data leaks and potential security breaches.

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
