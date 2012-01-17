#
# dump.rb
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
  newfunction(:dump, :type => :rvalue, :doc => <<-EOS
Displays content of a variable for any arbitrary value given.

Prototype:

    dump(x)
    dump(x, b)

Where x is a value of an arbitrary type, and where the value of b is a boolean,
or a string value given in one of the following boolean-alike forms:

  When given as either '1', 't', 'y', 'true' or 'yes' it will evaluate
  as true whereas when given as either '0', 'f', 'n', 'false' or 'no'
  then it will evaluate as false.

Then an indentation will be added to the resulting output, most likely making
display of such content split over a multiple lines for any value of x where
significant size and complexity is to be shown.  This might not be desirable in
most of the cases when used in conjunction with Puppet's notice built-in function.

For example:

  Given the following statements:

    $a = ['a', 'b', 'c']
    $b = { 'd' => 1, 'e' => 2, 'f' => 3 }
    $c = [$a, $b, 'xyz']

    notice dump($a)
    notice dump($b)
    notice dump($c)

  The result will be as follows:

    notice: Scope(Class[main]): ["a", "b", "c"]
    notice: Scope(Class[main]): {"d"=>"1", "e"=>"2", "f"=>"3"}
    notice: Scope(Class[main]): [["a", "b", "c"], {"d"=>"1", "e"=>"2", "f"=>"3"}, "xyz"]

  Known issues:

    This function should only be used as an aid in any debugging efforts,
    and everything else is probably out-of-scope for it.
    EOS
  ) do |*arguments|
    #
    # This is to ensure that whenever we call this function from within
    # the Puppet manifest or alternatively form a template it will always
    # do the right thing ...
    #
    arguments = arguments.shift if arguments.first.is_a?(Array)

    # Technically we support two arguments but only first is mandatory ...
    raise Puppet::ParseError, "dump(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)" if arguments.size < 1

    value = arguments.shift
    klass = value.class

    #
    # This should cover all the generic types present in Puppet ...
    #
    # There is one caveat -- numeric values like 1 and 1.0 will be
    # turn into string by Puppet and therefore they will appear as
    # such in the results ...
    #
    unless klass.ancestors.include?(Numeric) or
      [Array, Hash, String, TrueClass, FalseClass].include?(klass)
      raise Puppet::ParseError, 'dump(): Unknown type given'
    end

    indent = arguments.shift unless arguments.empty?

    if indent and indent.is_a?(String)
      # We consider all the boolean-alike values too ...
      indent = case indent
        #
        # This is how undef looks like in Puppet ...
        # We yield false in this case.
        #
        when /^$/, ''              then false # Empty string will be false ...
        when /^(1|t|y|true|yes)$/  then true
        when /^(0|f|n|false|no)$/  then false
        when /^(undef|undefined)$/ then false # This is not likely to happen ...
        else
          raise Puppet::ParseError, 'dump(): Unknown type of boolean given'
      end
    end

    require 'pp'

    indent ? PP.send(:pp, value, '', 78) : PP.send(:singleline_pp, value, '')
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
