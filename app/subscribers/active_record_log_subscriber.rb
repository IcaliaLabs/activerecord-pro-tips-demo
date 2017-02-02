# = ActiveRecordLogSubscriber
# Subscribes to the ActiveRecord notifications, and captures the issued SQL commands, redirecting
# them to the user via ActionCable:
class ActiveRecordLogSubscriber < ActiveSupport::LogSubscriber
  def sql(event)
    ActionCable.server.broadcast 'logger_output',
                                 type: 'sql',
                                 name: event.payload[:name],
                                 duration: event.duration,
                                 sql: event.payload[:sql]
  end
end
