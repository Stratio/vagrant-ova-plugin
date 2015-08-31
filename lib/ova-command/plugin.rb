require "vagrant"

module VagrantPlugins
  module CommandOva
    class Plugin < Vagrant.plugin('2')
      name 'Ova'
      description 'Stratio converter from vbox to vmware'

      command("ova") do
        require_relative "command"
        Command
      end      
    end   
  end
end

