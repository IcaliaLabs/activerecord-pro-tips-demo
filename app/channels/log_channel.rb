class LogChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'logger_output'
  end
end
