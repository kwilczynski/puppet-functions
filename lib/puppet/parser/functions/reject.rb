#
# reject.rb
#
# Copyright 2012 Krzysztof Wilczynski
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
  newfunction(:reject, :type => :rvalue, :doc => <<-EOS
Returns a new array containing all elements that do not match given regular expression.

Prototype:

    reject(a, r)

Where a is an array type and r is the regular expression pattern.

For example:

  Given the following statements:

    $a = ['a', 'b', 'c', 'abc', 0, 1.0]
    $b = ['d', 'e', 'f', 'def', 1, 2.0]
    $c = ['x', 'y', 'z', 'zyx', 2, 3.0]

    notice reject($a, 'a')
    notice reject($b, 'x')
    notice reject($c, 'z.x')

  The result will be as follows:

    notice: Scope(Class[main]): b c 0 1.0
    notice: Scope(Class[main]): d e f def 1 2.0
    notice: Scope(Class[main]): x y z 2 3.0

  Known issues:

    Currently, rejecting both integer and floating-point values is NOT possible.

    We only support Ruby compatible regular expressions.  For more information
    about Ruby's regular expression engine and its functionality, please see
    the following: http://www.ruby-doc.org/core/Regexp.html.
    EOS
  ) do |*arguments|
    #
    # This is to ensure that whenever we call this function from within
    # the Puppet manifest or alternatively form a template it will always
    # do the right thing ...
    #
    arguments = arguments.shift if arguments.first.is_a?(Array)

    raise Puppet::ParseError, "reject(): Wrong number of arguments " +
      "given (#{arguments.size} for 2)" if arguments.size < 2

    array = arguments.shift

    raise Puppet::ParseError, 'reject(): First argument requires ' +
      'an array type to work with' unless array.is_a?(Array)

    regular_expression = arguments.shift

    raise Puppet::ParseError, 'reject(): Second argument requires ' +
      'a string type to work with' unless regular_expression.is_a?(String)

    #
    # Any invalid and/or unsupported regular expression pattern will yield an
    # error and therefore we have to take care of that ...
    #
    begin
      regular_expression = Regexp.new(regular_expression)
    rescue SyntaxError, TypeError, RegexpError
      raise Puppet::ParseError, 'reject(): An invalid regular expression pattern'
    end

    # We can only make a match against elements that are strings ...
    array.reject {|i| i.is_a?(String) and i.match(regular_expression) }
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
