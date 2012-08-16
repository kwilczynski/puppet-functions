#
# delete_at.rb
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
  newfunction(:delete_at, :type => :rvalue, :doc => <<-EOS
Returns

Prototype:

    delete_at()

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

    if arguments.size < 2
      raise(Puppet::ParseError, "delete_at(): Wrong number " +
        "of arguments given (#{arguments.size} for 2)")
    end

    array = arguments[0]

    unless array.is_a?(Array)
      raise(Puppet::ParseError, 'delete_at(): Requires an array to work with')
    end

    index = arguments[1]
    klass = index.class

    # This should cover all the generic numeric types present in Puppet ...
    if not [Bignum, Fixnum, Float, String].include?(klass)
      raise(Puppet::ParseError, 'delete_at(): Requires ' +
        'a numeric value to work with')
    end

    # Numbers in Puppet are often string-encoded which is troublesome ...
    if index.is_a?(String)
      if index.match(/^-?(?:\d+)(?:\.\d+){1}$/) # Floating point
        index = index.to_f
      elsif index.match(/^-?\d+$/)              # Integer
        index = index.to_i
      else
        raise(Puppet::ParseError, 'delete_at(): Requires ' +
          'either integer or float to work with')
      end
    end

    result = array.clone

    result.delete_at(index) # We ignore the item that was deleted ...

    return result
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
