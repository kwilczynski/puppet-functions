#
# array.rb
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
  newfunction(:array, :type => :rvalue, :doc => <<-EOS
Returns

Prototype:

    array()

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

    raise Puppet::ParseError, "array(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)" if arguments.size < 1

    values = *arguments
    result = []

    # Complex data structures are not our thing as we are not recursive ...
    values.each do |i|
      if i.is_a?(Array)
        # Add content of given array to ours ...
        result += i
      elsif i.is_a?(Hash)
        # Make any key-value pair set of subsequent elements in our array ...
        i.each { |k,v| result += [k, v] }
      else
        # Just add whatever it is there ...
        result << i
      end
    end

    result
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
