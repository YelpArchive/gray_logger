# GrayLogger

## Overview

GrayLogger is a small logging tool that allows you to simply log anything you want to graylog2 from within your Rack application.

## Installation

1. Add GrayLogger to your Gemfile

	```ruby
	# in Gemfile
	gem "gray_logger"
	```

2. run the generator
	```shell
	rails g gray_logger:install
	```
	or if you are using Rails 2.3.x
	```shell
	script/generate gray_logger:install
    ```

3. configure GrayLogger in config/gray_logger.yml
   ```yaml
   development:
     host: 127.0.0.1
     port:  12201
     facility: "myapp"
   ```

## Usage

In Rails you can use the "gray_logger" method to add new fields to be logged to Graylog2.

e.g.
```ruby
gray_logger.login_name = "darkswoop"
```

After the request is finished and shortly before the response is send to the user GrayLogger will send your Log-Message to the Graylog2 server.


