module Occi::Api::Dsl

  module MainMethods

    def resource(*args)
      check
      @client.get_resource(*args)
    end

    def link(*args)
      check
      @client.get_link(*args)
    end

    def list(*args)
      check
      @client.list(*args)
    end

    def describe(*args)
      check
      @client.describe(*args)
    end

    def create(*args)
      check
      @client.create(*args)
    end

    def delete(*args)
      check
      @client.delete(*args)
    end

    def trigger(*args)
      check
      @client.trigger(*args)
    end

    def update(*args)
      check
      @client.update(*args)
    end

    def refresh
      check
      @client.refresh
    end

    def model
      check
      @client.model
    end

  end

end
