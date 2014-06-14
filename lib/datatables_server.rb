require "datatables_server/version"
require 'datatables_server/custom_errors'
require 'datatables_server/repository_factory'

module DatatablesServer
  class Base
    def initialize(params)
      @params = params
    end

    def as_json(options = {})
      {
        sEcho: s_echo,
        iTotalRecords: total_records_count,
        iTotalDisplayRecords: filtered_records_count,
        aaData: aa_data
      }
    end

    def data
      raise MethodNotImplementedError
    end

    def columns
      raise MethodNotImplementedError
    end

    private

    attr_reader :params

    def s_echo
      params[:sEcho].to_i
    end

    def total_records_count
      repository.count_all
    end

    def filtered_records_count
      repository.count_filtered
    end

    def aa_data
      repository.paginated_data.map do |datum|
        attributes.inject([]) do |array, column|
          raw_value = datum.public_send(column)
          if respond_to?(column)
            array << public_send(column, raw_value)
          else
            array << raw_value
          end
        end
      end
    end

    def attributes
      @attributes ||= columns.map do |column|
        column.split('.').last
      end
    end

    def options
      OpenStruct.new.tap do |o|
        o.page_start = params[:iDisplayStart]
        o.page_size = params[:iDisplayLength]
        o.sort_column = columns[params[:iSortCol_0].to_i]
        o.sort_direction = params[:sSortDir_0]
        o.search_term = params[:sSearch]
      end
    end

    def repository
      @repository ||= RepositoryFactory.create(data, columns, options)
    end

  end
end
