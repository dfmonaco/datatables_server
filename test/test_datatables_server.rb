require 'minitest_helper'
require 'ostruct'

describe DatatablesServer::Base do
  describe 'raising MethodNotImplementedError' do
    before do
      class Foo < DatatablesServer::Base
      end

      @foo = Foo.new({})
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

  describe '#as_json' do
    before do
      class ContactsDatatatables < DatatablesServer::Base
        def data
        end

        def columns
          %w(contacts.name contacts.age)
        end

        def name(value)
          value.upcase
        end

        private
        # Mock repository, we don't need a mock framework, thanks Ruby!
        # repository is a collaborator so we can mock the expected interface
        def repository
          OpenStruct.new.tap do |r|
            r.count_all = 57
            r.count_filtered = 32
            r.paginated_data = [OpenStruct.new(name: 'foo', age: 21),
                                OpenStruct.new(name: 'bar', age: 12)]
          end
        end
      end
    end

    it 'returns a hash with the right keys and values' do
      params = { sEcho: '1' }
      dt_server = ContactsDatatatables.new(params)
      expected_hash = {
                        sEcho: 1,
                        iTotalRecords: 57,
                        iTotalDisplayRecords: 32,
                        aaData: [['FOO', 21], ['BAR', 12]]
                      }

      generated_hash = dt_server.as_json

      assert_equal expected_hash, generated_hash
    end
  end

  describe '#options' do
    it 'returns an object with the required options for the repository' do
      class TestDatatables < DatatablesServer::Base
        def columns
          %w(column_1 column_2)
        end
      end

      params = {
          iDisplayStart: '0',
          iDisplayLength: '4',
          iSortCol_0: '1',
          iSortDir_0: 'asc',
          sSearch: 'foo'
        }

      options = TestDatatables.new(params).options

      assert_equal 0, options.page_start
      assert_equal 4, options.page_size
      assert_equal 'column_2', options.sort_column
      assert_equal 'ASC', options.sort_direction
      assert_equal 'foo', options.search_term
    end
  end

end
