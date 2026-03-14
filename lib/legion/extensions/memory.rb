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
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
