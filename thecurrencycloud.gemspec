# -*- encoding: utf-8 -*-
# stub: thecurrencycloud 0.5 ruby lib

Gem::Specification.new do |s|
  s.name = "thecurrencycloud"
  s.version = "0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Simon Reed"]
  s.date = "2014-02-03"
  s.description = "Implements the complete functionality of The Currency Cloud ConnectAPI."
  s.email = ["simonpreed@gmail.com"]
  s.files = [".gitignore", ".travis.yml", "Gemfile", "Gemfile.lock", "LICENSE", "README.md", "Rakefile", "lib/thecurrencycloud.rb", "lib/thecurrencycloud/bank.rb", "lib/thecurrencycloud/beneficiary.rb", "lib/thecurrencycloud/client.rb", "lib/thecurrencycloud/payment.rb", "lib/thecurrencycloud/price.rb", "lib/thecurrencycloud/trade.rb", "lib/thecurrencycloud/version.rb", "test/client_test.rb", "test/fixtures/authentication_close.json", "test/fixtures/authentication_success.json", "test/fixtures/custom_api_error.json", "test/fixtures/payment_add.json", "test/fixtures/prices_market.json", "test/fixtures/trade_execute_success.json", "test/fixtures/trades.json", "test/helper.rb", "test/thecurrencycloud_test.rb", "thecurrencycloud.gemspec"]
  s.homepage = "http://github.com/simonreed/thecurrencycloud/"
  s.rubygems_version = "2.2.0"
  s.summary = "A library which implements the complete functionality of v1 of The Currency Cloud Connect API."
  s.test_files = ["test/client_test.rb", "test/fixtures/authentication_close.json", "test/fixtures/authentication_success.json", "test/fixtures/custom_api_error.json", "test/fixtures/payment_add.json", "test/fixtures/prices_market.json", "test/fixtures/trade_execute_success.json", "test/fixtures/trades.json", "test/helper.rb", "test/thecurrencycloud_test.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<fakeweb>, ["~> 1.3"])
      s.add_development_dependency(%q<jnunemaker-matchy>, ["~> 0.4"])
      s.add_development_dependency(%q<mocha>, ["~> 0.9"])
      s.add_development_dependency(%q<shoulda>, ["~> 3.0.1"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_runtime_dependency(%q<hashie>, ["~> 1.0"])
      s.add_runtime_dependency(%q<httparty>, ["~> 0.8"])
      s.add_runtime_dependency(%q<rest-client>, [">= 0"])
    else
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<fakeweb>, ["~> 1.3"])
      s.add_dependency(%q<jnunemaker-matchy>, ["~> 0.4"])
      s.add_dependency(%q<mocha>, ["~> 0.9"])
      s.add_dependency(%q<shoulda>, ["~> 3.0.1"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<hashie>, ["~> 1.0"])
      s.add_dependency(%q<httparty>, ["~> 0.8"])
      s.add_dependency(%q<rest-client>, [">= 0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<fakeweb>, ["~> 1.3"])
    s.add_dependency(%q<jnunemaker-matchy>, ["~> 0.4"])
    s.add_dependency(%q<mocha>, ["~> 0.9"])
    s.add_dependency(%q<shoulda>, ["~> 3.0.1"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<hashie>, ["~> 1.0"])
    s.add_dependency(%q<httparty>, ["~> 0.8"])
    s.add_dependency(%q<rest-client>, [">= 0"])
  end
end
