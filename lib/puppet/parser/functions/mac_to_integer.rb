#
# mac_to_integer.rb
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
  newfunction(:mac_to_integer, :type => :rvalue, :doc => <<-EOS
Returns an integer value which is a representation of a MAC address given as string.

Prototype:

    mac_to_integer(s)

Where s is a string value that resembles IEEE 802 standard (including the
Microsoft variant), Cisco style or Sun Microsystems MAC address.

For example:

  Given the following statements:

    $a = 'C8:2A:14:44:66:59'
    $b = 'C8-2A-14-44-66-59'
    $c = 'C82A.1444.6659'

    notice mac_to_integer($a)
    notice mac_to_integer($b)
    notice mac_to_integer($c)

  The result will be as follows:

    notice: Scope(Class[main]): 220083054208601
    notice: Scope(Class[main]): 220083054208601
    notice: Scope(Class[main]): 220083054208601
  EOS
  ) do |*arguments|
    #
    # This is to ensure that whenever we call this function from within
    # the Puppet manifest or alternatively form a template it will always
    # do the right thing ...
    #
    arguments = arguments.shift if arguments.first.is_a?(Array)

    raise Puppet::ParseError, "mac_to_integer(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)"  if arguments.size < 1

    mac_address = arguments.shift

    raise Puppet::ParseError, 'mac_to_integer(): Requires a string type ' +
      'to work with' unless mac_address.is_a?(String)

    is_mac_address = case mac_address
      #
      # The IEEE 802 standard MAC address which is a six groups of two
      # hexadecimal digits and has ":" (single colon) as delimiter.
      #
      # Microsoft variant has the same overall format but uses "-" (single
      # hyphen) as delimiter instead.
      #
      # Note that both version have hexadecimal digital zero-padded ...
      #
      when /^([0-9a-fA-F]{2}[:\-]){5}[0-9a-fA-F]{2}$/ then true
      #
      # Cisco uses MAC address which is a three groups of four hexadecimal
      # digital as has "." (single dot) as delimiter ...
      #
      when /^([0-9a-fA-F]{4}\.){2}[0-9a-fA-F]{4}$/ then true
      #
      # Sun Microsystems standard MAC address is very similar to the
      # IEEE 802 standard with the difference that hexadecimal digits
      # are not zero-padded at all and should be lower-case ...
      #
      when /^((0|[1-9]{1,2}|[a-fA-F]{1,2}):){5}
              (0|[1-9]{1,2}|[a-fA-F]{1,2}){2}$/x then true
      # Otherwise no match ...
      else
        false
    end

    # We do not check for IP Address correctness but for string validity ...
    raise Puppet::ParseError, 'mac_to_integer(): Requires a MAC address ' +
      'to work with' unless is_mac_address

    mac_address = mac_address.tr('.:-', '')

    mac_address.unpack('A2A2A2A2A2A2').inject(0) do |result,value|
      result = result * (2**8) + value.hex
      result
    end
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
