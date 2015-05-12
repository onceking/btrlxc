require 'mixlib/shellout'
require 'inifile'
require 'netaddr'
require 'btrlxc/config'

module Btrlxc
  class << self
    # no DHCP as that's slow Gratuitous ARP & IPV6 autoconf
    def create(source, name)
      sdir = "#{Btrlxc::Config.snap_path}/#{source}"
      ddir = "#{Btrlxc::Config.lxc_path}/#{name}"

      raise "#{ddir} already exists." if File.exist?(ddir)
      unless File.file?("#{sdir}/config") && File.directory?("#{sdir}/rootfs")
        raise "#{sdir} is not valid."
      end

      ip = nil
      _with_lock do
        ip = _allocate_ip

        _run! "btrfs subvolume snapshot '#{sdir}' '#{ddir}'"
        conf = IniFile.load("#{sdir}/config")['global']

        conf.delete('lxc.mount')
        conf.delete('lxc.network.hwaddr')
        conf['lxc.rootfs']               = "#{ddir}/rootfs"
        conf['lxc.utsname']              = name
        conf['lxc.network.type']         = 'veth'
        conf['lxc.network.flags']        = 'up'
        conf['lxc.network.link']         = Btrlxc::Config.bridge
        conf['lxc.network.ipv4'] = "#{ip}#{Btrlxc::Config.bridge_cidr.netmask}"
        conf['lxc.network.ipv4.gateway'] = Btrlxc::Config.bridge_cidr_link.ip
        File.open("#{ddir}/config", 'w') do |f|
          conf.each do |k, v|
            f.puts [k, v].join(' = ')
          end
        end

        # security
        FileUtils.touch("#{ddir}/.btrlxc")

        _run! "lxc-start -dn #{name}"
        _run! "lxc-info -n #{name}"
      end
      ip
    end

    def destroy(name)
      dir = "#{Btrlxc::Config.lxc_path}/#{name}"
      raise "#{dir} is not a directory." unless File.directory?(dir)
      raise "#{dir} not created by btrlxc." unless File.exist?("#{dir}/.btrlxc")

      _run! "lxc-stop -kn #{name} || :"
      _run! "btrfs subvolume delete #{dir}"
    end

    def hosts
      hs = {}
      Dir["#{Btrlxc::Config.lxc_path}/*/config"].each do |f|
        name = File.basename(File.dirname(f))
        conf = IniFile.load(f)['global']

        hs[name] = NetAddr::CIDR.create(conf['lxc.network.ipv4'])
      end
      hs
    end

    private

    def _with_lock(&block)
      f = File.join(Btrlxc::Config.lxc_path, 'btrlxc.lock')
      f = File.new(f, File::CREAT, 0644)
      f.flock(File::LOCK_EX)
      yield
    ensure
      f.flock(File::LOCK_UN)
    end

    def _allocate_ip
      cidr = Btrlxc::Config.bridge_cidr
      min_ip = NetAddr.ip_to_i(cidr.ip)
      used_ips = hosts.values.map{|x| NetAddr.ip_to_i(x.ip)}
      cidr.range(0).find do |ip|
        i = NetAddr.ip_to_i(ip)
        i > min_ip && !used_ips.include?(i)
      end
    end

    def _run!(cmd)
      sh = Mixlib::ShellOut.new(cmd, live_stream: $stdout)
      sh.run_command
      sh.error!
    end
  end
end
