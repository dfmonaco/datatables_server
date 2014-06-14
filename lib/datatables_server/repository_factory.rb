require 'datatables_server/active_record_repository'

module DatatablesServer
  class RepositoryFactory
    def self.create(data, columns, options)
      case
      when defined?(ActiveRecord::Relation) && data.is_a?(ActiveRecord::Relation)
        ActiveRecordRepository.new(data, columns, options)
      when defined?(Sequel::Model) && data.is_a?(Sequel::Model)
        raise RepositoryNotImplementedError
      else
        raise RepositoryNotImplementedError
      end
    end
  end
end
