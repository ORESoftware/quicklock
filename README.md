

## QuickLock

##### <i>install</i>: `$ curl -o- https://raw.githubusercontent.com/oresoftware/quicklock/master/install.sh | bash`

or

##### <i>install</i>: `$ wget -q -O - https://raw.githubusercontent.com/oresoftware/quicklock/master/install.sh | bash`


### Simple usage

```bash
#!/usr/bin/env bash

# acquire lock. will exit with exit code 1, if lock cannot be acquired the first time
# first and only argument is an optional lockname, if no argument is passed, $PWD will be used as a good default.

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

## Debugging

To get a list of all the quicklock locks that exist, use:

`$ ql_ls`

To determine which process holds a lock, use:

`$ ql_find <lockname>  # lockname is optional`

`ql_find` echos a pid, if the lock exists. To find out information about that pid, you can use:

`$ ps -p <pid>`

or just do this:

`$ ql_find | xargs ps -p`








