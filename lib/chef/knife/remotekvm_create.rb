require 'knife-remotekvm/helpers'

module RemoteKVM
  class RemotekvmCreate < Chef::Knife

    include RemoteKVM::Helpers

    deps do
      Chef::Knife::Bootstrap.load_deps
    end

    banner 'knife remotekvm create NODE_NAME'

    option :kvm_node,
      :short => '-k FQDN|IP',
      :long => '--kvm-node FQDN|IP',
      :description => 'kvm enabled node',
      :required => true

    option :kvm_ssh_user,
      :short => '-X USERNAME',
      :long => '--kvm-ssh-user USERNAME'

    option :kvm_template,
      :long => '--kvm-template [template]',
      :description => 'kvm template to clone',
      :default => 'precise64'

    option :kvm_memory,
      :long => '--kvm-memory [MBs]',
      :description => 'Amount of memory in megabytes',
      :default => 512

    option :kvm_vcpus,
      :long => '--kvm-vcpus',
      :description => 'Number of virtual CPUs to configure',
      :default => 1

    option :kvm_maxvcpus,
      :long => '--kvm-maxvcpus',
      :description => 'Number of virtual CPUs guest is allowed to hotplug',
      :default => 1
    # TODO: Pass auth
    #option :kvm_ssh_password,
    #  :short => '-S PASSWORD',
    #  :long => '--kvm-ssh-password PASSWORD'

    # All the bootstrap options since we just proxy
    option :ssh_user,
      :short => "-x USERNAME",
      :long => "--ssh-user USERNAME",
      :description => "The ssh username",
      :default => "ubuntu"

    option :ssh_password,
      :short => "-P PASSWORD",
      :long => "--ssh-password PASSWORD",
      :description => "The ssh password",
      :default => "ubuntu"

    option :ssh_port,
      :short => "-p PORT",
      :long => "--ssh-port PORT",
      :description => "The ssh port",
      :default => "22",
      :proc => Proc.new { |key| Chef::Config[:knife][:ssh_port] = key }

    option :ssh_gateway,
      :short => "-G GATEWAY",
      :long => "--ssh-gateway GATEWAY",
      :description => "The ssh gateway",
      :proc => Proc.new { |key| Chef::Config[:knife][:ssh_gateway] = key }

    option :identity_file,
      :short => "-i IDENTITY_FILE",
      :long => "--identity-file IDENTITY_FILE",
      :description => "The SSH identity file used for authentication"

    option :prerelease,
      :long => "--prerelease",
      :description => "Install the pre-release chef gems"

    option :bootstrap_version,
      :long => "--bootstrap-version VERSION",
      :description => "The version of Chef to install",
      :proc => lambda { |v| Chef::Config[:knife][:bootstrap_version] = v }

    option :bootstrap_proxy,
      :long => "--bootstrap-proxy PROXY_URL",
      :description => "The proxy server for the node being bootstrapped",
      :proc => Proc.new { |p| Chef::Config[:knife][:bootstrap_proxy] = p }

    option :use_sudo,
      :long => "--sudo",
      :description => "Execute the bootstrap via sudo",
      :boolean => true

    option :template_file,
      :long => "--template-file TEMPLATE",
      :description => "Full path to location of template to use",
      :default => false

    option :run_list,
      :short => "-r RUN_LIST",
      :long => "--run-list RUN_LIST",
      :description => "Comma separated list of roles/recipes to apply",
      :proc => lambda { |o| o.split(/[\s,]+/) },
      :default => []

    option :first_boot_attributes,
      :short => "-j JSON_ATTRIBS",
      :long => "--json-attributes",
      :description => "A JSON string to be added to the first run of chef-client",
      :proc => lambda { |o| JSON.parse(o) },
      :default => {}

    option :host_key_verify,
      :long => "--[no-]host-key-verify",
      :description => "Verify host key, enabled by default.",
      :boolean => true,
      :default => true


    attr_reader :kvm_name

    def initialize(*args)
      super
      config[:distro] = 'chef-full'
    end

    def run
      tries = 5
      @kvm_name = config[:chef_node_name] = name_args.first
      ip_address = create_new_container
      begin
        bootstrap_container(ip_address)
      rescue Errno::EHOSTUNREACH
        if(tries > 0)
          tries -= 1
          puts "Failed to connect. Will wait and retry (#{tries} retries remaining)"
          retry
        else
          raise
        end
      end
    end

    private

    def kvm_base
      config[:kvm_node]
    end

    def create_new_container
      knife_ssh(
        kvm_base, 
        "sudo /usr/local/bin/knife_kvm create #{kvm_name} " <<
        "--memory #{config[:kvm_memory]} --vcpus #{config[:kvm_vcpus]} " <<
        "--maxvcpus #{config[:kvm_maxvcpus]}"
      ).stdout.to_s.split(':').last.to_s.strip
    end

    def bootstrap_container(ip_address)
      bootstrap = Chef::Knife::Bootstrap.new
      bootstrap.config = config
      bootstrap.name_args = [ip_address]
      bootstrap.run
    end

    def knife_ssh(addr, command)
      cmd = "ssh -o StrictHostKeyChecking=no #{"{config[:kvm_ssh_user]}@" if config[:kvm_ssh_user]}#{addr} #{command}"
      so = Mixlib::ShellOut.new(cmd,
        :logger => Chef::Log.logger,
        :live_stream => $stdout
      ).run_command
      so.error!
      so
    end
  end
end
