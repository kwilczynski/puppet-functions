#
# md5sum.rb
#
# Copyright 2012 Puppet Labs Inc.
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
  newfunction(:md5sum, :type => :rvalue, :doc => <<-EOS
Returns a new string which is a hexadecimal representation of an MD5 check sum
computed for the arbitrary string value given.

Prototype:

    md5sum(s)

Where s is an arbitrary string value.

For example:

  Given the following statements:

    $a = 'puppetlabs.com'
    $b = 'google.com'

    notice md5sum($a)
    notice md5sum($b)

  The result will be as follows:

    notice: Scope(Class[main]): fc8671ac8108a33a6f43de7f2132cd12
    notice: Scope(Class[main]): 1d5920f4b44b27a802bd77c4f0536f5a

  Known issues:

    Computing an MD5 check sum of an external artefact (e.g. file) is currently
    not available, and due to the nature of Puppet there are no plans to add
    such functionality.
    EOS
  ) do |*arguments|
    #
    # This is to ensure that whenever we call this function from within
    # the Puppet manifest or alternatively form a template it will always
    # do the right thing ...
    #
    arguments = arguments.shift if arguments.first.is_a?(Array)

    raise Puppet::ParseError, "md5sum(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)" if arguments.size < 1

    value = arguments.shift

    raise Puppet::ParseError, 'md5sum(): Requires a string type ' +
      'to work with' unless value.is_a?(String)

    # This is probably impossible as Digest is part of the Ruby Core ...
    begin
      require 'digest/md5'
    rescue LoadError
      raise Puppet::ParseError, 'md5sum(): Unable to load Digest::MD5 library.'
    end

    # Compute and return an MD5 check sum ...
    Digest::MD5.hexdigest(value)
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
