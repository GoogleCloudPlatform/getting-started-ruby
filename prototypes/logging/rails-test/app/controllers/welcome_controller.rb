class WelcomeController < ApplicationController

  def index
    Rails.logger.info "YAY!  You logged something!  :)"

    render text: "Hello from Rails @ #{Time.now}"
  end

end
