require_relative 'version'
require 'vagrant'
require File.dirname(__FILE__)+'/ovf_document'
require 'openssl'
require 'optparse'
require 'rexml/document'
require 'archive/tar/minitar'
include REXML
include Archive::Tar



module VagrantPlugins
  module VagrantOva
    class Plugin < Vagrant.plugin('2')
      name 'vagrant-ova'

      command("ova") do
        Command
      end
    end

    class Command < Vagrant.plugin(2, :command)

      def execute
        options = {}
        opts = OptionParser.new do |opts|
          opts.banner = "Usage: vagrant ovf [vm-name]"
        end

        argv = parse_options(opts) 
        box_ovf = argv[0]+'.ovf'                
        vagrant_file = 'Vagrantfile'
        box_mf = argv[0]+'.mf'
        box_disk1 = argv[0]+'-disk1.vmdk'


      
        puts "Exporting VM...It only takes a couple of minutes"
        mach = @env.machine(:default, :virtualbox)        
        mach.provider.driver.export(box_ovf)
        

        puts "Translating OVF document..."
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
        puts "Forming your ova file: "+ argv[0]+"-"+stratio_module_version+".ova"
        files = [ argv[0]+'.ovf', argv[0]+'-disk1.vmdk', argv[0]+'.mf', 'Vagrantfile']
        puts "Forming your ova file: "
          
        File.open(argv[0]+"-"+stratio_module_version+".ova", 'wb') do |f|
          Archive::Tar::Minitar::Writer.open(f) do |w|
            w.add_file(files[0],:mode => 0664, :mntime => Time.now) do |stream, io|
              open(files[0], "rb"){|f| stream.write(f.read)} 
            end
            w.add_file(files[1],:mode => 0664, :mntime => Time.now) do |stream, io|
              open(files[1], "rb"){|f| stream.write(f.read)}
            end
            w.add_file(files[2],:mode => 0664, :mntime => Time.now) do |stream, io|
              open(files[2], "rb"){|f| stream.write(f.read)}
            end
            w.add_file(files[3],:mode => 0664, :mntime => Time.now) do |stream, io|
              open(files[3], "rb"){|f| stream.write(f.read)}
            end
          end
        end



        exit 0      
        
      end   
    end
  end
end
