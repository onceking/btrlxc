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
    Btrlxc.hosts.each do |name, conf|
      puts "#{name}\t#{conf['lxc.network.ipv4']}"
    end
  end

  desc 'get', 'get attribute of a container'
  def get_ip(name, attr)
    attr = ['lxc', attr].join('.') unless attr.start_with?('lxc.')
    host = Btrlxc.hosts.find{|k, _| k == name}
    puts host[1][attr] if host
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
