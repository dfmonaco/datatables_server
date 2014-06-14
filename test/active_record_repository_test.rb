require 'minitest/autorun'
require 'sqlite3'
require 'active_record'
require 'database_cleaner'
require 'datatables_server'

unless File.exists? 'test.db'
  SQLite3::Database.new "test.db"

  ActiveRecord::Base.establish_connection(adapter: :sqlite3, database: "test.db")

  ActiveRecord::Schema.define do
    create_table :contacts do |t|
      t.column :name, :string
      t.column :age, :integer
    end

    create_table :addresses do |t|
      t.column :street, :string
      t.column :contact_id, :integer
    end
  end
end

ActiveRecord::Base.establish_connection(adapter: :sqlite3, database: "test.db")

class Contact < ActiveRecord::Base
  has_one :address
end

class Address < ActiveRecord::Base
  belongs_to :contact
end

module DatatablesServer
  describe ActiveRecordRepository do
    before do
      DatabaseCleaner.start
    end

    after do
      DatabaseCleaner.clean
    end

    describe '#count_all' do
      it 'counts all the records from the relation' do
        3.times { Contact.create }
        data = Contact.all
        columns = []
        options = OpenStruct.new

        repository = ActiveRecordRepository.new(data, columns, options) 

        assert_equal 3, repository.count_all
      end
    end

    describe '#count_filtered' do
      it 'counts the filtered records from the relation' do
        3.times {|n| Contact.create(name: "name_#{n}", age: n)}
        data = Contact.all
        columns = %w(contacts.name contacts.age)
        options = OpenStruct.new(search_term: '2')

        repository = ActiveRecordRepository.new(data, columns, options) 

        assert_equal 1, repository.count_filtered
      end

      it 'counts all the records if search term is blank' do
        3.times {|n| Contact.create(name: "name_#{n}", age: n)}
        data = Contact.all
        columns = %w(contacts.name contacts.age)
        options = OpenStruct.new(search_term: '')

        repository = ActiveRecordRepository.new(data, columns, options) 

        assert_equal 3, repository.count_filtered
      end
    end

    describe '#paginated_data' do
      it 'returns the data paginated' do
        10.times {|n| Contact.create(name: "name_#{n}", age: n)}
        data = Contact.all
        columns = %w(contacts.name contacts.age)
        options = OpenStruct.new.tap do |o|
          o.page_start = 4
          o.page_size = 2
          o.sort_column = 'contacts.name'
          o.sort_direction = 'ASC'
          o.search_term = ''
        end
        repository = ActiveRecordRepository.new(data, columns, options)

        paginated_data = repository.paginated_data

        assert_equal ['name_4', 'name_5'], paginated_data.map(&:name)
      end

      it 'returns the data in the right order' do
        Contact.create(age: 32)
        Contact.create(age: 48)
        Contact.create(age: 5)
        data = Contact.all
        columns = %w(contacts.name contacts.age)
        options = OpenStruct.new.tap do |o|
          o.page_start = 0
          o.page_size = 3
          o.sort_column = 'contacts.age'
          o.sort_direction = 'DESC'
          o.search_term = ''
        end
        repository = ActiveRecordRepository.new(data, columns, options)

        paginated_data = repository.paginated_data

        assert_equal [48, 32, 5], paginated_data.map(&:age)
      end

      it 'returns the data filtered' do
        Contact.create(age: 32, name: 'foo')
        Contact.create(age: 48, name: 'bar')
        Contact.create(age: 5, name: 'foo')
        data = Contact.all
        columns = %w(contacts.name contacts.age)
        options = OpenStruct.new.tap do |o|
          o.page_start = 0
          o.page_size = 3
          o.sort_column = 'contacts.age'
          o.sort_direction = 'ASC'
          o.search_term = 'fo'
        end
        repository = ActiveRecordRepository.new(data, columns, options)

        paginated_data = repository.paginated_data

        assert_equal [5, 32], paginated_data.map(&:age)
      end

      it 'works with joins' do
        c1 = Contact.create(name: 'bar', age: 32)
        c2 = Contact.create(name: 'foo', age: 23)
        c3 = Contact.create(name: 'bar', age: 78)
        Address.create(street: 'street 1', contact: c1)
        Address.create(street: 'street 2', contact: c2)
        Address.create(street: 'street 3', contact: c3)
        data = Contact.select('contacts.name', 'addresses.street').joins(:address)
        columns = %w(contacts.name addresses.street)
        options = OpenStruct.new.tap do |o|
          o.page_start = 0
          o.page_size = 3
          o.sort_column = 'addresses.street'
          o.sort_direction = 'DESC'
          o.search_term = 'ar'
        end
        repository = ActiveRecordRepository.new(data, columns, options)

        expected_data = [['bar', 'street 3'], ['bar', 'street 1']]
        actual_data = repository.paginated_data.map {|d| [d.name, d.street]}

        assert_equal expected_data, actual_data
      end
    end
  end
end


