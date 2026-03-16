# frozen_string_literal: true

require 'legion/extensions/memory/version'
require 'legion/extensions/memory/helpers/trace'
require 'legion/extensions/memory/helpers/decay'
require 'legion/extensions/memory/helpers/store'
require 'legion/extensions/memory/helpers/cache_store'
require 'legion/extensions/memory/helpers/error_tracer'
require 'legion/extensions/memory/runners/traces'
require 'legion/extensions/memory/runners/consolidation'

module Legion
  module Extensions
    module Memory
      class << self
        # Process-wide shared store. All memory runners delegate here so that
        # traces written by one component (ErrorTracer, coldstart, tick) are
        # visible to every other component (dream cycle, cortex, predictions).
        # CacheStore adds cross-process sharing via memcached on top of this.
        def shared_store
          @shared_store ||= create_store
        end

        def reset_store!
          @shared_store = nil
        end

        private

        def create_store
          if defined?(Legion::Cache) && Legion::Cache.respond_to?(:connected?) && Legion::Cache.connected?
            Legion::Logging.debug '[memory] Using shared CacheStore (memcached)'
            Helpers::CacheStore.new
          else
            Legion::Logging.debug '[memory] Using shared in-memory Store'
            Helpers::Store.new
          end
        end
      end

      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
