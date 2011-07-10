#
# type.rb
#
# Copyright 2011 Puppet Labs Inc.
# Copyright 2011 Krzysztof Wilczynski
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Puppet::Parser::Functions
  newfunction(:type, :type => :rvalue, :doc => <<-EOS
Returns the name of type for any arbitrary value given.

Prototype:

    type(x)

Where x is a value of an arbitrary type.

For example:

  Given the following statements:

    $a = true
    $b = 1
    $c = 1.0
    $d = ""
    $e = []
    $f = {}

    notice type($a)
    notice type($b)
    notice type($c)
    notice type($d)
    notice type($e)
    notice type($f)

  The result will be as follows:

    notice: Scope(Class[main]): Boolean
    notice: Scope(Class[main]): Integer
    notice: Scope(Class[main]): Float
    notice: Scope(Class[main]): String
    notice: Scope(Class[main]): Array
    notice: Scope(Class[main]): Hash

  Known issues:

    Both non-negative integer and floating-point numbers are conceptually
    a strings in Puppet e.g. both 1.0 and "1.0" will be strings in Puppet
    whereas -1.0 and "-1.0" differ as former in this case is a floating-point
    number with latter being simply a string.

    We try accommodate for this and parse any string with an attempt to cast
    into an appropriate numeric type but this may not be absolutely perfect.
    EOS
  ) do |arguments|

    #
    # We put arguments that are strings back into the array.  This is
    # to ensure that whenever we call this function from within the
    # Puppet manifest or alternatively form a template it will always
    # do the right thing ...
    #
    arguments.to_a if arguments.is_a?(String)

    raise Puppet::ParseError, "type(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)"  if arguments.size < 1

    value = arguments.shift
    klass = value.class

    #
    # This should cover all the generic types present in Puppet ...
    #
    # There is one caveat -- numeric values like 1 and 1.0 will be
    # turn into string by Puppet and therefore they will appear as
    # such in the results ...
    #
    unless klass.ancestors.include?(Numeric) or
      [Array, Hash, String, TrueClass, FalseClass].include?(klass)
      raise Puppet::ParseError, 'type(): Unknown type given'
    end

    # Numbers in Puppet are often string-encoded which is troublesome ...
    if value.is_a?(String)
      if value.match(/^-?(?:\d+)(?:\.\d+){1}$/) # Floating point
        value = value.to_f
      elsif value.match(/^-?\d+$/)              # Integer
        value = value.to_i
      end
      # We re-assign type again ...
      klass = value.class
    end

    #
    # We note that Integer is the parent to Bignum and Fixnum ...
    # Plus we claim name Boolean for FalseClass and TrueClass ...
    #
    klass = case klass.to_s
      when /^(?:Big|Fix)num$/      then 'Integer'
      when /^(?:False|True)Class$/ then 'Boolean'
      else klass
    end

    klass
  end
end

# vim: set ts=2 sw=2 et :
