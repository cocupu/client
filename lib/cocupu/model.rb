module Cocupu
  class Model
    attr_accessor :values, :conn
    def initialize(values)
      self.conn = Thread.current[:cocupu_connection] 
      self.values = values
    end
    
    def self.find(identity, pool, args)      
      unless args == :all
        raise Exception "Cocupu::Model.find only supports one use case - find all. Try Cocupu::Model.find(identity, pool, :all)."
      end
      conn = Thread.current[:cocupu_connection]
      url = "/#{identity}/#{pool}/models.json"
      models_json = JSON.parse(conn.get(url).body)
      models = models_json.map {|json| Cocupu::Model.new(json) }
      return models
    end
    
    def self.load(id)
      conn = Thread.current[:cocupu_connection]
      url = "/models/#{id}.json"
      json = JSON.parse(conn.get(url).body)
      return Cocupu::Model.new(json)
    end

    def name
      values['name']
    end

    def label=(label)
      values['label'] = label
    end

    def identity
      values['identity']
    end

    def pool
      values['pool']
    end

    def url
      values['url'] || "/#{identity}/#{pool}/models"
    end

    def url=(url)
      values['url'] = url
    end

    def id=(id)
      values['id'] = id
    end

    def fields=(fields)
      values['fields'] = fields
    end
    
    def fields
      values['fields']
    end

    def associations=(fields)
      values['associations'] = fields
    end
    
    def associations
      values['associations']
    end

    def id
      values['id']
    end

    def save
      #req_url = "http://#{host}:#{port}#{url}.json?auth_token=#{token}"
      response = if id
        conn.put("#{url}.json", body: {model: values})
      else
        conn.post("#{url}.json", body: {model: values})
      end
      raise "Error saving models: #{response.inspect}" unless response.code >= 200 and response.code < 300
      if (response['id'])
        self.id = response['id']
        self.url = response['url']
      end
      values
    end

  end
end
