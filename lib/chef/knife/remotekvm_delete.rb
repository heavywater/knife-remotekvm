require 'knife-remotekvm/helpers'

module RemoteKVM
  class RemotekvmDelete < Chef::Knife::Ssh

    include RemoteKVM::Helpers

    banner 'knife remotekvm delete NODE_NAME'

    option :kvm_node,
      :short => '-k FQDN|IP',
      :long => '--kvm-node FQDN|IP',
      :description => 'KVM enabled node',
      :required => true

    option :kvm_ssh_user,
      :short => '-X USERNAME',
      :long => '--kvm-ssh-user USERNAME'
   
    def run
      ui.confirm "Are you sure you want to delete KVM node: #{name_args.first}"
      knife_ssh(config[:kvm_node], "sudo knife_kvm delete #{name_args.first}")
    end

  end
end
