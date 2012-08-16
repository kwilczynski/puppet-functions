#
# join_with_prefix.rb
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
  newfunction(:join_with_prefix, :type => :rvalue, :doc => <<-EOS
Returns

Prototype:

    join_with_prefix()

Where

For example:

  Given the following statements:

    $a =

    notice join_with_prefix()

  The result will be as follows:

    notice: Scope(Class[main]):
    EOS
  ) do |*arguments|
    #
    # This is to ensure that whenever we call this function from within
    # the Puppet manifest or alternatively form a template it will always
    # do the right thing ...
    #
    arguments = arguments.shift if arguments.first.is_a?(Array)

    # Technically we support three arguments but only first is mandatory ...
    raise(Puppet::ParseError, "join(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)") if arguments.size < 1

    array = arguments[0]

    unless array.is_a?(Array)
      raise(Puppet::ParseError, 'join_with_prefix(): Requires ' +
        'an array to work with')
    end

    prefix = arguments[1] if arguments[1]
    suffix = arguments[2] if arguments[2]

    if prefix and suffix
      result = prefix + array.join(suffix + prefix)
    elsif prefix and not suffix
      result = array.collect { |i| prefix ? prefix + i : i }
    elsif suffix and not prefix
      result = array.join(suffix)
    else
      result = array.join
    end

    return result
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
