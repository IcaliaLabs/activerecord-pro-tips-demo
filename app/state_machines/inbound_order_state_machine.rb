class InboundOrderStateMachine
  include Statesman::Machine
  include Statesman::Events

  state :pending, initial: true
  state :received
  state :completed

  transition from: :pending,  to: :received
  transition from: :received, to: :completed

  guard_transition(to: :received) do |order|
    order.inbound_logs.any?
  end

  guard_transition(to: :completed) do |order|
    order.inbound_logs.without_shelf.empty?
  end

  before_transition(to: :completed) do |order, transition|
    order.store_items!
  end

  event :receive do
    transition from: :pending, to: :received
  end

  event :complete do
    transition from: :received, to: :completed
  end
end
