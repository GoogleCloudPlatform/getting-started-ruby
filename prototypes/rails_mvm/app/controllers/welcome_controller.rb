class WelcomeController < ApplicationController

  def index
    render text: "Hello from Rails @ #{Time.now}"
  end

end
