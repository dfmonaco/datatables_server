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

Datatables does NOT depend on Rails, it can be used perfectly with any framework, right now the only dependency it's ActiveRecord,
but it's very easy to implement an adapter for other ORMs.

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
And that's it!, DatatablesServer will handle paging, sorting and filtering by returning the right JSON document to the client,
you just have to instantiate it with the params sent by DataTables, and call the `#as_json` mehtod.

```ruby
ProductDatatables.new(params).as_json # => JSON document to be consumed by the client
```

### Processing raw data
If you want to process the raw data that's coming from the datatabase you can implement a method with the same name as the column
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

### Wroking with joins
To work with joins you don't have to do anything special, just define the required methods as before.

```ruby
#product_datatables

class ProductDatatables < DatatablesServer::Base

  # Product belongs_to :supplier
  def data
    Product.select('products.name', 'suppliers.email').joins(:supplier)
  end

  def columns
    %w(products.name suppliers.email)
  end
end
```
### Rails example
As I said DatatablesServer does not depend on Rails, this it's just an example of a possible implementation.

```ruby
# app/controllers/products_controller.rb

class ProductsController < ApplicationController
  def index
    respond_to do |format|
      format.html
      # you can pass the view_context if you want to use helper methods
      format.json {render json: ProductDatatables.new(view_context)}
    end
  end
end
```
```ruby
# app/datatables/product.rb

class ProductDatatables < DatatablesServer::Base

  attr_reader :h

  def initialize(view_context)
    super(view_context.params)
    @h = view_context
  end

  def data
    Product.in_stock
  end

  def columns
    %w(products.name products.price products.description)
  end

  def price(raw_price)
    h.number_to_currency(price)
  end
end
```

## Compatibility

For any given version, check `.travis.yml` to see what Ruby versions are being tested for compatibility.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/datatables_server/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

__MIT License__. *Copyright 2014 Diego Mónaco*
