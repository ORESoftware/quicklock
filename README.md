

## QuickLock

# npm install -g quicklock

### Usage

```bash
#!/usr/bin/env bash

quicklock $$

tsc --watch

```


what the above does is ensure that this script only runs once. If you try to run 
the same script again from the same working directory, you will get a lock file error.

You pass the pid of the shell process to quicklock, so that it releases the lock
when the shell process dies.


### Advanced usage

```bash
#!/usr/bin/env bash

quicklock $$ lockname

tsc --watch

```

with the above usage, we pass some lockname, this will use lockname as the unique identifier,
instead of the default which is $(pwd).

One recommended thing to do, would be to use:

``` quicklock $$ $(npm --root)```


or some other command that uniquely identifies your project, 
even if you aren't executing the command from
the root of your project (by accident, or whatnot);


