require 'nokogiri'

module VagrantPlugins
  module CommandOva
  class OVFDocument < Nokogiri::XML::Document
    XMLNS = {
      'rasd' => "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData",
      'vssd' => "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_VirtualSystemSettingData",
      'base' => "http://schemas.dmtf.org/ovf/envelope/1",
      'ovf' => "http://schemas.dmtf.org/ovf/envelope/1",
      'xsi' => "http://www.w3.org/2001/XMLSchema-instance",
      'vbox' => "http://www.virtualbox.org/ovf/machine"
    }

    # Insert a new file with the given attributes
    # :href :: filename of the file
    # :id :: identifier inside the OVF
    def add_file(attrs)
      return if search("//ovf:References/ovf:File[@ovf:href='#{attrs[:href]}']").count == 1
      file = Nokogiri::XML::Node.new 'File', self
      file['ovf:href'] = attrs[:href] if attrs[:href]
      if attrs[:id]
        file['ovf:id'] = attrs[:id]
      else
        n = filecount + 1
        file['ovf:id'] = "file#{n}"
      end
      at('//ovf:References').add_child file
    end

    def filecount
      search('//ovf:References/ovf:File').count
    end

    def add_virtual_system_type(type)
      at('//vssd:VirtualSystemType').content += " #{type}"
    end

    def find_item_by_resource_type(type)
      at("//rasd:ResourceType[text()=\"#{type}\"]/..")
    end

    def add_vmware_support
      return if search("//vssd:VirtualSystemType[contains(text(), 'vmx-04 vmx-06 vmx-08 ')]").count == 1
      %w(vmx-04 vmx-06 vmx-08).each {|t| add_virtual_system_type t}
    end

    def search(path, ns = {})
      super path, XMLNS.merge(ns)
    end
  end
end
end
