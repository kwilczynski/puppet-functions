#
# values_at.rb
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
  newfunction(:values_at, :type => :rvalue, :doc => <<-EOS
Returns

Prototype:

    values_at()

Where

For example:

  Given the following statements:

  The result will be as follows:

    EOS
  ) do |arguments|

    raise(Puppet::ParseError, "values_at(): Wrong number of " +
      "arguments given (#{arguments.size} for 1)") if arguments.size < 1

    array = arguments.shift

    unless array.is_a?(Array)
      raise(Puppet::ParseError, 'values_at(): Requires an array to work with')
    end

    indices = *arguments # Get them all ...

    # Anything to collect?  If not then just return empty array ...
    return [] unless indices

    # This is to detect single empty string as first arguments ...
    if indices.empty?
      raise(Puppet::ParseError, 'values_at(): Requires ' +
        'a numeric value or range to work with')
    end

    result       = []
    indices_list = []

    indices.each do |i|
      klass = i.class

      # This should cover all the generic numeric types present in Puppet ...
      unless [Bignum, Fixnum, Float, String].include?(klass)
        raise(Puppet::ParseError, 'values_at(): Requires ' +
          'a numeric value or range to work with')
      end

      if i.is_a?(String)
        # We support rages given as a..b, a...b and a-b which resembles a..b ...
        if m = i.match(/^(-?\d+)(\.{2,3}|\-)(-?\d+)$/)
          start = m[1]
          stop  = m[3]
          range = m[2]

          start = start.to_i
          stop  = stop.to_i

          range = case range
            when /^(\.{2}|\-)$/ then (start .. stop)
            when /^\.{3}$/      then (start ... stop) # Exclusive of last element ...
          end

          # We pass Range object along to the Array object to do the right thing ...
          indices_list << range
        elsif i.match(/^-?(?:\d+)(?:\.\d+){1}$/) # Floating point
          i = i.to_f
          indices_list << i
        elsif i.match(/^-?\d+$/)                 # Integer
          i = i.to_i
          indices_list << i
        else
          raise(Puppet::ParseError, 'values_at(): Requires ' +
            'either integer or float to work with')
        end
      else
        indices_list << i
      end
    end

    #
    # We remove nil values as they make no sense in Puppet DSL
    # and turn them into an empty string ...
    #
    result = indices_list.collect { |i| i ? array[i] : '' }

    return result
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
