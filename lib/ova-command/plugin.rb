module VagrantPlugins
  module OvaCommand
    class Plugin < Vagrant.plugin(2)
      name 'ova'
      description 'Stratio converter from vbox to vmware'

      command "ova" do
        require_relative "command"
        Command
      end

    end
  end
end

