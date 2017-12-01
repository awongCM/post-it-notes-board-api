module Requests
  module JSONHelpers

    def json
      JSON.parse(last_response.body)      
    end

  end
end