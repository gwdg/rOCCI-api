rOCCI-api - A Ruby OCCI Framework
=================================

[![Build Status](https://secure.travis-ci.org/gwdg/rOCCI-api.png)](http://travis-ci.org/gwdg/rOCCI-api)
[![Dependency Status](https://gemnasium.com/gwdg/rOCCI-api.png)](https://gemnasium.com/gwdg/rOCCI-api)
[![Gem Version](https://fury-badge.herokuapp.com/rb/occi-api.png)](https://badge.fury.io/rb/occi-api)
[![Code Climate](https://codeclimate.com/github/gwdg/rOCCI-api.png)](https://codeclimate.com/github/gwdg/rOCCI-api)

Requirements
------------

### Ruby
* at least version 1.8.7 is required
* Ruby 1.9.3+ is recommended
* RubyGems installed
* rake installed (e.g., `gem install rake`)

### Libraries/packages
* libxslt1-dev/libxslt-devel
* libxml2-dev/libxml2-devel
* **only if using Ruby 1.8.7:** libonig-dev/oniguruma-devel (Linux) or oniguruma (Mac)

### Examples
For distros based on Debian:
~~~
apt-get install ruby rubygems ruby-dev libxslt1-dev libxml2-dev libonig-dev
~~~

For distros based on RHEL:
~~~
yum install libxml2-devel libxslt-devel ruby-devel openssl-devel gcc gcc-c++ ruby rubygems oniguruma-devel
~~~

Installation
------------

### From RubyGems.org

To install the most recent stable version

    gem install rake
    gem install occi-api

To install the most recent beta version

    gem install rake
    gem install occi-api --pre

### From source (dev)

**Installation from source should never be your first choice! Especially, if you are not familiar with RVM, Bundler, Rake and other dev tools for Ruby!**
**However, if you wish to contribute to our project, this is the right way to start.**

To use rOCCI-api from source it is very much recommended to use RVM. [Install RVM](https://rvm.io/rvm/install/) with

    curl -L https://get.rvm.io | bash -s stable --ruby
    rvm install 1.9.3

To build and install the bleeding edge version from master

    git clone git://github.com/gwdg/rOCCI-api.git
    cd rOCCI-api
    gem install bundler
    bundle install
    bundle exec rake install
    rake install

Usage
-----
### Auth

For Basic auth use

    auth = Hashie::Mash.new
    auth.type = 'basic'
    auth.username = 'user'
    auth.password = 'mypass'
 
For Digest auth use

    auth = Hashie::Mash.new
    auth.type = 'digest'
    auth.username = 'user'
    auth.password = 'mypass'

For X.509 auth use
 
    auth = Hashie::Mash.new
    auth.type = 'x509'
    auth.user_cert = '/Path/To/My/usercert.pem'
    auth.user_cert_password = 'MyPassword'
    auth.ca_path = '/Path/To/root-certificates'

### DSL
In your scripts, you can use the OCCI client DSL.

To include the DSL definitions in a script use

    extend Occi::Api::Dsl

To include the DSL definitions in a class use

    include Occi::Api::Dsl

To connect to an OCCI endpoint/server (e.g. running on http://localhost:3300/ )

    # defaults
    options = {
      :endpoint => "http://localhost:3300/",
      :auth => {:type => "none"},
      :log => {:out => STDERR, :level => Occi::Log::WARN, :logger => nil},
      :auto_connect => "value", auto_connect => true,
      :media_type => nil
    }

    connect(:http, options ||= {})

To get the list of available resource, mixin, entity or link types use

    resource_types
    mixin_types
    entity_types
    link_types

To get compute, storage or network descriptions use

    describe "compute"
    describe "storage"
    describe "network"

To get the location of compute, storage or network resources use

    list "compute"
    list "storage"
    list "network"

To get the identifiers of specific mixins in specific mixin types use

    mixin "my_template", "os_tpl"
    mixin "small", "resource_tpl"

To get the identifiers of specific mixins with unknown types use

    mixin "medium"

To get mixin descriptions use

    mixin "medium", nil, true
    mixin "my_template", "os_tpl", true

To get a list of names of all / OS templates / Resource templates mixins use

    mixins
    mixins "os_tpl"
    mixins "resource_tpl"

To create a new compute resource use

    os = mixin 'my_os', 'os_tpl'
    size = mixin 'large', 'resource_tpl'
    cmpt = resource "compute"
    cmpt.mixins << os << size
    cmpt.title = "My VM"
    create cmpt

To get a description of a specific resource use

    describe "/compute/<OCCI_ID>"
    describe "/storage/<OCCI_ID>"
    describe "/network/<OCCI_ID>"

To delete a specific resource use

    delete "/compute/<OCCI_ID>"
    delete "/storage/<OCCI_ID>"
    delete "/network/<OCCI_ID>"

### API
If you need low level access to parts of the OCCI client or need to use more than one instance
at a time, you should use the OCCI client API directly.

To connect to an OCCI endpoint/server (e.g. running on http://localhost:3300/ )

    # defaults
    options = {
      :endpoint => "http://localhost:3300/",
      :auth => {:type => "none"},
      :log => {:out => STDERR, :level => Occi::Log::WARN, :logger => nil},
      :auto_connect => "value", auto_connect => true,
      :media_type => nil
    }

    client = Occi::Api::Client::ClientHttp.new(options ||= {})

All available categories are automatically registered to the OCCI model during client initialization. You can get them via

    client.model

To get the list of available resource, mixin, entity or link types use

    client.get_resource_types
    client.get_mixin_types
    client.get_entity_types
    client.get_link_types

To get compute, storage or network descriptions use

    client.describe "compute"
    client.describe "storage"
    client.describe "network"

To get the location of compute, storage or network resources use

    client.list "compute"
    client.list "storage"
    client.list "network"

To get the identifiers of specific mixins in specific mixin types use

    client.find_mixin "my_template", "os_tpl"
    client.find_mixin "small", "resource_tpl"

To get the identifiers of specific mixins with unknown types use

    client.find_mixin "medium"

To get mixin descriptions use

    client.find_mixin "medium", nil, true
    client.find_mixin "my_template", "os_tpl", true

To get a list of names of all / OS templates / Resource templates mixins use

    client.get_mixins
    client.get_mixins "os_tpl"
    client.get_mixins "resource_tpl"

To create a new compute resource use

    os = client.find_mixin 'my_os', 'os_tpl'
    size = client.find_mixin 'large', 'resource_tpl'
    cmpt = client.get_resource "compute"
    cmpt.mixins << os << size
    cmpt.title = "My VM"
    client.create cmpt

To get a description of a specific resource use

    client.describe "/compute/<OCCI_ID>"
    client.describe "/storage/<OCCI_ID>"
    client.describe "/network/<OCCI_ID>"

To delete a specific resource use

    client.delete "/compute/<OCCI_ID>"
    client.delete "/storage/<OCCI_ID>"
    client.delete "/network/<OCCI_ID>"

### Logging

The OCCI gem includes its own logging mechanism using a message queue. By default, no one is listening to that queue.
A new OCCI Logger can be initialized by specifying the log destination (either a filename or an IO object like
STDOUT) and the log level.

    Occi::Log.new(STDOUT,Occi::Log::INFO)

You can create multiple Loggers to receive the log output.

You can always, even if there is no logger defined, log output using the class methods of OCCI::Log e.g.

    Occi::Log.info("Test message")

Changelog
---------

### Version 4.0
* added extended support for OCCI-OS
* added full support for OS Keystone authentication
* split the code into rOCCI-core, rOCCI-api and rOCCI-cli
* internal changes, refactoring and some bugfixes

### Version 3.1
* added basic OS Keystone support
* added support for PKCS12 credentials for X.509 authN
* updated templates for plain output formatting
* minor client API changes
* several bugfixes

### Version 3.0

* many bugfixes
* rewrote Core classes to use metaprogramming techniques
* added VCR cassettes for reliable testing against prerecorded server responses
* several updates to the OCCI Client
* started work on an OCCI Client using AMQP as transport protocol
* added support for keystone authentication to be used with the OpenStack OCCI server
* updated dependencies
* updated rspec tests
* started work on cucumber features

### Version 2.5

* improved OCCI Client
* improved documentation
* several bugfixes

### Version 2.4

* Changed OCCI attribute properties from lowercase to first letter uppercase (e.g. type -> Type, default -> Default, ...)

### Version 2.3

* OCCI objects are now initialized with a list of attributes instead of a hash. Thus it is easier to check which
attributes are expected by a class and helps prevent errors.
* Parsing of a subset of the OVF specification is supported. Further parts of the specification will be covered in
future versions of rOCCI.

### Version 2.2

* OCCI Client added. The client simplifies the execution of OCCI commands and provides shortcuts for often used steps.

### Version 2.1

* Several improvements to the gem structure and code documentation. First rSpec test were added. Readme has been extended to include instructions how the gem can be used.

### Version 2.0

* Starting with version 2.0 Florian Feldhaus and Piotr Kasprzak took over the development of the OCCI gem. The codebase was taken from the rOCCI framework and improved to be bundled as a standalone gem.

### Version 1.X

* Version 1.X of the OCCI gem has been developed by retr0h and served as a simple way to access the first OpenNebula OCCI implementation.

Development
-----------

Checkout latest version from GIT:

    git clone git://github.com/gwdg/rOCCI-api.git

Change to rOCCI-api folder

    cd rOCCI-api

Install dependencies for deployment

    bundle install

### Code Documentation

[Code Documentation for rOCCI-api by YARD](http://rubydoc.info/github/gwdg/rOCCI-api/)

### Continuous integration

[Continuous integration for rOCCI-api by Travis-CI](http://travis-ci.org/gwdg/rOCCI-api/)

### Contribute

1. Fork it.
2. Create a branch (git checkout -b my_markup)
3. Commit your changes (git commit -am "My changes")
4. Push to the branch (git push origin my_markup)
5. Create an Issue with a link to your branch
