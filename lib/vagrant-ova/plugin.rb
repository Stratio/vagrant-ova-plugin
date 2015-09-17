require_relative 'version'
require 'vagrant'
require File.dirname(__FILE__)+'/ovf_document'
require 'openssl'
require 'optparse'
require 'rexml/document'
require 'archive/tar/minitar'
require 'log4r'


include REXML
include Archive::Tar
include Log4r

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
          opts.banner = "Usage: vagrant ova [output-name]"
        end
        machname = @env.machine(:default, :virtualbox).box.name        
        mylog = Logger.new ':'
        mylog.outputters = Outputter.stdout        
        argv = parse_options(opts) 
        box_ovf = machname+'.ovf'                
        vagrant_file = 'Vagrantfile'
        box_mf = machname+'.mf'
        box_disk1 = machname+'-disk1.vmdk'
        mach = @env.machine(:default, :virtualbox)          
        

        if File.exist?(box_ovf)
          mylog.warn box_ovf+" already exists. Skipping its generation...";
        else 
          if mach.provider.driver.read_state.to_s.eql?"running"
            mylog.warn box_ovf+" is being up, halting it..."
            mach.provider.driver.halt                   
          end
          mf = mach.provider.driver.read_machine_folder+"/"+machname  
          vmdkf = ""      
          Find.find(mf) do |path|
            vmdkf = path if path =~ /.*\.vmdk$/
          end          
          ##Size to MB and time to secs.
          disksize =  File.size(vmdkf)/ 1024.0 / 1024.0                 
          timeto = disksize* 0.0005*60                  
          mylog.info "Disk size: " + disksize.round(2).to_s + "MB ..."                                
          mylog.info "Exporting VM, it will take around "+timeto.round(0).to_s+" seconds ..."          
          mach.provider.driver.export(box_ovf)          
        end

        mylog.info "Translating OVF document ..."
        doc = OVFDocument.parse(File.new(box_ovf), &:noblanks)
        doc.add_file(:href => 'Vagrantfile')
        doc.add_vmware_support
        File.open(box_ovf, 'w') {|f| doc.write_xml_to f}        
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
        mylog.info "Forming your ova file: "+ argv[0]+".ova ..."
        files = [ machname+'.ovf', machname+'-disk1.vmdk', machname+'.mf', 'Vagrantfile']      
          
        File.open(argv[0]+".ova", 'wb') do |f|
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
