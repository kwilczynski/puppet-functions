#
# zip.rb
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
  newfunction(:zip, :type => :rvalue, :doc => <<-EOS
Returns

Prototype:

    zip()

Where

For example:

  Given the following statements:

  The result will be as follows:

    EOS
  ) do |*arguments|
    #
    # This is to ensure that whenever we call this function from within
    # the Puppet manifest or alternatively form a template it will always
    # do the right thing ...
    #
    arguments = arguments.shift if arguments.first.is_a?(Array)
    # Technically we support three arguments but only first is mandatory ...
    raise(Puppet::ParseError, "zip(): Wrong number of arguments " +
      "given (#{arguments.size} for 2)") if arguments.size < 2

    a = arguments[0]
    b = arguments[1]

    unless a.is_a?(Array) and b.is_a?(Array)
      raise(Puppet::ParseError, 'zip(): Requires ' +
        'a set of two arrays to work with')
    end

    flatten = arguments[2] if arguments[2]

    if flatten
      klass = flatten.class

      # We can have either true or false, or string which resembles boolean ...
      unless [FalseClass, TrueClass, String].include?(klass)
        raise(Puppet::ParseError, 'zip(): Requires ' +
          'either boolean or string to work with')
      end

      if flatten.is_a?(String)
        # We consider all the boolean-alike values too ...
        flatten = case flatten
          #
          # This is how undef looks like in Puppet ...
          # We yield false in this case.
          #
          when /^$/, ''              then false # Empty string will be false ...
          when /^(1|t|y|true|yes)$/  then true
          when /^(0|f|n|false|no)$/  then false
          when /^(undef|undefined)$/ then false # This is not likely to happen ...
          else
            raise(Puppet::ParseError, 'zip(): Unknown type of boolean given')
        end
      end
    end

    result = a.zip(b)
    result = flatten ? result.flatten : result

    return result
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
