module Playground
  module Concurrency
    class MutexExamples
      class << self
        Order = Struct.new(:amount, :status) do
          def pending?
            status == 'pending'
          end

          def collect_payment
            puts 'Collecting payment...'
            self.status = 'paid'
          end
        end

        # This method can collect the payment multiple times
        def payment_problem
          order = Order.new(100.00, 'pending')

          5.times.map do
            Thread.new do
              if order.pending?
                order.collect_payment
              else
                puts 'Paid order...'
              end
            end
          end.each(&:join)

          nil
        end

        # Use mutex to lock and unlock the portion of the code for other threads
        #   to make sure that only one thread will access the code
        def payment_fix
          order = Order.new(100.00, 'pending')

          5.times.map do
            Thread.new do
              mutex.synchronize do
                if order.pending?
                  order.collect_payment
                else
                  puts 'Paid order...'
                end
              end
            end
          end.each(&:join)

          nil
        end

        # This method will return different array sizes
        # However, due to the MRI used by Ruby
        #   race conditions in << operator are less likey
        #   but they are still not thread-safe
        def append_problem
          shared_array = []

          10.times.map do |i|
            Thread.new do
              1000.times do |j|
                shared_array << "[#{i}][#{j}]"
              end
            end
          end.each(&:join)

          puts shared_array.size
        end

        # Using mutex to make << operator thread-safe
        # However, a threadoff with this solution is performace
        # One thread would lock the code and other threads will
        #   wait until it has been unlocked
        def append_fix
          shared_array = []

          10.times.map do |i|
            Thread.new do
              1000.times do |j|
                mutex.synchronize do
                  shared_array << "[#{i}][#{j}]"
                end
              end
            end
          end.each(&:join)

          puts shared_array.size
        end

        # This solution avoids the mutable array which avoids race conditions
        # Doesn't need to use mutex to make it thread-safe
        def append_fix_better
          threads =
            10.times.map do |i|
              Thread.new do
                local_array = []
                1000.times { |j| local_array << "[#{i}][#{j}]" }
                local_array
              end
            end

          shared_array = threads.flat_map(&:value)
          puts shared_array.size
        end

        # This method will return different totals
        # However, due to the MRI used by Ruby
        #   race conditions in += operator are less likey
        #   but they are still not thread-safe
        def count_problem
          total = 0

          10.times.map do
            Thread.new do
              1000.times do
                total +=1
              end
            end
          end.each(&:join)

          puts total
        end

        # Using mutex to make << operator thread-safe
        # However, a threadoff with this solution is performace
        # One thread would lock the code and other threads will
        #   wait until it has been unlocked
        def count_fix
          total = 0

          10.times.map do
            Thread.new do
              1000.times do
                mutex.synchronize do
                  total +=1
                end
              end
            end
          end.each(&:join)

          puts total
        end

        def count_fix_better
          total = 0

          10.times.map do
            Thread.new do
              local_total = 0
              1000.times { local_total +=1 }

              mutex.synchronize { total += local_total }
            end
          end.each(&:join)

          puts total
        end

        # Doesn't need to use mutex to make it thread-safe
        def count_fix_best
          total =
            10.times.map do
              Thread.new do
                local_total = 0
                1000.times { local_total +=1 }
                local_total
              end
            end.sum(&:value)

          puts total
        end

        private

        def mutex
          @mutex ||= ::Mutex.new
        end
      end
    end
  end
end
