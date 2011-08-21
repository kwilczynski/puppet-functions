#
# num2str.rb
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
  newfunction(:num2str, :type => :rvalue, :doc => <<-EOS
Returns a string representation of any numeric data type after conversion.

Prototype:

    num2str(n)

Where n is a numeric value.

For example:

  Given the following statements:

    $a = 1
    $b = 1.0
    $c = -1
    $d = -1.0

    notice num2str($a)
    notice num2str($b)
    notice num2str($c)
    notice num2str($d)

  The result will be as follows:

    notice: Scope(Class[main]): 1
    notice: Scope(Class[main]): 1.0
    notice: Scope(Class[main]): -1
    notice: Scope(Class[main]): -1.0
    EOS
  ) do |*arguments|
    #
    # This is to ensure that whenever we call this function from within
    # the Puppet manifest or alternatively form a template it will always
    # do the right thing ...
    #
    arguments = arguments.shift if arguments.first.is_a?(Array)

    raise Puppet::ParseError, "num2str(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)" if arguments.size < 1

    numeric = arguments.shift

    # This should cover all the generic numeric types present in Puppet ...
    unless numeric.class.ancestors.include?(Numeric) or numeric.is_a?(String)
      raise Puppet::ParseError, 'num2str(): Requires a numeric type to work with'
    end

    # Numbers in Puppet are often string-encoded which is troublesome ...
    if numeric.is_a?(String)
      if numeric.match(/^-?(?:\d+)(?:\.\d+){1}$/) # Floating point
        numeric = numeric.to_f
      elsif numeric.match(/^-?\d+$/)              # Integer
        numeric = numeric.to_i
      else
        raise Puppet::ParseError, 'num2str(): Requires either integer ' +
          'or float value to work with'
      end
    end

    # We have a numeric value to handle ...
    numeric.to_s
  end
end

# vim: set ts=2 sw=2 et :
