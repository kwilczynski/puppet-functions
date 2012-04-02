#
# fact.rb
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
  newfunction(:fact, :type => :rvalue, :doc => <<-EOS
Returns

Prototype:

    fact()

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

    if arguments.size < 1
      raise(Puppet::ParseError, "fact(): Wrong number " +
        "of arguments given (#{arguments.size} for 1)")
    end

    values = *arguments

    # Prepare for processing ...
    values = values.inject([]) do |array, v|
      klass = v.class

      if not [Array, String].include?(klass)
        raise(Puppet::ParseError, 'fact(): Requires ' +
          'either array or string to work with')
      end

      # We concatenate the array we build with the array we have found ...
      v.is_a?(Array) ? array += v : array << v

      array
    end

    result = []

    # Process what we have so far ...
    values.each do |i|

      if not i.is_a?(String)
        raise(Puppet::ParseError, 'fact(): Requires ' +
          'fact to be a string')
      end

      if i.empty?
        result << '' # We simply do not even bother ...
      else
        #
        # Get the value of interest from Facter ...
        #
        # Puppet does not have a concept of returning neither undef nor nil
        # back for use within the Puppet DSL and empty string is as closest
        # to actual undef as you we can get at this point in time ...
        #
        i = lookupvar(i) ||= ''

        result << i
      end
    end

    # We only have one value?
    result = values.size > 1 ? result : result[0]

    return result
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
