# Documentation

edgeSDK documentation, included in this repo in the root directory, is built with [Jekyll](https://jekyllrb.com). The docs may be run locally.

## Prerequisites

To run our documentation locally you will need a copy of following software installed on your system.

- [https://nodejs.org](NodeJS) v 8.9.4
- [Ruby](https://www.ruby-lang.org/en/documentation/installation/)

## Installation

- Install [Bundler](https://bundler.io) with ```gem install bundler```
- Run ```bundle install``` to install the Ruby dependencies, like Jekyll.
- **Windows Users:** Read [this guide](https://jekyllrb.com/docs/windows/) to install Jekyll

## Running documentation locally

- Run ```bundle exec jekyll serve``` to serve content on a local server ***Note:** The included _config.yml file is an example. You can customize the [config file](https://jekyllrb.com/docs/configuration/#serve-command-options) or create a copy to make use of the Jekyll environment variables.
- Add the ```--verbose``` or ```--trace``` flags for debug information
- use ```bundle exec jekyll clean``` to clean _site folder, Jekyll metadata and .sass-cache

## Contributing

Found a bug or a type? Message us at support.sdk@mimik.com or create a pull request to let us know!

## License

Unless otherwise noted, use of the mimik edgeSDK is licensed under our [License Agreement](http://developers.mimik360.com/license.html) and the code shown on GitHub is available under the [MIT License](http://opensource.org/licenses/MIT).
