#
# is_valid_ip_address.rb
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
  newfunction(:is_valid_ip_address, :type => :rvalue, :doc => <<-EOS
Returns true if given string value is a valid IPv4 or IPv6 address and false otherwise.

Prototype:

    is_valid_ip_address(s)

Where s is a string value that resembles IPv4 or IPv6 address.

For example:

  Given the following statements:

    $a = '10.0.0.1'
    $b = '255.255.255.256'
    $c = '2620:0:1cfe:face:b00c::3'
    $d = 'google.com'

    notice is_valid_ip_address($a)
    notice is_valid_ip_address($b)
    notice is_valid_ip_address($c)
    notice is_valid_ip_address($d)

  The result will be as follows:

    notice: Scope(Class[main]): true
    notice: Scope(Class[main]): false
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

    raise Puppet::ParseError, "is_valid_ip_address(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)" if arguments.size < 1

    ip_address = arguments.shift

    raise Puppet::ParseError, 'is_valid_ip_address(): Requires a string type ' +
      'to work with' unless ip_address.is_a?(String)

    # This is probably impossible as IPAddr is part of the Ruby Core ...
    begin
      require 'ipaddr'
    rescue LoadError
      raise Puppet::ParseError, 'is_valid_ip_address(): Unable to load IPAddr library'
    end

    result = begin
      ip_address = IPAddr.new(ip_address)
      ip_address.ipv4? or ip_address.ipv6?
    rescue ArgumentError
      false
    end

    result
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
