# frozen_string_literal: true

module Legion
  module Extensions
    module Memory
      module Helpers
        # In-memory store for development and testing.
        # Production deployments should use a PostgreSQL + Redis backed store.
        class Store
          attr_reader :traces, :associations

          def initialize
            @traces = {}
            @associations = Hash.new { |h, k| h[k] = Hash.new(0) }
          end

          def store(trace)
            @traces[trace[:trace_id]] = trace
            trace[:trace_id]
          end

          def get(trace_id)
            @traces[trace_id]
          end

          def delete(trace_id)
            @traces.delete(trace_id)
            @associations.delete(trace_id)
            @associations.each_value { |links| links.delete(trace_id) }
          end

          def retrieve_by_type(type, min_strength: 0.0, limit: 100)
            @traces.values
                   .select { |t| t[:trace_type] == type && t[:strength] >= min_strength }
                   .sort_by { |t| -t[:strength] }
                   .first(limit)
          end

          def retrieve_by_domain(domain_tag, min_strength: 0.0, limit: 100)
            @traces.values
                   .select { |t| t[:domain_tags].include?(domain_tag) && t[:strength] >= min_strength }
                   .sort_by { |t| -t[:strength] }
                   .first(limit)
          end

          def retrieve_associated(trace_id, min_strength: 0.0, limit: 20)
            trace = @traces[trace_id]
            return [] unless trace

            trace[:associated_traces]
              .filter_map { |id| @traces[id] }
              .select { |t| t[:strength] >= min_strength }
              .sort_by { |t| -t[:strength] }
              .first(limit)
          end

          def record_coactivation(trace_id_a, trace_id_b)
            return if trace_id_a == trace_id_b

            @associations[trace_id_a][trace_id_b] += 1
            @associations[trace_id_b][trace_id_a] += 1

            threshold = Helpers::Trace::COACTIVATION_THRESHOLD

            return unless @associations[trace_id_a][trace_id_b] >= threshold

            link_traces(trace_id_a, trace_id_b)
          end

          def all_traces(min_strength: 0.0)
            @traces.values.select { |t| t[:strength] >= min_strength }
          end

          def count
            @traces.size
          end

          def firmware_traces
            retrieve_by_type(:firmware)
          end

          private

          def link_traces(id_a, id_b)
            trace_a = @traces[id_a]
            trace_b = @traces[id_b]
            return unless trace_a && trace_b

            max = Helpers::Trace::MAX_ASSOCIATIONS
            trace_a[:associated_traces] << id_b unless trace_a[:associated_traces].include?(id_b) || trace_a[:associated_traces].size >= max
            return if trace_b[:associated_traces].include?(id_a) || trace_b[:associated_traces].size >= max

            trace_b[:associated_traces] << id_a
          end
        end
      end
    end
  end
end
