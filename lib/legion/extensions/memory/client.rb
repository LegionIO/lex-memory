# frozen_string_literal: true

require 'legion/extensions/memory/helpers/trace'
require 'legion/extensions/memory/helpers/decay'
require 'legion/extensions/memory/helpers/store'
require 'legion/extensions/memory/runners/traces'
require 'legion/extensions/memory/runners/consolidation'

module Legion
  module Extensions
    module Memory
      class Client
        include Legion::Extensions::Memory::Runners::Traces
        include Legion::Extensions::Memory::Runners::Consolidation

        attr_reader :store

        def initialize(store: nil, **)
          @default_store = store || Helpers::Store.new
        end

        private

        attr_reader :default_store
      end
    end
  end
end
