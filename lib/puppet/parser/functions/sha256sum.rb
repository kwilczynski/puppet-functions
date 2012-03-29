#
# sha256sum.rb
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
  newfunction(:sha256sum, :type => :rvalue, :doc => <<-EOS
Returns a new string which is a hexadecimal representation of an SHA256 check sum
computed for the arbitrary string value given.

Prototype:

    sha256sum(s)

Where s is an arbitrary string value.

For example:

  Given the following statements:

    $a = 'puppetlabs.com'
    $b = 'google.com'

    notice sha256sum($a)
    notice sha256sum($b)

  The result will be as follows:

    notice: Scope(Class[main]): fcd3ec488796fa8d7e696c5292f849f3ab831718c05483b4a5ec876971f2b764
    notice: Scope(Class[main]): d4c9d9027326271a89ce51fcaf328ed673f17be33469ff979e8ab8dd501e664f

  Known issues:

    Computing an SHA256 check sum of an external artefact (e.g. file) is currently
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

    raise Puppet::ParseError, "sha256sum(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)" if arguments.size < 1

    value = arguments.shift

    raise Puppet::ParseError, 'sha256sum(): Requires a string type ' +
      'to work with' unless value.is_a?(String)

    # This is probably impossible as Digest is part of the Ruby Core ...
    begin
      require 'digest/sha2'
    rescue LoadError
      raise Puppet::ParseError, 'sha256sum(): Unable to load Digest::SHA2 library.'
    end

    # Compute and return an SHA1 check sum ...
    Digest::SHA256.hexdigest(value)
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
