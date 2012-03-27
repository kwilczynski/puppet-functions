#
# is_port_open.rb
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
  newfunction(:is_port_open, :type => :rvalue, :doc => <<-EOS
Returns true if given port is open on a remote peer (host) and false otherwise.

Prototype:

    is_port_open(h, p)
    is_port_open(h, p, t)

Where h is a string type which can be either a host name or IP address of the
remote peer and p is a numeric type which is the port to check on the remote peer.

Additionally, a numeric value can be set as t to specify number of seconds (a
time out) to wait before assumming that given port is not accessible on the
remote peer.  This value should always be greater than zero.  By default it
will be set to 2 if not specified.

For example:

  Given the following statements:

    $a = 'google.com'
    $b = 'yahoo.com'
    $c = 'localhost'

    notice is_port_open($a, 22)
    notice is_port_open($b, 80)
    notice is_port_open($c, 22)

  The result will be as follows:

    notice: Scope(Class[main]): false
    notice: Scope(Class[main]): true
    notice: Scope(Class[main]): true

  Known issues:

    Currently, there is no support for floating-point time out values.
    EOS
  ) do |*arguments|
    #
    # This is to ensure that whenever we call this function from within
    # the Puppet manifest or alternatively form a template it will always
    # do the right thing ...
    #
    arguments = arguments.shift if arguments.first.is_a?(Array)

    # Technically we support three arguments but only two are mandatory ...
    raise Puppet::ParseError, "is_port_open(): Wrong number of arguments " +
      "given (#{arguments.size} for 2)" if arguments.size < 2

    host = arguments.shift

    raise Puppet::ParseError, 'is_port_open(): First argument requires ' +
      'a string type to work with' unless host.is_a?(String)

    port = arguments.shift

    # This should cover all the generic numeric types present in Puppet ...
    unless port.class.ancestors.include?(Numeric) or port.is_a?(String)
      raise Puppet::ParseError, 'is_port_open(): Second argument requires ' +
        'a numeric type to work with'
    end

    # We blindly cast port to integer assuming that it is correct ...
    port = port.to_i

    timeout = arguments.shift

    if timeout
      # This should cover all the generic numeric types present in Puppet ...
      unless timeout.class.ancestors.include?(Numeric) or timeout.is_a?(String)
        raise Puppet::ParseError, 'is_port_open(): Optional argument requires ' +
          'a numeric type to work with'
      end

      # We blindly cast time out to integer assuming that it is correct ...
      timeout = timeout.to_i

      if timeout <= 0
        raise Puppet::ParseError, 'is_port_open(): Value of optional ' +
          'argument must be be greater than zero'
      end
    else
      # Pick some sane default?  Should be more than enough for local networks ...
      timeout = 2
    end

    require 'socket'
    require 'timeout'

    # We assume that port is closed unless proven otherwise later ...
    result = false
    socket = nil

    begin
      Timeout::timeout(timeout) do
        socket = TCPSocket.open(host, port)
        result = true
      end
    rescue Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::ETIMEDOUT
      # Common exceptions related to connection being refused, etc ..
    rescue Timeout::Error
      # We might time out for many reasons, for instance port is filtered ...
    ensure
      # We make an attempt to close socket gracefully ...
      if socket
        socket.shutdown rescue nil
        socket.close    rescue nil
      end
    end

    result
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
