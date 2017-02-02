#= LogChannel
# This is the channel used to send the Rails logger data to the clients
class LogChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'logger_output'
  end
end
