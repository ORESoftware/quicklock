

## QuickLock

##### <i>install</i>: `$ curl -o- https://raw.githubusercontent.com/oresoftware/quicklock/master/install.sh | bash`

or

##### <i>install</i>: `$ wget -q -O - https://raw.githubusercontent.com/oresoftware/quicklock/master/install.sh | bash`


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

### Explicit unlocking

For most use cases you don't need to explicitly unlock.

```bash
#!/usr/bin/env bash

ql_acquire_lock "$PWD" 

# your critical code goes here
echo "foo bar bar"

# we can release the lock here if we want and continue with more commands 

ql_release_lock <lockname>  # lockname is an optional argument

# we released the lock, because we are done with the critical section
# now we can run whatever

dosomethingelse here


```




