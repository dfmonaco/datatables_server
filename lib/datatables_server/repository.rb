require 'datatables_server/active_record_repository'

module DatatablesServer
  class Repository
    def self.create(data, columns, options)
      case data
      when ActiveRecord::Relation
        ActiveRecordRepository.new(data, columns, options)
      when Sequel::Model
        SequelRepository.new(data, columns, options)
      end
    end
  end
end
