# RadbearMobile

This is a common set of features and tools tailored for a native iOS or Android mobile app that includes a remote Rails api.

## Main Features
1. mobile app authentication including "frictionless" option
1. framework to aid in mobile api
1. client stub generation

## Usage

### Server
As a prerequisite, set up devise with a model named User using the normal devise instructions.

Although I do have plans to make this a public open source project, it is currently a private repository on Github so you will need to include credentials in your Gemfile to connect to the repository. Here is an example of how to configure that:

`gem 'radbear_mobile', :git => 'https://radbear:ke8spade@github.com/garyfoster/radbear_mobile.git', :branch => 'master'`
`bundle`

To install radbear_mobile, you must run the generator: 

`rails g radbear_mobile:install`
`rake db:migrate`

This will then create the initializer in the /config/initializers directory with the default values set within the generator template as well as copy all the files to the project.

### Client
Generate client stubs by running the following rake task:

`rake client_stubs:generate`

This will create client stubs for each model in the /tmp/client_stubs folder

## Development

### Test Suite

To generate items related to the dummy app, first cd into the /spec/dummy directory, then you can run `rails generate` commands.

This project contains a "dummy" app to run test against, see /spec/dummy. To prepare the test database, run the following command:

`rake app:db:migrate`
`rake app:db:test:prepare`

To run the test suite, run the following command:

`rake`

### Point Projects to Local Source Instead of Github

When refactoring and modifying code in this project while developing other projects, you may want your other project to point to the local source rather than the remote on Github. In your client project, you still need to keep the Gemfile pointing to the Github location but you can override your bundler setting like as follows:

`bundle config local.radbear_mobile /Users/garyfoster/Documents/Projects/radbear_mobile`

to undo this and revert to the remote github repository:

`bundle config --delete local.radbear_mobile`
