module Requests
  module JSONHelpers

    def json
      JSON.parse(last_response.body)      
    end

    def response
      last_response
    end

  end
end