$:.unshift File.expand_path("../../lib", __FILE__)

require 'thor'
require 'btrlxc'
require 'btrlxc/test'

class Cli < Thor
  desc 'test', 'test environment'
  def test
    Btrlxc::Test.net
    Btrlxc::Test.sudo
  end

  desc 'list', 'list current hosts'
  def list
    Btrlxc.hosts.each do |name, cidr|
      puts [name, cidr.ip].join("\t")
    end
  end

  desc 'create', 'create new instance from source'
  def create(source, name)
    puts [name, Btrlxc.create(source, name)].join("\t")
  end
end

Cli.start(ARGV)
