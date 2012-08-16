#
# strftime.rb
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
  newfunction(:strftime, :type => :rvalue, :doc => <<-EOS
Returns

Prototype:

    strftime()

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

    # Technically we support two arguments but only first is mandatory ...
    raise(Puppet::ParseError, "strftime(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)") if arguments.size < 1

    format = arguments[0]

    unless format.is_a?(String)
      raise(Puppet::ParseError, 'strftime(): Requires ' +
        'a string to work with')
    end

    # The Time Zone argument is optional ...
    time_zone = arguments[1] if arguments[1]

    time = Time.new

    # There is probably a better way to handle Time Zone ...
    if time_zone
      unless time_zone.is_a?(String)
        raise(Puppet::ParseError, 'strftime(): Requires ' +
          'time zone to be a string')
      end

      # When there is no Time Zone given then we default to UTC ...
      time_zone = time_zone.empty? ? 'UTC' : time_zone

      original_zone = ENV['TZ']

      local_time = time.clone
      local_time = local_time.utc

      ENV['TZ'] = time_zone

      time = local_time.localtime

      ENV['TZ'] = original_zone
    end

    result = time.strftime(format)

    return result
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
