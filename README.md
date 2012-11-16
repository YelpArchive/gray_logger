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
    Rails.configuration.middleware.insert_after Rack::Lock, "GrayLogger::Middleware", :configuration => gray_logger_config
  rescue => e
    $stderr.puts("GrayLogger not configured. Please add config/gray_logger.yml")
  end

  ActionController::Base.send(:include, ::GrayLogger::HelperMethods)
  ````

4. To install the gray_logger proxy:
  ````ruby
  config.logger = Rack::GrayLogger::Proxy.new(Syslogger.new("path..."))
  ````

## Usage

In Rails you can use the "gray_logger" method to add new fields to be logged to Graylog2.

e.g.
```ruby
gray_logger.login_name = "darkswoop"
```

After the request is finished and shortly before the response is send to the user GrayLogger will send your Log-Message to the Graylog2 server.


