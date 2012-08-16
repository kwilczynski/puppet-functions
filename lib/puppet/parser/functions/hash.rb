#
# hash.rb
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
  newfunction(:hash, :type => :rvalue, :doc => <<-EOS
Returns

Prototype:

    hash()

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
      raise(Puppet::ParseError, "hash(): Wrong number " +
        "of arguments given (#{arguments.size} for 1)")
    end

    values = *arguments

    #
    # Prepare for processing ...
    # Complex data structures are not our thing as we are not recursive ...
    #
    values = values.inject([]) do |array, v|
      if v.is_a?(Array)
        # We concatenate the array we build with the array we have found ...
        array += v
      elsif v.is_a?(Hash)
        # Make any key-value pair set of subsequent elements in our array ...
        v.each { |k,v| array += [k, v] }
      else
        array << v
      end

      array
    end

    size = values.size

    if size.odd?
      raise(Puppet::ParseError, 'hash(): Unable to compute ' +
       'hash with odd number of arguments given')
    end

    result = {}

    # Process what we have so far ...
    begin
      # This is to make it compatible with older version of Ruby ...
      values = values.flatten
      result = Hash[*values]
    rescue Exception
      raise(Puppet::ParseError, 'hash(): Unable to compute ' +
        'hash from arguments given')
    end

    return result
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
