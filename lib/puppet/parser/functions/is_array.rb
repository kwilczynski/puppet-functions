#
# is_array.rb
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
  newfunction(:is_array, :type => :rvalue, :doc => <<-EOS
Returns true if given arbitrary value is of an array type and false otherwise.

Prototype:

    is_array(x)

Where x is a value of an arbitrary type.

For example:

  Given the following statements:

    $a = true
    $b = 1
    $c = -1
    $d = 1.0
    $e = -1.0
    $f = ''
    $g = []
    $h = {}

    notice is_array($a)
    notice is_array($b)
    notice is_array($c)
    notice is_array($d)
    notice is_array($e)
    notice is_array($f)
    notice is_array($g)
    notice is_array($h)

  The result will be as follows:

    notice: Scope(Class[main]): false
    notice: Scope(Class[main]): false
    notice: Scope(Class[main]): false
    notice: Scope(Class[main]): false
    notice: Scope(Class[main]): false
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

    raise Puppet::ParseError, "is_array(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)" if arguments.size < 1

    type = arguments.shift

    type.is_a?(Array)
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
