#
# str2bool.rb
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
  newfunction(:str2bool, :type => :rvalue, :doc => <<-EOS
Returns a boolean value after conversion from string which resembles boolean.

Prototype:

    str2bool(s)

Where s is a string given in one of the following boolean-alike forms:

  When given as either '1', 't', 'y', 'true' or 'yes' it will evaluate
  as true whereas when given as either '0', 'f', 'n', 'false' or 'no'
  then it will evaluate as false.

For example:

  Given the following statements:

    $a = 'yes'
    $b = 'no'
    $c = 't'
    $d = 'f'
    $e = '1'
    $f = '0'

    notice str2bool($a)
    notice str2bool($b)
    notice str2bool($c)
    notice str2bool($d)
    notice str2bool($e)
    notice str2bool($f)

  The result will be as follows:

    notice: Scope(Class[main]): true
    notice: Scope(Class[main]): false
    notice: Scope(Class[main]): true
    notice: Scope(Class[main]): false
    notice: Scope(Class[main]): true
    notice: Scope(Class[main]): false
    EOS
  ) do |arguments|

    #
    # We put arguments that are strings back into the array.  This is
    # to ensure that whenever we call this function from within the
    # Puppet manifest or alternatively form a template it will always
    # do the right thing ...
    #
    arguments.to_a if arguments.is_a?(String)

    raise Puppet::ParseError, "str2bool(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)" if arguments.size < 1

    string = arguments.shift

    raise Puppet::ParseError, 'str2bool(): Requires a string type ' +
      'to work with' unless string.is_a?(String)

    # We consider all the boolean-alike values too ...
    string = case string
      #
      # This is how undef looks like in Puppet ...
      # We yield false in this case.
      #
      when /^$/, ''              then false # Empty string will be false ...
      when /^(1|t|y|true|yes)$/  then true
      when /^(0|f|n|false|no)$/  then false
      when /^(undef|undefined)$/ then false # This is not likely to happen ...
      else
        raise Puppet::ParseError, 'str2bool(): Unknown type of boolean given'
    end

    string
  end
end

# vim: set ts=2 sw=2 et :
