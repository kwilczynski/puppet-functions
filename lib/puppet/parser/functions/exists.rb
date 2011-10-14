#
# exists.rb
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
  newfunction(:exists, :type => :rvalue, :doc => <<-EOS
Returns an boolean value if a given file and/or directory exists on Puppet Master.

Prototype:

    exists(x)

Where x is a file or directory.

For example:

  Given the following statements:

    $a = '/etc/resolv.conf'
    $b = '/this/does/not/exists'

    notice exists($a)
    notice exists($b)

  The result will be as follows:

    notice: Scope(Class[main]): true
    notice: Scope(Class[main]): false

  Known issues:

    This function will ONLY be evaluated on the Puppet Master side and it
    makes no sense to use it when checking whether a file and/or directory
    exists on the client side.

    There is no support for "file://" and "puppet://" URI type resolution
    at this point in time.
    EOS
  ) do |*arguments|
    #
    # This is to ensure that whenever we call this function from within
    # the Puppet manifest or alternatively form a template it will always
    # do the right thing ...
    #
    arguments = arguments.shift if arguments.first.is_a?(Array)

    raise Puppet::ParseError, "exists(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)" if arguments.size < 1

    file = arguments.shift

    raise Puppet::ParseError, 'exists(): Requires a string type ' +
      'to work with' unless file.is_a?(String)

    # We want to be sure that we have the complete path ...
    file = File.expand_path(file)

    File.exists?(file)
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
