#! /usr/bin/env ruby
$:.unshift File.expand_path("../../lib", __FILE__)

require 'dotenv'
require 'etc'
require 'thor'
require 'btrlxc'
require 'btrlxc/test'

class Cli < Thor
  desc 'test', 'test environment'
  def test
    Btrlxc::Test.net
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

  desc 'destroy', 'create new instance from source'
  def destroy(name)
    Btrlxc.destroy(name)
  end
end

Dotenv.load(File.join(
             Dir.home(ENV.key?('SUDO_USER') ? ENV['SUDO_USER'] : Etc.getlogin),
             '.btrlxc.env'))

Cli.start(ARGV)
