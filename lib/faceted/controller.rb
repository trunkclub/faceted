module Faceted

  module Controller

    # For rendering a response with a single object, e.g.
    # render_response(@addresses)
    def render_response(obj)
      render :json => {
        success:  obj.success,
        response: obj.to_hash,
        errors:   obj.errors
      }
    end

    # For rendering a response with a multiple objects, e.g.
    # render_response_with_collection(:addresses, @addresses)
    def render_response_with_collection(key, array)
      render :json => {
        success: true,
        response: {"#{key}".to_sym => array},
        errors:   nil
      }
    end

    # In your base API controller:
    # rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
    def render_400(exception)
      render :json => {
        success: false,
        response: nil,
        errors: "Record not found: #{exception.message}"
      }, :status => 404
    end

    # In your base API controller:
    # rescue_from Exception, :with => :render_500
    def render_500(exception)
      Rails.logger.info("!!! #{self.class.name} exception caught: #{exception} #{exception.backtrace.join("\n")}")
      render :json => {
        success: false,
        response: nil,
        errors: "#{exception.message}"
      }, :status => 500
    end

  end

end