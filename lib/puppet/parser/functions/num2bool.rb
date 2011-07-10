#
# num2bool.rb
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
  newfunction(:num2bool, :type => :rvalue, :doc => <<-EOS
Returns a boolean type after conversion from numeric value which resembles boolean.

Prototype:

    num2bool(n)

Where n is a numeric value given in one of the following boolean-alike forms:

  When given as either 1, 1.0, or any positive numeric value it will evaluate
  as true whereas when given as either 0, 0.0, or any negative value then it
  will evaluate as false.

For example:

  Given the following statements:

    $a = 1
    $b = -1
    $c = 1.0
    $d = 0.0

    notice num2bool($a)
    notice num2bool($b)
    notice num2bool($c)
    notice num2bool($d)

  The result will be as follows:

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

    raise Puppet::ParseError, "num2bool(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)" if arguments.size < 1

    numeric = arguments.shift

    # This should cover all the generic numeric types present in Puppet ...
    unless numeric.class.ancestors.include?(Numeric) or numeric.is_a?(String)
      raise Puppet::ParseError, 'num2bool(): Requires a numeric type to work with'
    end

    # Numbers in Puppet are often string-encoded which is troublesome ...
    if numeric.is_a?(String)
      if numeric.match(/^-?(?:\d+)(?:\.\d+){1}$/) # Floating point
        numeric = numeric.to_f
      elsif numeric.match(/^-?\d+$/)              # Integer
        numeric = numeric.to_i
      else
        raise Puppet::ParseError, 'num2bool(): Requires either integer ' +
          'or float value to work with'
      end
    end

    # We yield true for any positive number and false otherwise ...
    numeric > 0 ? true : false
  end
end

# vim: set ts=2 sw=2 et :
