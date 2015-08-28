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
        Command
      end      
    end
    class Command < Vagrant::Command::Base
      def self.synopsis
        "Custom command to convert from vagrant vbox machines to vmware machines"
      end
      def exportOvf(arg)
        system("vboxmanage export #{arg} --output #{arg}.ovf")
      end
      def execute
        options = {}
        opts = OptionParser.new do |opts|
          opts.banner = "Usage: vagrant ovf [vm-name]"
        end
        #version = '0'
        #provider = 'virtualbox'
        #Parse the options
        argv = parse_options(opts)
        modovf = argv[0]
        
        exportOvf(modovf)
              
        
        puts "Finding box with name #{argv[0]}"        
        

        ##OJO!!!!       
                      
        box_ovf = argv[0]+'.ovf'        
        vagrant_file = 'Vagrantfile'

        box_mf = argv[0]+'.mf'
        box_disk1 = argv[0]+'-disk1.vmdk'
        doc = OVFDocument.parse(File.new(box_ovf), &:noblanks)
        doc.add_file(:href => 'Vagrantfile')
        doc.add_vmware_support
        File.open(box_ovf, 'w') {|f| doc.write_xml_to f}

        # rewrite SHA1 values of box.ovf & Vagrantfile
        box_ovf_sha1 = OpenSSL::Digest::SHA1.hexdigest(File.read(box_ovf))
        vagrant_file_sha1 = OpenSSL::Digest::SHA1.hexdigest(File.read(vagrant_file))
        box_disk1_sha1 = OpenSSL::Digest::SHA1.hexdigest(File.read(box_disk1))
        File.open(box_mf, 'w') do |f|
          f.write("SHA1 (box.ovf)= #{box_ovf_sha1}\n")
          f.write("SHA1 (box-disk1.vmdk)= #{box_disk1_sha1}\n")
          f.write("SHA1 (Vagrantfile)= #{vagrant_file_sha1}")
        end
        
        file = File.new("../pom.xml")
        doc = Document.new(file)
            
        stratio_module_version = doc.root.elements['version'].text
        #TODO change system 
        system("tar cfv #{argv[0]}-#{stratio_module_version }.ova #{argv[0]}.ovf #{argv[0]}-disk1.vmdk #{argv[0]}.mf Vagrantfile")
        return 0
      end        
    end   
  end
end
Vagrant.commands.register(:ova) { Command }

