class HelloController < ApplicationController
  def sayhello
		@msg = "Hello World"  	
  end


def say
    case params[:something]
    when "hello" then @msg="saying hello"; render action: :sayhello
    when "goodbye" then @msg="saying goodbye"; render action: :saygoodbye
    when "badword" then render nothing: true
    else 
      @msg="saying goodbye"; render action: :sayhello
    end
  end

 end