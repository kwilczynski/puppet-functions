#
# to_numeric.rb
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
  newfunction(:to_numeric, :type => :rvalue, :doc => <<-EOS
Returns

Prototype:

    to_numeric()

Where

For example:

  Given the following statements:

  The result will be as follows:

    EOS
  ) do |*arguments|
    #
    # This is to ensure that whenever we call this function from within
    # the Puppet manifest or alternatively form a template it will always
    # do the right thing ...
    #
    arguments = arguments.shift if arguments.first.is_a?(Array)

    raise(Puppet::ParseError, "to_numeric(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)") if arguments.size < 1

    value = arguments[0]
    klass = value.class

    # This should cover all the generic numeric types present in Puppet ...
    unless [Bignum, Fixnum, Float, String].include?(klass)
      raise(Puppet::ParseError, 'to_numeric(): Requires ' +
        'a numeric value to work with')
    end

    if value.is_a?(String)
      if value.match(/^-?(?:\d+)(?:\.\d+){1}$/) # Floating point
        value = value.to_f
      elsif value.match(/^0x[\da-fA-F]+$/)      # Hexadecimal
        value = value.to_i(16)
      elsif value.match(/^0[0-7]+$/)            # Octal
        value = value.to_i(8)
      elsif value.match(/^-?\d+$/)              # Integer
        value = value.to_i
      elsif value.match(/^$/)                   # Empty string
        value = 0
      else
        raise(Puppet::ParseError, 'to_numeric(): Unable to convert into numeric')
      end
    end

    # We should have numeric value at this point ...
    result = value

    return result
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
