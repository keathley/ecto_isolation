# EctoIsolation

This is a test framework to show how to set the transaction level in ecto
using the postgres adapter. I'm using postgres as an example here but this
should be directly comparable to other databases.

## Scenario

The test problem that we're trying to solve is a "Lost Update" as
described by [Martin Kleppmann](https://github.com/ept/hermitage). The
specific interleaving of operations would look like this:

```sql
begin; set transaction isolation level read committed; -- T1
begin; set transaction isolation level read committed; -- T2
select * from test where id = 1; -- T1
select * from test where id = 1; -- T2
update test set value = 11 where id = 1; -- T1
update test set value = 11 where id = 1; -- T2, BLOCKS
commit; -- T1. This unblocks T2, so T1's update is overwritten
commit; -- T2
```

The solution to this problem is to use "repeatable read" isolation instead
of "read committed".

## Running Tests

A single coordinator process spawns two children, both of which start
a transaction. The interleavings are controled by the central coordinator
in order to cause consistent failures.

In order to run the tests first you need to setup the database:

    $ mix ecto.create
    $ mix ecto.migrate
    $ echo "insert into coupons (code) values ('foo');" | psql -U postgres -d ecto_isolation

Running the tests is done like so:

```elixir
# This transaction will not fail and you'll lose updates
iex> EctoIsolation.Coordinator.race(EctoIsolation.UnsafeTransaction)

# This transaction uses the correct isolation level and you'll see failures
iex> EctoIsolation.Coordinator.race(EctoIsolation.SafeTransaction)
```

