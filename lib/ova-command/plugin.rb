require 'optparse'
require File.dirname(__FILE__)+'/ovf_document'
require 'openssl'
require 'rexml/document'
include REXML

module Vagrant
  module Command
    class Plugin < Vagrant.plugin('2')
      name 'Ova'
      description 'Stratio converter from vbox to vmware'

      command "ova" do
        require_relative "command"
        Command
      end      
    end   
  end
end

