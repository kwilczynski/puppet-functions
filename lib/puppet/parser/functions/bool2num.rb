#
# bool2num.rb
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
  newfunction(:bool2num, :type => :rvalue, :doc => <<-EOS
Returns a numeric representation of any boolean type given.

Prototype:

    bool2num(x)

Where x is either a boolean type or a string value given in one of the
following boolean-alike forms:

  When given as either '1', 't', 'y', 'true' or 'yes' it will evaluate
  as 1 whereas when given as either '0', 'f', 'n', 'false' or 'no'
  then it will evaluate as 0.

For example:

  Given the following statements:

    $a = true
    $b = false
    $c = 'yes'
    $d = 'no'
    $e = 't'
    $f = 'f'
    $g = '1'
    $h = '0'

    notice bool2num($a)
    notice bool2num($b)
    notice bool2num($c)
    notice bool2num($d)
    notice bool2num($e)
    notice bool2num($f)
    notice bool2num($g)
    notice bool2num($h)

  The result will be as follows:

    notice: Scope(Class[main]): 1
    notice: Scope(Class[main]): 0
    notice: Scope(Class[main]): 1
    notice: Scope(Class[main]): 0
    notice: Scope(Class[main]): 1
    notice: Scope(Class[main]): 0
    notice: Scope(Class[main]): 1
    notice: Scope(Class[main]): 0
    EOS
  ) do |*arguments|
    #
    # This is to ensure that whenever we call this function from within
    # the Puppet manifest or alternatively form a template it will always
    # do the right thing ...
    #
    arguments = arguments.shift if arguments.first.is_a?(Array)

    raise Puppet::ParseError, "bool2num(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)" if arguments.size < 1

    boolean = arguments.shift

    # We can have either true, false, or string which resembles boolean ...
    unless [TrueClass, FalseClass, String].include?(boolean.class)
      raise Puppet::ParseError, 'bool2num(): Requires either boolean type ' +
        'or string value to work with'
    end

    if boolean.is_a?(String)
      # We consider all the boolean-alike values too ...
      boolean = case boolean
        #
        # This is how undef looks like in Puppet ...
        # We yield false in this case.
        #
        when /^$/, ''              then false # Empty string will be false ...
        when /^(1|t|y|true|yes)$/  then true
        when /^(0|f|n|false|no)$/  then false
        when /^(undef|undefined)$/ then false # This is not likely to happen ...
        else
          raise Puppet::ParseError, 'bool2num(): Unknown type of boolean given'
      end
    end

    # We have real boolean values as at this point ...
    boolean ? 1 : 0
  end
end

# vim: set ts=2 sw=2 et :
