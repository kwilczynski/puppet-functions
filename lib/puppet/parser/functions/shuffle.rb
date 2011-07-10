#
# shuffle.rb
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
  newfunction(:shuffle, :type => :rvalue, :doc => <<-EOS
Returns either a new array or string by shuffling elements within.

Prototype:

    shuffle(x)

Where x is either an array type or string value.

For example:

  Given the following statements:

    $a = "abcdef"
    $b = ["a", "b", "c", "d", "e", "f"]

    notice shuffle($a)
    notice shuffle($b)

  The result may look as follows:

    notice: Scope(Class[main]): cafdeb
    notice: Scope(Class[main]): e a c d b f
    EOS
  ) do |arguments|

    #
    # We put arguments that are strings back into the array.  This is
    # to ensure that whenever we call this function from within the
    # Puppet manifest or alternatively form a template it will always
    # do the right thing ...
    #
    arguments.to_a if arguments.is_a?(String)

    raise Puppet::ParseError, "shuffle(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)" if arguments.size < 1

    value = arguments.shift

    unless [Array, String].include?(value.class)
      raise Puppet::ParseError, 'shuffle(): Requires either array ' +
        'or string type to work with'
    end

    # Check whether it makes sense to shuffle ...
    if value.size > 1
      # We shuffle in-place and therefore cannot use the original ...
      value = value.clone

      string_given = value.is_a?(String)

      # We turn any string value into an array to be able to shuffle ...
      value = string_given ? value.split('') : value
      size  = value.size

      # Simple implementation of Fisher–Yates in-place shuffle ...
      size.times do |i|
        j = rand(size - i) + i
        value[j], value[i] = value[i], value[j]
      end

      value = string_given ? value.join : value
    end

    value
  end
end

# vim: set ts=2 sw=2 et :