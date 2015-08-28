require_relative 'ova-command/plugin'
#require 'vagrant'
require_relative 'ova-command/command'

Vagrant.commands.register(:ova){OvaCommand::Command}
#module VagrantPlugins
#	class Plugin < Vagrant.plugin("2")
#		name "ova"
#		description <<-DESC 
#		Stratio converter from vbox to vmware
#		DESC
#
#		command("ova") do
#			require File.expand_path("/ova-command", __FILE__)
#			Command
#		end
#	end
#end