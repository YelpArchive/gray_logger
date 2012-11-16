# GrayLogger

## Overview

GrayLogger is a small logging tool that allows you to simply log anything you want to graylog2 from within your Rack application.

## Installation

1. Add GrayLogger to your Gemfile

	```ruby
	# in Gemfile
	gem "gray_logger"
	```

2. configure GrayLogger in config/gray_logger.yml
   ```yaml
   development:
     host: 127.0.0.1
     port:  12201
     facility: "myapp"
   ```

3. if you are using Rails 2.3 please add the following code to an initializer:
  ```ruby
  require 'gray_logger'
  begin
    gray_logger_config = YAML.load(File.read(Rails.root.join("config/gray_logger.yml")))[Rails.env]
    Rails.configuration.middleware.insert_after Rack::Lock, "Rack::GrayLogger::Middleware", :configuration => gray_logger_config
  rescue => e
    $stderr.puts("GrayLogger not configured. Please add config/gray_logger.yml")
  end

  ActionController::Base.send(:include, ::GrayLogger::HelperMethods)
  ````

4. To install the gray_logger proxy:
  ````ruby
  Rack::GrayLogger.proxy.proxied_logger = Syslogger.new("path...")
  config.logger = Rack::GrayLogger.proxy
  ````

## Usage

In Rails you can use the "gray_logger" method to add new fields to be logged to Graylog2.

#### Buckets
You can use buckets to collect fields and send them in one request to GrayLog2:

````ruby
gray_logger.bucket(:financial_data).account_nr = 123
gray_logger.bucket(:financial_data).iban = 98767
gray_logger.flush_bucket(:financial_data) # sends the collected fields as one log message to GrayLog2 and clears the bucket
````
When the request is finished all remaining buckets are send to GrayLog2 so you don't have to care if you only want to collect your data.

#### After Request Log

There is a special bucket that is used for logging possible exceptions and request information.
When you are using the Rack::GrayLogger::Proxy the proxy will use this bucket to collect the loglines
from the proxied logger. Feel free to add your own fields using:

````ruby
gray_logger.after_request_log.user_login = current_user.login
````

#### Automatic Logging

Automatic Logging is enabled by default. That means after the request is done GrayLogger will automatically
log to GrayLog2. If you don't want this automatic logging disable it by setting automatic_logging to false.

````yaml
development:
  host: ...
  port:  ...
  facility: ...
  automatic_logging: false
````

