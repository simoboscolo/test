class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :configure_permitted_parameters, if: :devise_controller?

  def current_organisation
    if user_signed_in?
      return @organisation if @organisation.present?
      @organisation = current_user.organisations.find(params[controller_name == 'organisations' ? :id : :organisation_id]) rescue @organisation = current_user.organisations.first
      return @organisation
    else
      org = get_org_from_params
      if org.present?
        @organisation = org
        return @organisation
      else
        return nil
      end
    end
  end
  helper_method :current_organisation # Make this method visible to views as well


  protected
    def get_org_from_params
      id = params[controller_name == 'organisations' ? :id : :organisation_id]
      if id.present?
        Organisation.find(id)
      else
        nil
      end
    end

    def after_sign_in_path_for(resource)
      request.env['omniauth.origin'] || stored_location_for(resource) || organisation_elections_path(current_user.organisations.first)
    end

    def authenticate_user!(options = {})
      if user_signed_in?
        super(options)
      else
        redirect_to login_path, notice: "You're not logged in!"
      end
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) << :name
      devise_parameter_sanitizer.for(:sign_up) << :organisation_id
    end
end
