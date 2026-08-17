# TODO: Implement this service

module Playground
  module Concurrency
    class DatabaseLockTickets
      class << self
        def purchase_ticket_problem(event_id, user_id)
          event = Event.find_by(id: event_id)
          return nil if event.nil?
          return nil if event.sold_out?

          user = User.find_by(id: user_id)
          return nil if user.nil?

          event.tickets.create(user: user)
        end

        def purchase_ticket(event_id, user_id)
          event = Event.find_by(id: event_id)
          return nil if event.nil?
          return nil if event.sold_out?

          user = User.find_by(id: user_id)
          return nil if user.nil?

          event.tickets.create(user: user)
        end
      end
    end
  end
end
