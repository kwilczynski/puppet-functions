#
# integer_to_mac.rb
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
  newfunction(:integer_to_mac, :type => :rvalue, :doc => <<-EOS
Returns a string value which is a MAC address upon converstion from an integer value.

Prototype:

    integer_to_mac(n)
    integer_to_mac(n, s)
    integer_to_mac(n, s, b)

Where n is a numeric value and s is a string value which resembles one of the
following strings that change resulting MAC address format:

  __IEEE__      -- C8:2A:14:44:66:59 (default)
  __MICROSOFT__ -- C8-2A-14-44-66-59
  __CISCO__     -- C82A.1444.6659

Whereas b is either a boolean type or a string value given in one of the following
boolean-alike forms:

  When given as either '1', 't', 'y', 'true' or 'yes' it will evaluate as true
  making resulting MAC address to be given with all upper-case letters (default)
  whereas when given as either '0', 'f', 'n', 'false' or 'no' then it will in trun
  evaluate as false making resulting MAC address to be given with all lower-case
  letters.

For example:

  Given the following statements:

    $a = 220083054208601

    notice integer_to_mac($a)
    notice integer_to_mac($a, '__CISCO__')
    notice integer_to_mac($a, '__IEEE__', false)

  The result will be as follows:

    notice: Scope(Class[main]): C8:2A:14:44:66:59
    notice: Scope(Class[main]): C82A.1444.6659
    notice: Scope(Class[main]): c8:2a:14:44:66:59
  EOS
  ) do |*arguments|
    #
    # This is to ensure that whenever we call this function from within
    # the Puppet manifest or alternatively form a template it will always
    # do the right thing ...
    #
    arguments = arguments.shift if arguments.first.is_a?(Array)

    # Technically we support three arguments but only first is mandatory ...
    raise Puppet::ParseError, "integer_to_mac(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)"  if arguments.size < 1

    mac_integer = arguments.shift
    delimiter   = arguments.shift || '__IEEE__'
    upper_case  = arguments.shift

    # This should cover all the generic numeric types present in Puppet ...
    unless mac_integer.class.ancestors.include?(Numeric) or mac_integer.is_a?(String)
      raise Puppet::ParseError, 'integer_to_mac(): Requires a numeric type ' +
        'to work with'
    end

    # Should capture any floating-point values here ...
    if mac_integer.is_a?(String)
      if mac_integer.match(/^-?\d+$/)
        mac_integer = mac_integer.to_i
      else
        raise Puppet::ParseError, 'integer_to_mac(): Requires an integer ' +
        'value to work with'
      end
    end

    if mac_integer < 0
      raise Puppet::ParseError, 'integer_to_mac(): Requires a non-negative ' +
        'integer value to work with'
    end

    if delimiter.is_a?(String)
      #
      # We use this special string value because Puppet is rather not easy
      # to work with in terms of passing symbols (there is no support) or
      # numeric values, therefore this ugly solution must do for the time
      # being ...
      #
      delimiter = case delimiter
        when /^__IEEE__$/      then ['A2A2A2A2A2A2', ':'] # C8:2A:14:44:66:59
        when /^__MICROSOFT__$/ then ['A2A2A2A2A2A2', '-'] # C8-2A-14-44-66-59
        when /^__CISCO__$/     then ['A4A4A4',       '.'] # C82A.1444.6659
        else
          raise Puppet::ParseError, 'integer_to_mac(): An unknown delimiter given'
      end
    else
      raise Puppet::ParseError, 'integer_to_mac(): An invalid delimiter type given'
    end

    unless upper_case.nil?
      # We can have either true, false, or string which resembles boolean ...
      unless [TrueClass, FalseClass, String].include?(upper_case.class)
        raise Puppet::ParseError, 'integer_to_mac(): Requires either boolean type ' +
          'or string value to work with'
      end

      if upper_case.is_a?(String)
        # We consider all the boolean-alike values too ...
        upper_case = case upper_case
          #
          # This is how undef looks like in Puppet ...
          # We yield false in this case.
          #
          when /^$/, ''              then false # Empty string will be false ...
          when /^(1|t|y|true|yes)$/  then true
          when /^(0|f|n|false|no)$/  then false
          when /^(undef|undefined)$/ then false # This is not likely to happen ...
          else
            raise Puppet::ParseError, 'integer_to_mac(): Unknown type of boolean given'
        end
      end
    else
      upper_case = true
    end

    # Converting back to a hexadecimal value ...
    mac_string = begin
      string = (1 .. 6).inject([]) do |result,value|
        result << '%02x' % [mac_integer % (2**8)]
        mac_integer = mac_integer / (2**8)
        result
      end

      string.reverse!
      string.join
    end

    mac_string = mac_string.unpack(delimiter[0]).join(delimiter[1])

    # By default we favour upper-case letters in the MAC address ...
    upper_case ? mac_string.tr('a-z', 'A-Z') : mac_string.tr('A-Z', 'a-z')
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
