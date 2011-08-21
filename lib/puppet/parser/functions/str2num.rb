#
# str2num.rb
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
  newfunction(:str2num, :type => :rvalue, :doc => <<-EOS
Returns a numeric representation of any string data type after conversion.

Prototype:

    str2num(s)

Where s is a string value.

For example:

  Given the following statements:

    $a = '1'
    $b = '-1'
    $c = '1.0'
    $d = '-1.0'
    $e = 'abc1'
    $f = '1def'
    $g = ''
    $h = 'abc'

    notice str2num($a)
    notice str2num($b)
    notice str2num($c)
    notice str2num($d)
    notice str2num($e)
    notice str2num($f)
    notice str2num($g)
    notice str2num($h)

  The result will be as follows:

    notice: Scope(Class[main]): 1
    notice: Scope(Class[main]): -1
    notice: Scope(Class[main]): 1.0
    notice: Scope(Class[main]): -1.0
    notice: Scope(Class[main]): 1
    notice: Scope(Class[main]): 1
    notice: Scope(Class[main]): 0
    notice: Scope(Class[main]): 0
    EOS
  ) do |*arguments|
    #
    # This is to ensure that whenever we call this function from within
    # the Puppet manifest or alternatively form a template it will always
    # do the right thing ...
    #
    arguments = arguments.shift if arguments.first.is_a?(Array)

    raise Puppet::ParseError, "str2num(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)" if arguments.size < 1

    string = arguments.shift

    raise Puppet::ParseError, 'str2num(): Requires a string type ' +
      'to work with' unless string.is_a?(String)

    # Numbers in Puppet are often string-encoded which is troublesome ...
    if match = string.match(/(-?(?:\d+)(?:\.\d+){1})/) # Floating point
      string = match[1].to_f
    elsif match = string.match(/(-?\d+)/)              # Integer
      string = match[1].to_i
    else
      # When unable to match ...
      string = 0
    end

    string
  end
end

# vim: set ts=2 sw=2 et :
