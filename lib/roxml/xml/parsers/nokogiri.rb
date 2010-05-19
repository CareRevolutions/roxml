require 'nokogiri'

module ROXML
  module XML # :nodoc:all

    class << self
      def new_node(name)
        Nokogiri::XML::Node.new(name, Document.new)
      end

      def add_node(parent, name)
        add_child(parent, Nokogiri::XML::Node.new(name, parent.document))
      end

      def add_cdata(parent, content)
        parent.add_child(Nokogiri::XML::CDATA.new(parent.document, content))
      end

      def add_child(parent, child)
        parent.add_child(child)
      end
    end

    Document = Nokogiri::XML::Document
    Element = Nokogiri::XML::Element
    Node = Nokogiri::XML::Node

    module Error; end

    class Parser
      class << self
        def parse(string)
          Nokogiri::XML(string)
        end

        def parse_file(path) #:nodoc:
          path = path.sub('file:', '') if path.starts_with?('file:')
          parse(open(path))
        end

        def parse_io(stream) #:nodoc:
          parse(stream)
        end
      end
    end

    class Document
      def save(path)
        open(path, 'w') do |file|
          file << serialize
        end
      end

      def default_namespace
        'xmlns' if root.namespaces['xmlns']
      end
    end

    module NodeExtensions
      def search(xpath, roxml_namespaces = {})
        xpath = "./#{xpath}"
        (roxml_namespaces.present? ? super(xpath, roxml_namespaces) : super(xpath))
      end

      def roxml_attributes
        self
      end

      def default_namespace
        document.default_namespace
      end
    end

    class Element
      include NodeExtensions

      def empty?
        children.empty?
      end
    end

    class Node
      include NodeExtensions
      alias :remove! :remove
    end
  end
end