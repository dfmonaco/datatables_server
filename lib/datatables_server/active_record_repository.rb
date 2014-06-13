module DatatablesServer
  class ActiveRecordRepository
    def initialize(data, columns, options)
      @data = data
      @columns = columns
      @options = options
    end

    def count_all
      data.count
    end

    def count_filtered
      filtered_data.count
    end

    def paginated_data
      ordered_data.limit(options.page_size).offset(options.page_start)
    end

    private

    attr_reader :data, :options, :columns

    def ordered_data
      filtered_data.order("#{options.sort_column} #{options.sort_direction}")
    end

    def filtered_data
      return data if options.search_term.empty?
      data.where(conditions, search: "%#{options.search_term}%")
    end

    def conditions
      columns.join(' LIKE :search OR ') << ' LIKE :search'
    end
  end
end
