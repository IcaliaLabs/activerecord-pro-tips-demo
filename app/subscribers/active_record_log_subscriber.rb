# = ActiveRecordLogSubscriber
# Subscribes to the ActiveRecord notifications, and captures the issued SQL commands, redirecting
# them to the user via ActionCable:
class ActiveRecordLogSubscriber < ActiveSupport::LogSubscriber
  IGNORED_QUERY_NAMES = [
    'SCHEMA',
    'ActiveRecord::SchemaMigration Load'
  ].freeze

  def self.extract_data_from_payload(payload)
    data = payload.slice(:name, :sql)

    # Replace any query parameter binding...
    payload[:binds].each_with_index do |bind, index|
      data[:sql] = data[:sql].gsub "$#{index + 1}", "'#{bind.value}'"
    end

    data
  end

  def self.sql(event)
    payload = event.payload
    return if payload[:name].in? IGNORED_QUERY_NAMES
    broadcast_data = { type: :sql, duration: event.duration }
    broadcast_data.merge! extract_data_from_payload(payload)
    ActionCable.server.broadcast 'logger_output', broadcast_data
  end

  delegate :sql, to: :class
end
