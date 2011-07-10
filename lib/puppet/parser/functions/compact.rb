#
# compact.rb
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
  newfunction(:compact, :type => :rvalue, :doc => <<-EOS
Returns a new array with all empty or not-initialised elements removed.

Prototype:

    compact(a)

Where a is an array type.

For example:

  Given the following statements:

    $a = ["a", "", "c", "", "e", "f", ""]
    $b = ["", "x", "y", ""]

    notice compact($a)
    notice compact($b)

  The result will be as follows:

    notice: Scope(Class[main]): a c e f
    notice: Scope(Class[main]): x y
    EOS
  ) do |arguments|

    raise Puppet::ParseError, "compact(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)" if arguments.size < 1

    array = arguments.shift

    raise Puppet::ParseError, 'compact(): Requires an array type ' +
      'to work with' unless array.is_a?(Array)

    #
    # We are almost like Array#compact in Ruby with the difference that
    # alongside any nil we also remove any empty string if present ...
    #
    array.reject { |i| i.is_a?(String) and i.empty? or i.nil? }
  end
end

# vim: set ts=2 sw=2 et :
