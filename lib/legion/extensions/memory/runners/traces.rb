# frozen_string_literal: true

module Legion
  module Extensions
    module Memory
      module Runners
        module Traces
          def store_trace(type:, content_payload:, store: nil, **)
            store ||= default_store
            trace = Helpers::Trace.new_trace(type: type.to_sym, content_payload: content_payload, **)
            store.store(trace)
            Legion::Logging.debug "[memory] stored trace #{trace[:trace_id][0..7]} type=#{trace[:trace_type]} strength=#{trace[:strength].round(2)}"
            { trace_id: trace[:trace_id], trace_type: trace[:trace_type], strength: trace[:strength] }
          end

          def get_trace(trace_id:, store: nil, **)
            store ||= default_store
            trace = store.get(trace_id)
            Legion::Logging.debug "[memory] get trace #{trace_id[0..7]} found=#{!trace.nil?}"
            return { found: false } unless trace

            { found: true, trace: trace }
          end

          def retrieve_by_type(type:, store: nil, min_strength: 0.0, limit: 100, **)
            store ||= default_store
            traces = store.retrieve_by_type(type.to_sym, min_strength: min_strength, limit: limit)
            Legion::Logging.debug "[memory] retrieve_by_type=#{type} count=#{traces.size} min_strength=#{min_strength}"
            { count: traces.size, traces: traces }
          end

          def retrieve_by_domain(domain_tag:, store: nil, min_strength: 0.0, limit: 100, **)
            store ||= default_store
            traces = store.retrieve_by_domain(domain_tag, min_strength: min_strength, limit: limit)
            Legion::Logging.debug "[memory] retrieve_by_domain=#{domain_tag} count=#{traces.size}"
            { count: traces.size, traces: traces }
          end

          def retrieve_associated(trace_id:, store: nil, min_strength: 0.0, limit: 20, **)
            store ||= default_store
            traces = store.retrieve_associated(trace_id, min_strength: min_strength, limit: limit)
            Legion::Logging.debug "[memory] retrieve_associated for #{trace_id[0..7]} count=#{traces.size}"
            { count: traces.size, traces: traces }
          end

          def retrieve_ranked(trace_ids: [], store: nil, query_time: nil, **)
            store ||= default_store
            query_time ||= Time.now.utc
            associated_set = Set.new

            traces = trace_ids.filter_map { |id| store.get(id) }
            traces.each { |t| associated_set.merge(t[:associated_traces]) }

            scored = traces.map do |t|
              score = Helpers::Decay.compute_retrieval_score(
                trace: t, query_time: query_time, associated: associated_set.include?(t[:trace_id])
              )
              { trace: t, score: score }
            end

            result = scored.sort_by { |s| -s[:score] }
            Legion::Logging.debug "[memory] retrieve_ranked ids=#{trace_ids.size} scored=#{result.size}"
            result
          end

          def delete_trace(trace_id:, store: nil, **)
            store ||= default_store
            store.delete(trace_id)
            Legion::Logging.debug "[memory] deleted trace #{trace_id[0..7]}"
            { deleted: true, trace_id: trace_id }
          end

          private

          def default_store
            @default_store ||= Helpers::Store.new
          end

          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)
        end
      end
    end
  end
end
