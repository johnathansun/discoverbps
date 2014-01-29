#DiscoverBPS
A website where you can easily find schools your children are eligible to attend based on your address. Visit [Discover BPS](http://www.discoverbps.org).

![Discover BPS Homepage](http://cl.ly/image/2t3O0R1T1e3Q/Image%202014-01-20%20at%2011.51.40%20PM.png)

![Discover BPS sample results](http://cl.ly/image/2T3A0Y0y0y1n/Image%202014-01-20%20at%2011.44.13%20PM.png)

## Stack Overview

* Ruby version 2.0.0
* Rails version 3.2.14
* PostgreSQL

## Installation
Please note that the instructions below have only been tested on OS X. If you are running another operating system and run into any issues, feel free to update this README, or open an issue if you are unable to resolve installation issues.

###Prerequisites

#### Git, Ruby 2.0.0+, Rails 3.2.14+ (+ Homebrew on OS X)
**OS X**: [Set up a dev environment on OS X with Homebrew, Git, RVM, Ruby, and Rails](http://www.moncefbelyamani.com/how-to-install-xcode-homebrew-git-rvm-ruby-on-mac/)

**Windows**: Try [RailsInstaller](http://railsinstaller.org), along with some of these [tutorials](https://www.google.com/search?q=install+rails+on+windows) if you get stuck.


#### PostgreSQL
**OS X**

On OS X, the easiest way to install PostgreSQL is with [Postgres.app](http://postgresapp.com/)

If that doesn't work, try this [tutorial](http://www.moncefbelyamani.com/how-to-install-postgresql-on-a-mac-with-homebrew-and-lunchy/).

**Other**

See the Downloads page on postgresql.org for steps to install on other systems: [http://www.postgresql.org/download/](http://www.postgresql.org/download/)


### Install the dependencies and prepare the DB:

    script/bootstrap

If you get a `permission denied` message, set the correct permissions:

    chmod -R 755 script

then run `script/bootstrap`.

Here's what the script will do:

1. Run `bundle install`
2. Create the local DB and load the schema
3. Import schools from the API into the DB
4. Update each school's attributes from the API

This will take several minutes to run.

### Run the app
Start the app locally on port 8080 using Unicorn:

    unicorn

### See a sample result set
1. On the home page, enter "123" for "Street Number", "Main St" for "Street Name", "02115" for "ZIP", and "3" for Grade.
2. Press "Next"
3. Press "Next" when the confirmation popup appears
4. Press "Next" again

You should see something like the results screenshot at the top of this README.