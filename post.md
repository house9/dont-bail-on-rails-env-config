# Managing Secrets: `credentials.yml` vs. Environment Variables in Ruby on Rails

Deploying a Ruby on Rails application involves making crucial decisions about how to manage sensitive information and configuration settings. One of the pivotal choices you'll encounter is whether to rely on Rails' built-in `credentials.yml` file or opt for the simplicity and flexibility of environment variables (`ENV`).

Both approaches have their strengths and considerations, and the choice you make can significantly impact your application's security, deployment workflow, and maintenance.

## `credentials.yml`

By default, Rails assumes you will be using `credentials.yml` and a master key to decrypt this file. There are many tutorials available on the internet for managing the credentials file. I recommend this one:

[The Complete Guide to Ruby on Rails Encrypted Credentials](https://web-crunch.com/posts/the-complete-guide-to-ruby-on-rails-encrypted-credentials)

### Quick steps for using `credentials.yml`:

1. Ensure you have both `credentials.yml.enc` and `master.key` present in your application.
2. Edit or add credentials by running `bin/rails credentials:edit`.
3. Deploy your application and ensure the `RAILS_MASTER_KEY` environment variable is set on your server or PaaS platform.

## Environment Variables

To manage your secrets and configuration using environment variables (`ENV`) in your Ruby on Rails application, I recommend the following steps:

- Delete the credentials file and `master.key` if they exist:
  - `rm config/credentials.yml.enc config/master.key`
- Manage your development ENV with [direnv](https://direnv.net/) or the [dotenv-rails](https://github.com/bkeepers/dotenv) gem.
  - create a `.env` or `.envrc` file as needed
- Set `SECRET_KEY_BASE` in your staging and production environments:

  - Generate a new key base for each environment using `bin/rails secret`.
  - This step isn't needed in the development environment.

- Most Platform as a Service (PaaS) providers allow you to manage ENV values via a web portal or CLI tools. Common PaaS for Rails deployments include [render.com](https://render.com/), [heroku.com](https://www.heroku.com/home), and [fly.io](https://fly.io/):

```sh
heroku config:set SECRET_KEY_BASE=`bin/rails secret`
```

```sh
flyctl secrets set SECRET_KEY_BASE=`bin/rails secret`
```

## Which to Choose?

Choosing between `credentials.yml` and environment variables largely depends on the deployment strategy, security considerations, and personal preference. Here are a few pointers:

**Cloud-based deployments:** If you're deploying to a cloud service that natively supports environment variable configuration (like Heroku or AWS), using `ENV` might be more straightforward.

**Containerized environments:** For Docker or Kubernetes deployments, environment variables can offer more flexibility and fit better with the infrastructure's ethos.

**On-premises or traditional hosting:** If you're deploying on traditional servers or on-premises, the Rails `credentials.yml` approach can offer a more consolidated and familiar way of managing secrets.

**Team Comfort:** If you're working in a team environment, consider the learning curve and comfort level of all team members. Some might be more familiar with one approach over the other.

Ultimately, the choice should align with your team's comfort level, deployment strategy, and security requirements.

## Why Use ENV Over `credentials.yml`?

**Simplicity:** Storing sensitive information in environment variables is straightforward. It eliminates the complexities of encryption and managing a `credentials.yml.enc` file.

**Portability:** Environment variables work across various deployment environments, simplifying the deployment process in containerized settings.

**Compatibility:** Some cloud platforms natively support environment variables, making deployment easier.

**Security Best Practices:** Using environment variables aligns with the Twelve-Factor App methodology, promoting code and configuration separation.

**Ease of Rotation:** Changing secrets, like API keys, is often simpler with environment variables than with the `credentials.yml.enc` file. No need to commit changes and re-deploy your code, changes can be deployed at will.

**External Configuration Management:** Some organizations with configuration management tools prefer environment variables as they fit into existing processes.

**Access Control:** Environment variables' access control can be managed via the hosting platform, ensuring only authorized individuals can view or modify them.

## Why Use the Credentials File Over ENV?

**Encryption & Security:** The `credentials.yml.enc` file is encrypted, ensuring that the file's contents remain secure even if accessed.

**Centralized Configuration:** A single file for credentials offers a centralized location, aiding comprehension and management.

**Version Control Friendly:** The encrypted `credentials.yml.enc` file can be safely version controlled, helping in change tracking without revealing secrets.

**Built-in Rails Support:** With Rails' native support, developers can easily manage encrypted credentials. As new configuration is added to the application developers simply need to get the lastest code and now they have access to the new values. If using ENV each developer needs to manage their own `.env` files and keep them up to date manually.

## Concluding thoughts

Managing secrets effectively is paramount for the security and integrity of your Rails applications. Whether you choose `credentials.yml` or environment variables, ensure that you understand the implications of each approach and align your choice with the needs and practices of your development and deployment environments.

## Additional Notes

### Ensuring your application has the needed configuration

### database credentials

When using ENV to manage your secrets I prefer setting a `DATABASE_URL` ENV instead of keeping track of the database host, user and password in separate values.

Postgres database url has the following structure: `postgres://username:password@host:port/database_name`

For example: `postgres://vinz:Clortho@localhost:5432/development_database`.

Rails will automatically use `DATABASE_URL` and even merge it will settings in the `config/database.yml` file. For clarity you may want to explicity update the config file:

```
production:
  <<: *default
  url: <%= ENV['DATABASE_URL'] %>
```

See the rails guides for more detail: [Configuring a Database](https://guides.rubyonrails.org/configuring.html#configuring-a-database)

### Git and Secrets

Ensure sensitive information stays out of version control:

- For environment variables, exclude the `.env` file from version control. Add `.env` to your `.gitignore` file.
- For `credentials.yml`, the `master.key` should never be in version control. Ensure `master.key` is also in `.gitignore`. Securely share and manage `master.key` among necessary team members.

### Resolving the `secret_key_base` Missing Error

While deploying Rails apps to production for the first time you may encounter the following error:

```
ArgumentError: Missing`secret_key_base`for 'production' environment, set this string with `bin/rails credentials:edit`
```

The resolution depends on your secrets management choice:

- **Credentials File**:
  - Set the `RAILS_MASTER_KEY` environment variable on your server or PaaS.
  - This should match the `master.key` used to encrypt the credentials file.
  - Note: All new Rails apps have an entry in the credentials file for `secret_key_base`.
- **ENV**:
  - Set the `SECRET_KEY_BASE` environment variable on your server or PaaS.
  - You can use `bin/rails secret` to generate a new value.

Certainly, here's a section at the end of your blog post that discusses missing configuration and includes code samples for returning `nil` vs. raising a `KeyError` for both `ENV` and `Rails.application.credentials`:

### Handling Missing Configuration

When dealing with missing configuration, you have the choice of whether to raise errors or, at the very least, log the absence of configuration settings. In my practice, I tend to favor raising errors because in a production environment, the absence of essential configuration can lead to undesirable behavior.

- `credentials.yml`: missing configuration will return `nil` by default or you can use the bang version `!` to raise an error

```ruby
# Assuming credentials.yml does not contain 'some_api_key'
Rails.application.credentials.some_api_key # => nil
Rails.application.credentials.some_api_key! # => :some_api_key is blank (KeyError)
```

- `ENV`: ENV is a Hash like object and has a `fetch` method which can be used to ensure configuration is set

```ruby
# Assuming the environment variable is not set
ENV['SOME_API_KEY'] # => nil
ENV.fetch('SOME_API_KEY') # => key not found: "SOME_API_KEY" (KeyError)
```
