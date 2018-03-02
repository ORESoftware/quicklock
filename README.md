

## QuickLock

### To use the simple bash version:

##### <i>install</i>: `$ curl -o- https://raw.githubusercontent.com/oresoftware/quicklock/master/install.sh | bash`


or

##### <i>install</i>: `$ wget -q0 https://raw.githubusercontent.com/oresoftware/quicklock/master/install.sh | bash`

### To use the complex node.js version:

#####  <i>install</i>: `$ npm install -g quicklock`


### Simple usage

```bash
#!/usr/bin/env bash

# acquire lock. will exit with exit code 1, if lock cannot be acquired the first time
# first and only argument is an optional lockname, if no argument passed, $PWD will be used

ql_acquire_lock "$PWD"  

# your critical code goes here

foobarbaz --watch   # this can be whatever you want

# when the script/process exits, lock will automatically be released

```

### Advanced usage

```bash
#!/usr/bin/env bash

ql_acquire_lock "$PWD" 

# your critical code goes here

echo "foo bar bar"

# we can release the lock here if we want and continue with more commands 

ql_release_lock true  # true is optional argument, if true is passed, will exit on failure to release lock

# we released the lock already, because we are done with the critical section
# now we can run whatever

dosomethingelse here


```

### Complicated Usage With Node.js

```bash
#!/usr/bin/env bash

quicklock $$

# your critical code goes below the above statement
tsc --watch   # this can be whatever you want

```

what the above does is ensure that this script only runs once. If you try to run 
the same script again from the same working directory, you will get a lock related error.

You pass the pid ($$) of the shell process to quicklock, so that it releases the lock
when the shell process dies.


### Advanced usage

```bash
#!/usr/bin/env bash

quicklock $$ "<lockname>"  # lockname is some string of your own choosing

tsc --watch

```

with the above usage, we pass some lockname, this will use lockname as the unique identifier,
instead of the default which is $(pwd).

One recommended thing to do, would be to use:

``` quicklock $$ $(npm --root)```


or some other command that uniquely identifies your project, 
even if you aren't executing the command from
the root of your project (by accident, or whatnot);


