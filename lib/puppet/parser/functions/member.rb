#
# member.rb
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
  newfunction(:member, :type => :rvalue, :doc => <<-EOS
    EOS
Returns

Prototype:

    member()

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

    raise(Puppet::ParseError, "member(): Wrong number of arguments " +
      "given (#{arguments.size} for 2)") if arguments.size < 2

    array = arguments[0]

    unless array.is_a?(Array)
      raise(Puppet::ParseError, 'member(): Requires an array to work with')
    end

    item = arguments[1]

    raise(Puppet::ParseError, 'member(): You must provide item ' +
      'to search for within an array given') if item.empty?

    result = array.include?(item)

    return result
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
