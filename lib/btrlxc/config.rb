require 'socket'
require 'netaddr'

module Btrlxc
  class Config
    class << self
      def bridge
        _env('BRIDGE', 'lxcbr')
      end

      def bridge_cidr
        cidr = _env('CIDR', nil)
        if cidr.nil?
          cidr = bridge_cidr_link
        else
          cidr = NetAddr::CIDR.create(cidr)
        end
        cidr
      end

      def bridge_cidr_link
        ifce = Socket.getifaddrs.select{|x| x.name == bridge && x.addr.ipv4? }[0]
        NetAddr::CIDR.create([ifce.addr.ip_address, ifce.netmask.ip_address].join('/'))
      end

      def ssh_pubkey
        [ssh_key, '.pub'].join('')
      end

      def ssh_key
        _env('SSH_KEY', '/var/lib/lxc/id_rsa')
      end

      def lxc_path
        _env('LXC_PATH', '/var/lib/lxc')
      end

      def snap_path
        _env('SNAP_PATH', '/var/lib/lxc/.snap')
      end

      private

      def _env(key, default)
        key = "BTRLXC_#{key}"
        ENV.key?(key) ? ENV[key] : default
      end
    end
  end
end
