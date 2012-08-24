#
# array_intersection.rb
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
  newfunction(:array_intersection, :type => :rvalue, :doc => <<-EOS
Returns a new array that only contains items common in both arrays given,
with all duplicate items removed.

Prototype:

    array_intersection(a, b)

Where both a and b are of an array type.

For example:

  Given the following statements:

    $a = ['a', 'b', 'c', 'd', 'd']
    $b = ['a', 'b']
    $c = ['b', 'd', 'x']

    notice array_intersection($a, $b)
    notice array_intersection($b, $c)
    notice array_intersection($c, $a)

  The result will be as follows:

    notice: Scope(Class[main]): a b
    notice: Scope(Class[main]): b
    notice: Scope(Class[main]): b d
    EOS
  ) do |*arguments|
    #
    # This is to ensure that whenever we call this function from within
    # the Puppet manifest or alternatively form a template it will always
    # do the right thing ...
    #
    arguments = arguments.shift if arguments.first.is_a?(Array)

    raise Puppet::ParseError, "array_intersection(): Wrong number of arguments " +
      "given (#{arguments.size} for 2)" if arguments.size < 1

    one = arguments.shift
    two = arguments.shift 

    %w(one two).each do |i|
      raise Puppet::ParseError, 'array_intersection(): Requires an array type ' +
        'to work with' unless eval(i).is_a?(Array)
    end

    one & two
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
