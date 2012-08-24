#
# bracket_expansion.rb
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
  newfunction(:bracket_expansion, :type => :rvalue, :doc => <<-EOS
Returns

Prototype:

    bracket_expansion(p)
    bracket_expansion(p, s)

Where

For example:

  Given the following statements:

    $a = '[1-10]'
    $b = 'abc[1-3]'
    $c = 'def[001-3]'
    $d = '[01,3,5].ghi[1,2].test'
    $e = 'jkl[01-2,42].test[001,2]'
    $f = 'xyz[1-10]'

    notice bracket_expansion($a)
    notice bracket_expansion($b)
    notice bracket_expansion($c)
    notice bracket_expansion($d)
    notice bracket_expansion($e)
    notice bracket_expansion($f, 2)

  The result will be as follows:

    notice: Scope(Class[main]): 1 2 3 4 5 6 7 8 9 10
    notice: Scope(Class[main]): abc1 abc2 abc3
    notice: Scope(Class[main]): def001 def002 def003
    notice: Scope(Class[main]): 01.ghi1.test 01.ghi2.test 03.ghi1.test 03.ghi2.test 05.ghi1.test 05.ghi2.test
    notice: Scope(Class[main]): jkl01.test001 jkl01.test002 jkl02.test001 jkl02.test002 jkl42.test001 jkl42.test002
    notice: Scope(Class[main]): xyz1 xyz3 xyz5 xyz7 xyz9

  Known issues:

    Currently, using zero-padding and negative integer values for either
    start or stop parameters may result in undesirable outcome.
    EOS
  ) do |*arguments|
    #
    # This is to ensure that whenever we call this function from within
    # the Puppet manifest or alternatively form a template it will always
    # do the right thing ...
    #
    arguments = arguments.shift if arguments.first.is_a?(Array)

    # We support more than one argument but at least one is mandatory ...
    raise Puppet::ParseError, "bracket_expansion(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)" if arguments.size < 1

    pattern = arguments.shift

    raise Puppet::ParseError, 'bracket_expansion(): Requires a string type ' +
      'to work with' unless pattern.is_a?(String)

    raise Puppet::ParseError, 'bracket_expansion(): An argument given cannot ' +
      'be an empty string value' if pattern.empty?

    raise Puppet::ParseError, 'bracket_expansion(): An invalid bracket ' +
      'expansion pattern' unless pattern.match(/\[.+?\]/)

    step = arguments.shift || 1

    # This should cover all the generic numeric types present in Puppet ...
    unless step.class.ancestors.include?(Numeric) or step.is_a?(String)
      raise Puppet::ParseError, 'bracket_expansion(): Requires a numeric ' +
        'type to work with'
    end

    # Numbers in Puppet are often string-encoded which is troublesome ...
    if step.is_a?(Integer) or (step.is_a?(String) and step.match(/^-?\d+$/))
      # An Integer value should match ...
      step = step.to_i

      # Step cannot be of an negative size ...
      raise Puppet::ParseError, 'bracket_expansion(): Requires a non-negative ' +
        'integer value to work with' if step < 0
    else
      raise Puppet::ParseError, 'bracket_expansion(): Requires an integer ' +
        'value to work with'
    end

    # We store initial pattern to perform first match an further dissection ...
    range = []
    range << pattern

    # Step through brackets ...
    pattern.scan(/\[.+?\]/).collect do |bracket|
      bracket.tr!('[]', '')

      values       = []
      zero_padding = 0

      # We collect single digits ...
      bracket.split(',').each do |expression|
        expression.strip!

        raise Puppet::ParseError, 'bracket_expansion(): An incompatible value ' +
          'given in bracket expansion pattern' unless expression.match(/-?\d+/)

        count = 0

        if match = expression.match(/^(-?\d+)\-(-?\d+)$/)
          # Get start and stop pair when a rage is given ...
          start = match[1].to_i
          stop  = match[2].to_i

          raise Puppet::ParseError, 'bracket_expansion(): An invalid ' +
            'start or stop value given' if start > stop

          match.captures.each do |i|
            value = i.match(/-?\d+/)[0]
            count = value.size if value.match(/^0+/) and value.size > count
          end

          # Apply step ...
          values += (start .. stop).step(step).to_a
        else
          # The longest match (in terms of number of zeros) in zero-padding wins ...
          value = expression.match(/-?\d+/)[0]
          count = value.size if value.match(/^0+/)

          values << value.to_i
        end

        zero_padding = count if count > zero_padding
      end

      range = begin
        result = []

        # We correct zero-padding in the pattern accordingly ...
        range.each do |i|
          values.each do |j|
            result << i.sub(/\[.*?\]/, sprintf("%0#{zero_padding}i", j))
          end
        end

        result
      end
    end

    range
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
