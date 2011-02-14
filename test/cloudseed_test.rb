require "test/unit"
require "cloudseed"

class CloudSeed::TestCase < Test::Unit::TestCase
  undef_method :default_test if method_defined? :default_test

  def self.test(name, &block)
    define_method("test #{name.inspect}", &block)
  end
end
