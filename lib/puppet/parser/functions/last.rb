#
# last.rb
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
  newfunction(:last, :type => :rvalue, :doc => <<-EOS
Returns last element from an array given.

Prototype:

    last(a)

Where a is an array type.

For example:

  Given the following statements:

    $a = ["a", "b", "c"]
    $b = ["d", "e", "f"]

    notice last($a)
    notice last($b)

  The result may look as follows:

    notice: Scope(Class[main]): c
    notice: Scope(Class[main]): f
    EOS
  ) do |arguments|

    raise Puppet::ParseError, "last(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)" if arguments.size < 1

    array = arguments.shift

    raise Puppet::ParseError, 'last(): Requires an array ' +
      'to work with' unless array.is_a?(Array)

    array.last
  end
end

# vim: set ts=2 sw=2 et :
