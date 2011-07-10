#
# reverse.rb
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
  newfunction(:reverse, :type => :rvalue, :doc => <<-EOS
Returns either a new array or string by reversing order of elements within.

Prototype:

    reverse(x)

Where x is either an array type or string value.

For example:

  Given the following statements:

    $a = "abc"
    $b = ["d", "e", "f"]

    notice reverse($a)
    notice reverse($b)

  The result may look as follows:

    notice: Scope(Class[main]): cba
    notice: Scope(Class[main]): f e d
    EOS
  ) do |arguments|

    #
    # We put arguments that are strings back into the array.  This is
    # to ensure that whenever we call this function from within the
    # Puppet manifest or alternatively form a template it will always
    # do the right thing ...
    #
    arguments.to_a if arguments.is_a?(String)

    raise Puppet::ParseError, "reverse(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)" if arguments.size < 1

    value = arguments.shift

    unless [Array, String].include?(value.class)
      raise Puppet::ParseError, 'reverse(): Requires either array ' +
        'or string type to work with'
    end

    value.reverse
  end
end

# vim: set ts=2 sw=2 et :
