# Mutex: concurrency vs. parallelism

**Parallelism** (multiple machines/processes executing literally simultaneously) and **concurrency** (multiple threads interleaved within one process) are different problems needing different fixes.

Snowflake's `machine_id` + DB unique constraint handle **parallelism** — different machines never collide. But the `@sequence` counter inside one `GeneratorService` instance is shared, mutable state — unsafe across **concurrent threads in the same process**, even on a single machine.

## The race

```ruby
def next_sequence
  current = @sequence        # READ
  @sequence = current + 1    # MODIFY + WRITE
  @sequence
end
```

`@sequence += 1` is three steps (read, add, write), not one atomic step. Two threads can both read the same value before either writes back — both "win," both generate the same id.

## Demonstrated (20 concurrent threads, unsafe counter)

Only 5 unique values came out of 20 calls — massive duplication under interleaving.

## Fix: wrap the read-modify-write in a Mutex

```ruby
def next_sequence
  @mutex.synchronize do
    current = @sequence
    @sequence = current + 1
    @sequence
  end
end
```

Same 20 threads → 20/20 unique values. The mutex forces each thread to fully finish its read-modify-write before the next can start.

**Cost:** threads queue up waiting for the lock — a real but usually tiny cost (the critical section is microseconds). Under very high contention, a lock-free alternative like `Concurrent::AtomicFixnum` (from the `concurrent-ruby` gem) avoids full lock overhead while keeping the same atomicity guarantee:

```ruby
@sequence = Concurrent::AtomicFixnum.new(0)
@sequence.increment
```

This repo's `GeneratorService#next_id` already wraps its whole read-modify-write block in `@mutex.synchronize` — this note documents *why* that's necessary, not just that it's there.
