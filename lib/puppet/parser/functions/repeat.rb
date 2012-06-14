#
# repeat.rb
#
# Copyright 2012 Puppet Labs Inc.
# Copyright 2012 Krzysztof Wilczynski
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
  newfunction(:repeat, :type => :rvalue, :doc => <<-EOS
Returns either a string representation or an array containing an arbitrary
value given repeated desired number of times.

Prototype:

    repeat(x, n, b)

Where x is either a numeric type or a string value and n is a non-negative
integer which denotes how many times the value of x will be repeated, and
where the value of b is a boolean, or a string value given in one of the
following boolean-alike forms:

  When given as either '1', 't', 'y', 'true' or 'yes' it will evaluate
  as true whereas when given as either '0', 'f', 'n', 'false' or 'no'
  then it will evaluate as false.

This changes the type of the output from the default being a coerced string
to an array containing the value of x repeated desired number of times.

For example:

  Given the following statements:

    $a = 'a'
    $b = 'xyz'
    $c = 1
    $d = -1.0

    notice repeat($a, 10)
    notice repeat($a, 10, true)
    notice repeat($b, 10)
    notice repeat($b, 10, true)
    notice repeat($c, 10, false)
    notice repeat($c, 10, true)
    notice repeat($d, 10, true)

  The result will be as follows:

    notice: Scope(Class[main]): aaaaaaaaaa
    notice: Scope(Class[main]): a a a a a a a a a a
    notice: Scope(Class[main]): xyzxyzxyzxyzxyzxyzxyzxyzxyzxyz
    notice: Scope(Class[main]): xyz xyz xyz xyz xyz xyz xyz xyz xyz xyz
    notice: Scope(Class[main]): 1111111111
    notice: Scope(Class[main]): 1 1 1 1 1 1 1 1 1 1
    notice: Scope(Class[main]): -1.0 -1.0 -1.0 -1.0 -1.0 -1.0 -1.0 -1.0 -1.0 -1.0

  Known issues:

    A very large value of n might lead to extranerous memory consumption.
    EOS
  ) do |*arguments|
    #
    # This is to ensure that whenever we call this function from within
    # the Puppet manifest or alternatively form a template it will always
    # do the right thing ...
    #
    arguments = arguments.shift if arguments.first.is_a?(Array)

    raise Puppet::ParseError, "repeat(): Wrong number of arguments " +
      "given (#{arguments.size} for 2)" if arguments.size < 1

    item  = arguments.shift

    unless item.class.ancestors.include?(Numeric) or item.is_a?(String)
      raise Puppet::ParseError, 'repeat(): Requires either numeric type ' +
        'or string value to work with'
    end

    count = arguments.shift

    unless count.class.ancestors.include?(Numeric) or count.is_a?(String)
      raise Puppet::ParseError, 'repeat(): Requires a numeric type to work with'
    end

    # Numbers in Puppet are often string-encoded which is troublesome ...
    if count.is_a?(String) and count.match(/^-?\d+$/)
      # An Integer value should match ...
      count = count.to_i

      # Array cannot be of an negative size ...
      raise Puppet::ParseError, 'repeat(): Requires a non-negative integer '  +
        'value to work with' if count < 0
    else
      raise Puppet::ParseError, 'repeat(): Requires an integer value to work with'
    end

    # By default we return coerced string instead of an array ...
    boolean = arguments.shift || false

    # We can have either true, false, or string which resembles boolean ...
    unless [TrueClass, FalseClass, String].include?(boolean.class)
      raise Puppet::ParseError, 'repeat(): Requires either boolean type ' +
        'or string value to work with'
    end

    if boolean.is_a?(String)
      # We consider all the boolean-alike values too ...
      boolean = case boolean
        #
        # This is how undef looks like in Puppet ...
        # We yield false in this case.
        #
        when /^$/, ''              then false # Empty string will be false ...
        when /^(1|t|y|true|yes)$/  then true
        when /^(0|f|n|false|no)$/  then false
        when /^(undef|undefined)$/ then false # This is not likely to happen ...
        else
          raise Puppet::ParseError, 'repeat(): Unknown type of boolean given'
      end
    end

    # Create new array pre-populated relevant number of times ...
    value = Array.new(count, item)

    # Check if we suppose to return a string or an array ..?
    boolean ? value : value.join
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
