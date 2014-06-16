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
### Basic usage
To use DatatablesServer you just need to inherit from `DatatablesServer::Base` and implement two methods: `#data`, wich must return
an `ActiveRecord::Relation` and `#columns` wich must return the columns used in the client table in the right order and represented
as an array of strings in the form `'table_name.column_name'`.

```ruby
# product.rb

class Product < ActiveRecord::Base
end
```

```ruby
#product_datatables

class ProductDatatables < DatatablesServer::Base

  def data
    Product.all
  end

  def columns
    %w(products.name products.price products.description)
  end
end
```
And that's it!, DatatablesServer will handle paging, sorting and filtering by returning the right JSON document to the client.

### Processing raw data
If you want to process the raw data that's comming from the datatabase you can implement a method with the same name as the column
and do whatever you want with the data.

```ruby
class ProductDatatables < DatatablesServer::Base
   ....

   def name(raw_name)
    raw_name.capitalize
   end

   def price(raw_price)
    "$ #{raw_price}"
   end
end
```
##

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
