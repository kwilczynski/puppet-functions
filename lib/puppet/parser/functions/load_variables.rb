#
# load_variables.rb
#

module Puppet::Parser::Functions
  newfunction(:load_variables, :type => :statement, :doc => <<-EOS
This function will allow for loading variables from an external YAML
file and expose them for further use inside the Puppet manifest file ...

For example:

Given following content of the data.yaml file:

  ---
  host1.example.com:
    foo: bar
    baz: quux
    question: 42
  host2.example.com:
    abc: def
    this: that
    darth: vader

Then calling load_variables in Puppet manifest file as follows:

  load_variables("/etc/puppet/data.yaml", $fqdn)

Will result in addition of variables $foo, $baz and $question
for matching host name as per the variable $fqdn ...

Another example which uses per-host file:

Given following content of the file data-host1.example.com.yaml:

  ---
  foo: bar

Then when we call load_variables like this:

  load_variables("/etc/puppet/data-$fqdn.yaml")

This will result in a variable $foo being added and ready for use.
    EOS
  ) do |*arguments|
    #
    # This is to ensure that whenever we call this function from within
    # the Puppet manifest or alternatively form a template it will always
    # do the right thing ...
    #
    arguments = arguments.shift if arguments.first.is_a?(Array)

    raise(Puppet::ParseError, "Wrong number of arguments " +
      "given (#{arguments.size} for 2)") if arguments.size < 2

    data = {}

    file = arguments[0]
    key  = arguments[1] if arguments[1]

    if File.exists?(file)

      begin
        data = YAML.load_file(file)
      rescue => error
        raise(Puppet::ParseError, "Unable to load data " +
          "from the file `%s': %s" % file, error.to_s)
      end

      raise(Puppet::ParseError, "Data in the file `%s' " +
        "is not a hash" % file) unless data.is_a?(Hash)

      data = ((data[key] and data[key].is_a?(Hash)) ? data[key] : {}) if key
    end

    data.each { |param, value| setvar(param, strinterp(value)) }
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
