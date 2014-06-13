require 'minitest/autorun'
require 'active_record'
require 'datatables_server'

class Project < ActiveRecord::Base
  def self.create_column(name, default = nil, type = 'string')
    ActiveRecord::ConnectionAdapters::Column.new(name, default, type)
  end

  def self.columns
    [create_column('name'),
      create_column('project_manager'),
      create_column('id'),
      create_column('created_at'),
      create_column('updated_at'),
      create_column('company_id')]
  end

  belongs_to :company

  def persisted?
    true
  end
end

class Company < ActiveRecord::Base
  def self.create_column(name, default = nil, type = 'string')
    ActiveRecord::ConnectionAdapters::Column.new(name, default, type)
  end

  def self.columns
    [create_column('name'),
      create_column('id'),
      create_column('created_at'),
      create_column('updated_at')]
  end

  def persisted?
    true
  end
end

describe DatatablesServer do
  before do
    class Foo < DatatablesServer::Base
    end

    @foo = Foo.new({})
  end

  it 'responds to #as_json' do
    assert @foo.respond_to? :as_json
  end

  it 'raises an exception if #data is not implemented' do
    assert_raises(DatatablesServer::MethodNotImplementedError) do
      @foo.data
    end
  end

  it 'raises an exception if #columns is not implemented' do
    assert_raises(DatatablesServer::MethodNotImplementedError) do
      @foo.columns
    end
  end
end
