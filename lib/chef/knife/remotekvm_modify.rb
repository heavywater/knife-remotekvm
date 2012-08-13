require 'knife-remotekvm/helpers'

module RemoteKVM
  class RemotekvmModify < Chef::Knife::Ssh

    include RemoteKVM::Helpers

    banner 'knife remotekvm modify NODE_NAME'

    option :kvm_node,
      :short => '-k FQDN|IP',
      :long => '--kvm-node FQDN|IP',
      :description => 'KVM enabled node',
      :required => true

    option :kvm_ssh_user,
      :short => '-X USERNAME',
      :long => '--kvm-ssh-user USERNAME'
   
    def run
      ui.say "Sorry, not ready yet"
    end

  end
end
