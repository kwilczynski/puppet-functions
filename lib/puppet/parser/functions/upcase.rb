#
# upcase.rb
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
  newfunction(:upcase, :type => :rvalue, :doc => <<-EOS
Returns either a new array or string by changing case of elements within
to be upper-case for every letter.

Prototype:

    upcase(x)

Where x is either an array type or string value.

For example:

  Given the following statements:

    $a = 'abc'
    $b = ['def', 'g', 'H']

    notice upcase($a)
    notice upcase($b)

  The result will be as follows:

    notice: Scope(Class[main]): ABC
    notice: Scope(Class[main]): DEF G H
    EOS
  ) do |*arguments|
    #
    # This is to ensure that whenever we call this function from within
    # the Puppet manifest or alternatively form a template it will always
    # do the right thing ...
    #
    arguments = arguments.shift if arguments.first.is_a?(Array)

    raise Puppet::ParseError, "upcase(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)" if arguments.size < 1

    value = arguments.shift

    unless [Array, String].include?(value.class)
      raise Puppet::ParseError, 'upcase(): Requires either array type ' +
        'or string value to work with'
    end

    if value.is_a?(Array)
      value.collect { |i| i.is_a?(String) ? i.upcase : i }
    else
      value.upcase
    end
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
