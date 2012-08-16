#
# count.rb
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
  newfunction(:count, :type => :rvalue, :doc => <<-EOS
Returns

Prototype:

    count()

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

    # We technically support two arguments but only first is mandatory ...
    raise Puppet::ParseError, "count(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)" if arguments.size < 1

    value = arguments.shift

    unless [Array, Hash, String].include?(value.class)
      raise Puppet::ParseError, 'count(): Requires either array, hash ' +
        'or string type to work with'
    end

    item = *arguments

    if item
      # The String#count is different than in other classes ...
      if value.is_a?(Array)
        value = value.count(item)
      elsif value.is_a?(Hash)
        value = value.keys.count(item)
      elsif value.is_a?(String)
        value = value.count(*item)
      end
    else
      # No item to look for and count?  Then just return current size ...
      value = value.size
    end

    value
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
