#WAQ's website

## Getting started

Requires [composer](http://getcomposer.org) dependency manager for PHP.

Install PHP 5.4+ for easy dev server. With brew :`brew install php54`

    $ composer install
    $ npm install -g coffee-script
    $ bundle install
    $ php -t web -S localhost:8000

Or point your favorite server index at `web/app.php`.

### Assets

To watch both sass and coffeescript files, just ```cd /path/to/my/project/``` and run the ```guard``` command.

You'll need [Guard](https://github.com/guard/guard) and [guard-shell](https://github.com/guard/guard-shell) : ```gem install guard```, ```gem install guard-shell```