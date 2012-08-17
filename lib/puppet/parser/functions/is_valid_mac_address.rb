#
# is_valid_mac_address.rb
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
  newfunction(:is_valid_mac_address, :type => :rvalue, :doc => <<-EOS
Returns true if given string value is a valid MAC address and false otherwise.

Prototype:

    is_valid_mac_address(s)

Where s is a string value that resembles IEEE 802 standard (including the
Microsoft variant), Cisco style or Sun Microsystems MAC address.


For example:

  Given the following statements:

    $a = '4E:55:35:AD:17:DF'
    $b = '92:1H:8E:8C:89:A5'
    $c = 'A9-79-FA-9D-79-A8'
    $d = '36A0.8B54.9FD7'
    $e = 'C:0:F:F:E:42'
    $f = '0C:C:B:FF:35:5C'

    notice is_valid_mac_address($a)
    notice is_valid_mac_address($b)
    notice is_valid_mac_address($c)
    notice is_valid_mac_address($d)
    notice is_valid_mac_address($e)
    notice is_valid_mac_address($f)

  The result will be as follows:

    notice: Scope(Class[main]): true
    notice: Scope(Class[main]): false
    notice: Scope(Class[main]): true
    notice: Scope(Class[main]): true
    notice: Scope(Class[main]): true
    notice: Scope(Class[main]): false
    EOS
  ) do |*arguments|
    #
    # This is to ensure that whenever we call this function from within
    # the Puppet manifest or alternatively form a template it will always
    # do the right thing ...
    #
    arguments = arguments.shift if arguments.first.is_a?(Array)

    raise Puppet::ParseError, "is_valid_mac_address(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)" if arguments.size < 1

    mac_address = arguments.shift

    raise Puppet::ParseError, 'is_valid_mac_address(): Requires a string type ' +
      'to work with' unless mac_address.is_a?(String)

    result = case mac_address
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

    result
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
