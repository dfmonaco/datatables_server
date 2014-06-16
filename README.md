# DatatablesServer

[![Build Status](https://travis-ci.org/dfmonaco/datatables_server.svg?branch=master)](https://travis-ci.org/dfmonaco/datatables_server)
[![Coverage Status](https://coveralls.io/repos/dfmonaco/datatables_server/badge.png)](https://coveralls.io/r/dfmonaco/datatables_server)

DatatablesServer will receive a number of variables from a DataTables client and
it will perform all the required processing (i.e. when paging, sorting, filtering etc),
and then return the data in the format required by DataTables.

## Installation

Add this line to your application's Gemfile:

    gem 'datatables_server'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install datatables_server

## Usage
To use DatatablesServer you just need to inherit from `DatatablesServer::Base` and implement two methods: `#data`, wich must return
an `ActiveRecord::Relation` and `#columns` wich must return the columns used in the client table in the right order and represented
as an array of strings in the form `'table_name.column_name'`.

```ruby
# person.rb

class Person < ActiveRecord::Base
end
```

```ruby
#person_datatables

class PersonDatatables < DatatablesServer::Base

  def data
    Person.all
  end

  def columns
    %w(persons.name persons.age persons.gender)
  end
end
```
And that's it!, DatatablesServer will handle paging, ordering and filtering by returning the right JSON document to the client.

## Compatibility

For any given version, check `.travis.yml` to see what Ruby versions are being tested for compatibility.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/datatables_server/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

__MIT License__. *Copyright 2013 Diego Mónaco*
