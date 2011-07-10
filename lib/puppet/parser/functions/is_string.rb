#
# is_string.rb
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
  newfunction(:is_string, :type => :rvalue, :doc => <<-EOS
Returns true if given arbitrary value is of a string type and false otherwise.

Prototype:

    is_string(x)

Where x is a value of an arbitrary type.

For example:

  Given the following statements:

    $a = true
    $b = 1
    $c = -1
    $d = 1.0
    $e = -1.0
    $f = ""
    $g = []
    $h = {}

    notice is_string($a)
    notice is_string($b)
    notice is_string($c)
    notice is_string($d)
    notice is_string($e)
    notice is_string($f)
    notice is_string($g)
    notice is_string($h)

  The result will be as follows:

    notice: Scope(Class[main]): false
    notice: Scope(Class[main]): false
    notice: Scope(Class[main]): false
    notice: Scope(Class[main]): false
    notice: Scope(Class[main]): false
    notice: Scope(Class[main]): true
    notice: Scope(Class[main]): false
    notice: Scope(Class[main]): false

  Known issues:

    Both non-negative integer and floating-point numbers are conceptually
    strings in Puppet e.g. both 1.0 and "1.0" will be strings in Puppet
    whereas -1.0 and "-1.0" differ as former in this case is a floating-point
    number with latter being simply a string.

    We try accommodate for this and parse any string with an attempt to cast
    into an appropriate numeric type but this may not be absolutely perfect.
    EOS
  ) do |arguments|

    #
    # We put arguments that are strings back into the array.  This is
    # to ensure that whenever we call this function from within the
    # Puppet manifest or alternatively form a template it will always
    # do the right thing ...
    #
    arguments.to_a if arguments.is_a?(String)

    raise Puppet::ParseError, "is_string(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)" if arguments.size < 1

    value = arguments.shift

    # Numbers in Puppet are often string-encoded which is troublesome ...
    if value.is_a?(String)
      if value.match(/^-?(?:\d+)(?:\.\d+){1}$/) # Floating point
        value = value.to_f
      elsif value.match(/^-?\d+$/)              # Integer
        value = value.to_i
      end
    end

    value.is_a?(String)
  end
end

# vim: set ts=2 sw=2 et :
