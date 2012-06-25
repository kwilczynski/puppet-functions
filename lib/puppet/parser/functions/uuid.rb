#
# uuid.rb
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
  newfunction(:uuid, :type => :rvalue, :doc => <<-EOS
Returns a new string which is an RFC 4122 compliant UUID version 5 type
identifier for the fully-qualified domain name given.

Prototype:

    uuid(s)

Where s is a string value that represents a fully-qualified domain name.

For example:

  Given the following statements:

    $a = 'puppetlabs.com'
    $b = 'google.com'

    notice uuid($a)
    notice uuid($b)

  The result will be as follows:

    notice: Scope(Class[main]): 9c70320f-6815-5fc5-ab0f-debe68bf764c
    notice: Scope(Class[main]): 64ee70a4-8cc1-5d25-abf2-dea6c79a09c8

  Known issues:

    Currently we only support SHA-1 hash (over MD5 equivalent) and DNS (which
    encourages use of a fully-qualified domain name) is the only available
    name space when generating the UUID version 5 identifier.

    Please consult http://www.ietf.org/rfc/rfc4122.txt for the details on
    UUID generation and example implementation.

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

    raise Puppet::ParseError, "uuid(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)" if arguments.size < 1

    domain = arguments.shift

    raise Puppet::ParseError, 'uuid(): Requires a string type ' +
      'to work with' unless domain.is_a?(String)

    #
    # Since UUID version 5 will concatenate specific name space with
    # an appropriate string value e.g. a domain name, we cannot really
    # allow for an accidental empty string value ...
    #
    raise Puppet::ParseError, 'uuid(): An argument given cannot ' +
      'be an empty string value.' if domain.empty?

    # This is probably impossible as Digest is part of the Ruby Core ...
    begin
      require 'digest/sha1'
    rescue LoadError
      raise Puppet::ParseError, 'uuid(): Unable to load Digest::SHA1 library.'
    end

    #
    # The String#bytes method was added in 1.8.7 (and now is present in any
    # recent version) therefore we monkey-patch String if such is missing ...
    #
    unless String.method_defined?(:bytes)
      class String
        def bytes(&block)
          # This should not be necessary, really ...
          require 'enumerator'
          return to_enum(:each_byte) unless block_given?
          each_byte(&block)
        end
      end
    end

    #
    # This is the UUID version 5 type DNS name space which is as follows:
    #
    #  6ba7b810-9dad-11d1-80b4-00c04fd430c8
    #
    uuid_name_space_dns = "\x6b\xa7\xb8\x10\x9d\xad\x11\xd1" +
                          "\x80\xb4\x00\xc0\x4f\xd4\x30\xc8"

    sha1 = Digest::SHA1.new

    # Concatenate appropriate UUID name space with the domain name given ...
    sha1.update(uuid_name_space_dns)
    sha1.update(domain)

    #
    # We only need to use first 16 bytes and use of String#bytes should be
    # more portable between Rubies 1.8.x and 1.9.x, with the exception of
    # anything prior to version 1.8.7 where String#bytes was added ...
    #
    bytes = sha1.digest[0, 16].bytes.to_a

    # We adjust version to be 5 correctly ...
    bytes[6] &= 0x0f
    bytes[6] |= 0x50

    # We adjust variant to be DCE 1.1 ...
    bytes[8] &= 0x3f
    bytes[8] |= 0x80

    #
    # We turn raw bytes into an user-friendly UUID string representation.
    # The values 4, 2, 2, 2 and 6 denote how many bytes we collect at once
    # giving the total of 16 bytes (128 bits) ...
    #
    bytes = [4, 2, 2, 2, 6].collect do |i|
      bytes.slice!(0, i).pack('C*').unpack('H*')
    end

    # Add UUID-relevant hyphens in place ...
    bytes.join('-')
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
