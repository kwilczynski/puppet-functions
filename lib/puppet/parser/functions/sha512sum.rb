#
# sha512sum.rb
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
  newfunction(:sha512sum, :type => :rvalue, :doc => <<-EOS
Returns a new string which is a hexadecimal representation of an SHA512 check sum
computed for the arbitrary string value given.

Prototype:

    sha256sum(s)

Where s is an arbitrary string value.

For example:

  Given the following statements:

    $a = 'puppetlabs.com'
    $b = 'google.com'

    notice sha512sum($a)
    notice sha512sum($b)

  The result will be as follows:

    notice: Scope(Class[main]): 6366f2c1fc4f02e06c1de4c0fcf66c1b69002af77bafb66310ab4e7df2c038b59c0cdc7424a0d82343ded633329227aee7a4cafeec88d477ebb1c72bfef0c5a6
    notice: Scope(Class[main]): a5b5955a4db31736f9dfd45c89c12331e0370074fc7fec0ac4d189a62391bf7060287f957ce67cf3adcac7a4353a7a8241e33084a9b543cbb3f39770970a41b2

  Known issues:

    Computing an SHA512 check sum of an external artefact (e.g. file) is currently
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

    raise Puppet::ParseError, "sha512sum(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)" if arguments.size < 1

    value = arguments.shift

    raise Puppet::ParseError, 'sha512sum(): Requires a string type ' +
      'to work with' unless value.is_a?(String)

    # This is probably impossible as Digest is part of the Ruby Core ...
    begin
      require 'digest/sha2'
    rescue LoadError
      raise Puppet::ParseError, 'sha512sum(): Unable to load Digest::SHA2 library.'
    end

    # Compute and return an SHA1 check sum ...
    Digest::SHA512.hexdigest(value)
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
