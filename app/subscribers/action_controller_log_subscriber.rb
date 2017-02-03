# = ActionControllerLogSubscriber
# Subscribes to the ActionController notifications, and captures the 'Completed 200 OK' log event
# and redirects it to the user via ActionCable
class ActionControllerLogSubscriber < ActiveSupport::LogSubscriber
  delegate :process_action, to: :class

  def self.process_action(event)
    payload   = event.payload
    additions = ActionController::Base.log_process_action(payload)

    message = generate_message event, payload, additions

    ActionCable.server.broadcast 'logger_output', type: 'controller', message: message
  end

  def self.generate_message(event, payload, additions)
    status = get_payload_status payload
    message = "Completed #{status} #{Rack::Utils::HTTP_STATUS_CODES[status]} in %.0fms" % event.duration
    return message if additions.blank?
    "#{message} (#{additions.join(" | ")})"
  end

  def self.get_payload_status(payload)
    status = payload[:status]
    return status if status.present?

    payload_exception = payload[:exception]
    return nil unless payload_exception.present?
    Rack::Utils.status_code(ActionDispatch::ExceptionWrapper.new({}, payload_exception).status_code)
  end
end
