module Cocupu
  class File
    attr_accessor :node, :file_name, :file
    attr_reader :conn
    def initialize(node, file_name, file)
      self.node = node
      self.file_name = file_name
      self.file = file
      @conn = Thread.current[:cocupu_connection] 
    end

    def url
      node.url + "/files"
    end

    def save
      response = conn.post("#{url}.json", query: {file_name: file_name, file: file})
      unless response.code >= 200 and response.code < 300
        error = JSON.parse(response.body)
        raise "Error saving file: #{error.inspect}"
      end
    end
  end
end
