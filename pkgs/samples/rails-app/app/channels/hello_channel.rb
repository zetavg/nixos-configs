class HelloChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'hello_messages'
  end

  def unsubscribed; end
end
