require 'knife-remotekvm/helpers'

module RemoteKVM
  class RemotekvmList < Chef::Knife::Ssh

    include RemoteKVM::Helpers

    banner 'knife remotekvm list'

    option :kvm_node,
      :short => '-k FQDN|IP',
      :long => '--kvm-node FQDN|IP',
      :description => 'KVM enabled node',
      :required => true

    option :kvm_ssh_user,
      :short => '-X USERNAME',
      :long => '--kvm-ssh-user USERNAME'
   
    def run
      knife_ssh(config[:kvm_node], "sudo knife_kvm list")
    end

  end
end
