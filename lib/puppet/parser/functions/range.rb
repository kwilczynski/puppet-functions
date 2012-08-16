#
# range.rb
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
  newfunction(:range, :type => :rvalue, :doc => <<-EOS
Returns

Prototype:

    range()

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

    # We support more than one argument but at least one is mandatory ...
    raise(Puppet::ParseError, "range(): Wrong number of " +
      "arguments given (#{arguments.size} for 1)") if arguments.size < 1

    if arguments.size > 1
      start = arguments[0]
      stop  = arguments[1]

      type = '..' # We select simplest type for Range available in Ruby ...

    elsif arguments.size > 0
      value = arguments[0]

      if m = value.match(/^(\w+)(\.\.\.?|\-)(\w+)$/)
        start = m[1]
        stop  = m[3]

        type = m[2]

      elsif value.match(/^.+$/)
        raise(Puppet::ParseError, 'range(): Unable to compute range ' +
          'from the value given')
      else
        raise(Puppet::ParseError, 'range(): Unknown format of range given')
      end
    end

      # Check whether we have integer value if so then make it so ...
      if start.match(/^\d+$/)
        start = start.to_i
        stop  = stop.to_i
      else
        start = start.to_s
        stop  = stop.to_s
      end

      range = case type
        when /^(\.\.|\-)$/ then (start .. stop)
        when /^(\.\.\.)$/  then (start ... stop) # Exclusive of last element ...
      end

      result = range.collect { |i| i } # Get them all ... Pokemon ...

    return result
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
