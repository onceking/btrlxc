require 'mixlib/shellout'
require 'btrlxc/config'

module Btrlxc
  class Test
    class << self
      def net
        puts "Bridge: #{Btrlxc::Config.bridge}"
        link = Btrlxc::Config.bridge_cidr_link
        env = Btrlxc::Config.bridge_cidr
        puts "Bridge LINK CIDR: #{link}"
        _p "Bridge ENV CIDR: #{env}",  link == env || link.contains?(env)
      end

      private

      def _check_commands(cmds)
        errs = 0
        cmds.each do |cmd, exp|
          sh = Mixlib::ShellOut.new("#{cmd} 2>&1")
          sh.run_command
          if sh.stdout.include?(exp)
            _p cmd, true
          else
            _p cmd, false
            puts sh.stdout
            errs += 1
          end
        end
        errs
      end

      def _p(name, cond)
        puts '[%s] %s' % [cond ? 'PASS' : 'FAIL', name]
      end
    end
  end
end
