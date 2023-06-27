# TeachCallElixir

**Dependencies:**

If you're using Homebrew versions of elixir and erlang, the following command is advisable

`brew upgrade erlang elixir`

If you have ASDF installed, then just do

`asdf install`

**How to run:**

Without benchmark:

`./bin/run`

With benchmark ips calc:

`./bin/brun`

**Benchmark**

```
Name           ips        average  deviation         median         99th %
task          0.35         2.84 s     ±9.96%         2.79 s         3.22 s

Memory usage statistics:

Name    Memory usage
task         2.10 GB
```

```
________________________________________________________
Executed in    3.23 secs    fish           external
   usr time    4.52 secs    0.10 millis    4.52 secs
   sys time    0.93 secs    1.56 millis    0.93 secs

```
