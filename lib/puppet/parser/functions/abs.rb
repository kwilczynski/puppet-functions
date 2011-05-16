#
# abs.rb
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
  newfunction(:abs, :type => :rvalue, :doc => <<-EOS
Returns the absolute value of the argument given.

Prototype:

    abs(x)

Where x is a numeric value.

For example:

  Given the following statements:

    $a = -1
    $b = -1.0

    notice abs($a)
    notice abs($b)

  The result will be as follows:

    notice: Scope(Class[main]): 1
    notice: Scope(Class[main]): 1.0
    EOS
  ) do |arguments|

    #
    # We put arguments that are strings back into the array.  This is
    # to ensure that whenever we call this function from within the
    # Puppet manifest or alternatively form a template it will always
    # do the right thing ...
    #
    if arguments.is_a?(String)
      arguments = [ arguments ]
    end

    if arguments.size < 1
      raise(Puppet::ParseError, "abs(): Wrong number " +
        "of arguments given (#{arguments.size} for 1)")
    end

    value = arguments.shift
    klass = value.class

    # This should cover all the generic numeric types present in Puppet ...
    unless klass.ancestors.include?(Numeric) or value.is_a?(String)
      raise(Puppet::ParseError, 'abs(): Requires ' +
        'a numeric value to work with')
    end

    # Numbers in Puppet are often string-encoded which is troublesome ...
    if value.is_a?(String)
      if value.match(/^-?(?:\d+)(?:\.\d+){1}$/) # Floating point
        value = value.to_f
      elsif value.match(/^-?\d+$/)              # Integer
        value = value.to_i
      else
        raise(Puppet::ParseError, 'abs(): Requires ' +
          'either integer or float to work with')
      end
    end

    # We have a numeric value to handle ...
    result = value.abs

    return result
  end
end

# vim: set ts=2 sw=2 et :
