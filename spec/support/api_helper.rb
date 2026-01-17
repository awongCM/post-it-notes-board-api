module APIHelper
  include Rack::Test::Methods

  def app
    Rails.application
  end

  # Override HTTP methods to handle params correctly for JSON API
  def get(uri, params: {}, **options)
    super(uri, params, options.merge('CONTENT_TYPE' => 'application/json'))
  end

  def post(uri, params: {}, **options)
    super(uri, params.to_json, options.merge('CONTENT_TYPE' => 'application/json'))
  end

  def put(uri, params: {}, **options)
    super(uri, params.to_json, options.merge('CONTENT_TYPE' => 'application/json'))
  end

  def patch(uri, params: {}, **options)
    super(uri, params.to_json, options.merge('CONTENT_TYPE' => 'application/json'))
  end

  def delete(uri, params: {}, **options)
    super(uri, params, options.merge('CONTENT_TYPE' => 'application/json'))
  end
  
end