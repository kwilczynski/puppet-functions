#
# empty.rb
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
  newfunction(:empty, :type => :rvalue, :doc => <<-EOS
Returns true if given array type or hash type has no elements or when a string
value is empty and false otherwise.

Prototype:

    empty(x)

Where x is either an array, a hash or a string value.

For example:

  Given the following statements:

    $a = ""
    $b = "abc"
    $c = []
    $d = ["d", "e", "f"]
    $e = {}
    $f = { "x" => 1, "y" => 2, "z" => 3 }

    notice empty($a)
    notice empty($b)
    notice empty($c)
    notice empty($d)
    notice empty($e)
    notice empty($f)

  The result will be as follows:

    notice: Scope(Class[main]): true
    notice: Scope(Class[main]): false
    notice: Scope(Class[main]): true
    notice: Scope(Class[main]): false
    notice: Scope(Class[main]): true
    notice: Scope(Class[main]): false
    EOS
  ) do |*arguments|

    #
    # This is to ensure that whenever we call this function from within
    # the Puppet manifest or alternatively form a template it will always
    # do the right thing ...
    #
    arguments = arguments.shift if arguments.first.is_a?(Array)

    raise Puppet::ParseError, "empty(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)" if arguments.size < 1

    value = arguments.shift

    unless [Array, Hash, String].include?(value.class)
      raise Puppet::ParseError, 'empty(): Requires either array, hash ' +
        'or string type to work with'
    end

    value.empty?
  end
end

# vim: set ts=2 sw=2 et :
