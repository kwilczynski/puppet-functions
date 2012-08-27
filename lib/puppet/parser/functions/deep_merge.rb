#
# deep_merge.rb
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
  newfunction(:deep_merge, :type => :rvalue, :doc => <<-EOS
Returns a new hash that contains elements from both the first hash and the
second hash concerning any level (depth) of both hashes, where any duplicate
elements (keys) being over-written using values from the second hash.

Prototype:

    deep_merge(a, b)

Where both a and b are of a hash type.

For example:

  Given the following statements:

    $a = { 'a' => 1, 'b' => { 'c' => { 'd' => 2, 'e' => 3, 'f' => 4 } } }
    $b = { 'a' => 1, 'b' => { 'c' => { 'd' => 42, 'f' => 8 } } }

    notice deep_merge($a, $b)
    notice dump(deep_merge($a, $b))

  The result will be as follows:

    notice: Scope(Class[main]): a1bcd42e3f8
    notice: Scope(Class[main]): {"a"=>"1", "b"=>{"c"=>{"d"=>"42", "e"=>"3", "f"=>"8"}}}
    EOS
  ) do |*arguments|
    #
    # This is to ensure that whenever we call this function from within
    # the Puppet manifest or alternatively form a template it will always
    # do the right thing ...
    #
    arguments = arguments.shift if arguments.first.is_a?(Array)

    raise Puppet::ParseError, "deep_merge(): Wrong number of arguments " +
      "given (#{arguments.size} for 2)" if arguments.size < 2

    this  = arguments.shift
    other = arguments.shift

    [this, other].each do |i|
      raise Puppet::ParseError, 'deep_merge(): Requires a hash type ' +
        'to work with' unless i.is_a?(Hash)
    end

    # We have to be compliant with Hash#merge merge priority ...
    callback = Proc.new do |key, this, other|
      if this.is_a?(Hash) and other.is_a?(Hash)
        other.merge(this, &callback)
      else
        other
      end
    end

    this.merge(other, &callback)
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
