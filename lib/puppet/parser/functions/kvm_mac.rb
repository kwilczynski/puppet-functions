#
# kvm_mac.rb
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
  newfunction(:kvm_mac, :type => :rvalue, :doc => <<-EOS
Returns a new string which is a MAC address that uses the Kernel Virtual Machine
(KVM) format of 52:54:00:XX:YY:ZZ for the fully-qualified domain name given.

Prototype:

    kvm_mac(s)

Where s is a string value that represents a fully-qualified domain name.

For example:

  Given the following statements:

    $a = 'puppetlabs.com'
    $b = 'google.com'

    notice kvm_mac($a)
    notice kvm_mac($b)

  The result will be as follows:

    notice: Scope(Class[main]): 52:54:00:BA:45:45
    notice: Scope(Class[main]): 52:54:00:1C:98:05

  Known issues:

    No verification is present at the moment as whether the domain name given
    is in fact a correct fully-qualified domain name.  Therefore any arbitrary
    string and/or alpha-numeric value can subside for a domain name.
    EOS
  ) do |*arguments|
    #
    # This is to ensure that whenever we call this function from within
    # the Puppet manifest or alternatively form a template it will always
    # do the right thing ...
    #
    arguments = arguments.shift if arguments.first.is_a?(Array)

    raise Puppet::ParseError, "kvm_mac(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)" if arguments.size < 1

    domain = arguments.shift

    raise Puppet::ParseError, 'kvm_mac(): Requires a string type ' +
      'to work with' unless domain.is_a?(String)

    #
    # We cannot really allow for an accidental empty string value.  A MAC
    # address should preferably be unique in order not to cause problems
    # issues within the infrastructure where virtual machines are in use
    # and where troubleshooting networking usually takes effort ...
    #
    raise Puppet::ParseError, 'kvm_mac(): An argument given cannot ' +
      'be an empty string value' if domain.empty?

    # This is probably impossible as Digest is part of the Ruby Core ...
    begin
      require 'digest/sha1'
    rescue LoadError
      raise Puppet::ParseError, 'kvm_mac(): Unable to load Digest::SHA1 library'
    end

    #
    # Generate SHA1 digest from given fully-qualified domain name and/or any
    # arbitrary string given ...
    #
    sha1  = Digest::SHA1.new
    bytes = sha1.digest(domain)

    #
    # We take only three hexadecimal values: one from the begging, one from
    # the middle of the digest and one from the end; which hopefully will
    # ensure uniqueness of the MAC address we have ...
    #
    "52:54:00:%s" % bytes.unpack('H2x9H2x8H2').join(':').tr('a-z', 'A-Z')
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
