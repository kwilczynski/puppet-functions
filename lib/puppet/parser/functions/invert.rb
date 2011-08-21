#
# invert.rb
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
  newfunction(:invert, :type => :rvalue, :doc => <<-EOS
Returns a new hash type that has all the keys from a given hash as values
and all the values as keys.

Prototype:

    invert(h)

Where h is a hash type.

For example:

  Given the following statements:

    $a = { 'a' => 1, 'b' => 2, 'c' => 3 }
    $b = { 'def' => 123, 'xyz' => 456 }

    notice $a
    notice $b
    notice invert($a)
    notice invert($b)

  The result will be as follows:

    notice: Scope(Class[main]): a1b2c3
    notice: Scope(Class[main]): xyz456def123
    notice: Scope(Class[main]): 1a2b3c
    notice: Scope(Class[main]): 123def456xyz
    EOS
  ) do |*arguments|

    #
    # This is to ensure that whenever we call this function from within
    # the Puppet manifest or alternatively form a template it will always
    # do the right thing ...
    #
    arguments = arguments.shift if arguments.first.is_a?(Array)

    raise Puppet::ParseError, "invert(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)" if arguments.size < 1

    hash = arguments.shift

    raise Puppet::ParseError, 'invert(): Requires a hash type ' +
      'to work with' unless hash.is_a?(Hash)

    hash.invert
  end
end

# vim: set ts=2 sw=2 et :
