# MrMurano

[![Gem Version](https://badge.fury.io/rb/MrMurano.svg)](https://badge.fury.io/rb/MrMurano)
[![Build Status](https://travis-ci.org/tadpol/MrMurano.svg?branch=master)](https://travis-ci.org/tadpol/MrMurano)
[![Inline docs](http://inch-ci.org/github/exosite/MrMurano.svg?branch=master)](http://inch-ci.org/github/exosite/MrMurano)

* [Requirements and Setup](#requirements-and-setup)
* [Installation](#installation)
* [Using MrMurano](#using-mrmurano)
* [Features](#features)
  * User has created an account
  * User has installed MrMurano
  * Directory layout definition
    * modules
    * endpoints
    * eventhandlers
    * files
    * specs
* Starting a new project from scratch
  * `mkdir project`
  * `cd project`
  * List businesses to obtain ID
  * Set business ID of project
  * Create a product
  * Save ID of product as returned
  * Define product resources in specific file
    * TODO: define file format
  * `mr syncup --specs`
    * Specify --specs because specs are skipped
    * Only syncs up specs, no other files
  * Create a solution
  * Save ID of solution
  * Associate product to solution
    * `my assign set`
    * TODO: How will this change in Okami?
* Started a new project in UI
  * `mkdir project`
  * `cd project`
  * `mr init`
  * `mr syncdown`
  * `mr syncdown --specs --cors`
* Migrating an existing project from Exosite CLI
  * Option 1: Migrate files in place
    * `cd project`
    * `mr config import`
  * Option 2: Make new directory
    * Follow steps for Started a new project in UI
  * Final steps
    * Manually inspect files for consistency
    * Use `mr status` to verify what files will be uploaded, deleted, changed on next syncup
    * Use `mr status --asdown` to validate files that would be pulled down
* Product tasks
  * Enable device ID
  * List devices
  * Read and write device data
  * Create, retrieve, update, and delete firmware content in content area
* Solution tasks
  * Setup (steps above for getting started)
  * Working with files
    * `mr status`
    * `mr syncup`
    * `mr syncdown`
    * `mr diff`
  * Querying services
    * Keystore
      * Redis
    * Timeseries
      * Influx
    * TSDB
      * Cassandra
    * SQL
      * Postgres
  * Logs for debugging
* Advanced usage
  * `mr config --dump`
  * MR_PASSWORD environment variable for continuation integration stuff
  * MR_CONFIGFILE
  * dotenv
    * --specs --cors --files --endpoints --modules --eventhandlers
    * ( --roles --users)


Do more from the command line with [Murano](https://exosite.com/platform/)

MrMurano is the command-line tool that interacts with Murano and makes different
tasks easier. MrMurano makes it easy to deploy code to a solution, import many
product definitions at once, set up endpoints and APIs, and more.

MrMurano works around the idea of syncing, much like rsync.  Files from your project
directory are synced up (or down) from Murano.

## Requirements and Setup

MrMurano is a [Ruby](https://www.ruby-lang.org/) application and depends on the following gems:
* commander
* highline
* terminal
* mime
* mime
* inifile
* http
* dotenv

## Installation

```
> gem install MrMurano
```
Or
```
> gem update MrMurano
```

You will likely need to be root for the above commands.  If you would rather not
install as root, you can install gems in the user directory.

```
> gem install MrMurano --user-install
```

Your `PATH` may need to be updated to find the installed `mr` command.  See the
[Ruby Gem FAQ](http://guides.rubygems.org/faqs/#user-install).  In short, you need
to add the output of `ruby -rubygems -e 'puts Gem.user_dir'` to your `PATH`.

### Windows Install

The MrMurano gem will install on Windows.  There is also a single Windows binary
Setup installer availible in [releases](https://github.com/exosite/MrMurano/releases)

You can install Ruby on Windows with [RubyInstaller](http://rubyinstaller.org).
You might run into a [known SSL cert issue](http://guides.rubygems.org/ssl-certificate-update/).
If so follow the steps there to update the certs.

## Using MrMurano

### To start from an existing project in Murano
```
mkdir myproject
cd myproject
mr config solution.id XXXXXX
mr syncdown -V
```

Do stuff, see what changed: `mr status` or `mr diff`.
Then deploy with `mr syncup`

### To start a brand new project
There are a few steps and pieces to getting a solution with a product up and
running in Murano. Here is the list.

- Pick a business: `mr account --business`
	If this is the first time you've run `mr` it will ask for your Murano username
	and password.
- Set it: `mr config business.id ZZZZZZZZZ`
- Create a product: `mr product create myawesomeproduct`
- Save the result: `mr config product.id YYYYYYYYY`
- Add resource aliases to specs/resources.yaml
- Sync the product definition up: `mr syncup -V --specs`
- Create a solution: `mr solution create myawesomesolution`
- Save the result: `mr config solution.id XXXXXX`
- Sync solution code up: `mr syncup -V`
- Assign the product to the solution: `mr assign set`

Do stuff, see what changed: `mr status` or `mr diff`.
Then deploy with `mr syncup`

## Features

### Logs

You can monitor the log messages from your solution with the `mr logs --follow`.
Or quickly get the last few with `mr logs`

MrMurano does a few things to make your log output easier to follow.
- Adds color to easily see where each log message starts.
- Reformats the timestamps to be in local time.
- Finds JSON blobs and pretty prints them.

All of these can be toggled with command line options.

### MR_CONFIGFILE environment and Dotenv

The environment variable `MR_CONFIGFILE` is checked for an additional config to
load.  This in conjuction with dotenv support, allows for easily switching between
development, staging, and production setups.

To use this, write the three solution ids into `.mrmurano.dev`, `.mrmurano.stg`,
and `.mrmurano.prod`. Then write the `.env` file to point at the system you're
currently working on.

The files for this are then:
```
cat > .mrmurano.dev <<EOF
[solution]
id=AAAAAAAA
EOF

cat > .mrmurano.stg <<EOF
[solution]
id=BBBBBBBB
EOF

cat > .mrmurano.prod <<EOF
[solution]
id=CCCCCCCC
EOF

cat > .env <<EOF
MR_CONFIGFILE=.mrmurano.dev
EOF
```

This also allows for keeping private things in a seperate config file and having
the shared things checked into source control.

### Direct Service Access

To aid with debugging, MrMurano has direct access to some of the services in a
solution.

Currently these are:
- Keystore: `mr keystore`
- Timeseries: `mr timeseries`
- TSDB: `mr tsdb`

### Output Format

Many sub-commands respect the `outformat` setting.  This lets you switch the output
between YAML, JSON, Ruby, CSV, and pretty tables.  Not all formats work with all
commands.

```
mr tsdb product list
mr tsdb product list -c outformat=csv
mr tsdb product list -c outformat=json
mr tsdb product list -c outformat=yaml
mr tsdb product list -c outformat=pp
```

### Product Content Area

MrMurano can manage the content area for a product.  This area is a place to store
files for use by devices.  Typically holding firmware images for Over-The-Air
updating.  Although any kind of fleet wide data that devices may need to download
can be stored here.

Once the `product.id` is set, the content for that product can be accessed with the
following commands:
```
> mr content list
> mr content upload
> mr content info
> mr content delete
> mr content download
```

Call them with `--help` for details.

### Sub-directories

For the endpoints, modules, and eventhandlers directories. The can contain both
files or a sub-directory of files.  This allows for keeping common things grouped
together.  Or adding a git submodule in to manage reusable chunks.

So, as an example, your project could be like:
```
endpoints
endpoints/get_-v1-data-averaged.lua
endpoints/get_-v1-data-cupsDrank.lua
endpoints/get_-v1-data-latest.lua
endpoints/statusboard-data.lua
endpoints/users
endpoints/users/get_-session.lua
endpoints/users/get_-v1-verify-code.lua
endpoints/users/patch_-v1-user.lua
endpoints/users/post_-session.lua
endpoints/users/post_-v1-pushtoken.lua
endpoints/users/put_-v1-user-email.lua
eventhandlers
eventhandlers/product.lua
eventhandlers/timer_timer.lua
files
files/batteryMeter.svg
files/index.html
files/meter.html
modules
modules/TSQ
modules/TSQ/func_field_quote_test.lua
modules/TSQ/isadate_test.lua
modules/TSQ/README.md
modules/TSQ/results_test.lua
modules/TSQ/select_fields_test.lua
modules/TSQ/tsq-1.2-2.rockspec
modules/TSQ/tsq.lua
modules/TSQ/tsq_test.lua
modules/TSQ/tsw.lua
modules/TSQ/tsw_test.lua
modules/users.lua
modules/util.lua
spec
spec/cico.murano.spec
```

## Developing

MrMurano uses [git flow](https://github.com/nvie/gitflow#getting-started) for
[managing branches](http://nvie.com/posts/a-successful-git-branching-model/).

MrMurano also uses [bundler](http://bundler.io).

When submitting pull requests, please do them against the develop branch.

