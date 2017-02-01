class InboundOrderTransition < ActiveRecord::Base
  belongs_to :inbound_order, inverse_of: :inbound_order_transitions

  after_destroy :update_most_recent, if: :most_recent?

  private

  def update_most_recent
    last_transition = inbound_order.inbound_order_transitions.order(:sort_key).last
    return unless last_transition.present?
    last_transition.update_column(:most_recent, true)
  end
end
