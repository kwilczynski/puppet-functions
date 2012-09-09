#
# integer_to_ip.rb
#
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
  newfunction(:integer_to_ip, :type => :rvalue, :doc => <<-EOS
Returns a string value which is an IP address upon conversion from an integer value.

Prototype:

    integer_to_ip(n)

Where n is a numeric value.

For example:

  Given the following statements:

    $a = 2130706433

    notice integer_to_ip($a)

  The result will be as follows:

    notice: Scope(Class[main]): 127.0.0.1

  Known issues:

    Currently we only support IPv4 addressing.
  EOS
  ) do |*arguments|
    #
    # This is to ensure that whenever we call this function from within
    # the Puppet manifest or alternatively form a template it will always
    # do the right thing ...
    #
    arguments = arguments.shift if arguments.first.is_a?(Array)

    raise Puppet::ParseError, "integer_to_ip(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)"  if arguments.size < 1

    ip_integer = arguments.shift

    # This should cover all the generic numeric types present in Puppet ...
    unless ip_integer.class.ancestors.include?(Numeric) or ip_integer.is_a?(String)
      raise Puppet::ParseError, 'integer_to_ip(): Requires a numeric type ' +
        'to work with'
    end

    # Should capture any floating-point values here ...
    if ip_integer.is_a?(String)
      if ip_integer.match(/^-?\d+$/)
        ip_integer = ip_integer.to_i
      else
        raise Puppet::ParseError, 'integer_to_ip(): Requires an integer ' +
          'value to work with'
      end
    end

    if ip_integer < 0
      raise Puppet::ParseError, 'integer_to_ip(): Requires a non-negative ' +
        'integer value to work with'
    end

    # Converting back to an IP address ...
    [ip_integer].pack('N').unpack('C4').join('.')
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
