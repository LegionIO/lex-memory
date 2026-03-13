# frozen_string_literal: true

RSpec.describe Legion::Extensions::Memory::Helpers::Store do
  let(:store) { described_class.new }
  let(:trace_helper) { Legion::Extensions::Memory::Helpers::Trace }

  let(:semantic_trace) { trace_helper.new_trace(type: :semantic, content_payload: { fact: 'ruby is great' }, domain_tags: ['programming']) }
  let(:episodic_trace) { trace_helper.new_trace(type: :episodic, content_payload: { event: 'meeting' }, domain_tags: ['work']) }
  let(:firmware_trace) { trace_helper.new_trace(type: :firmware, content_payload: { directive_text: 'protect' }) }

  describe '#store and #get' do
    it 'stores and retrieves a trace' do
      store.store(semantic_trace)
      result = store.get(semantic_trace[:trace_id])
      expect(result[:trace_type]).to eq(:semantic)
    end

    it 'returns nil for unknown trace_id' do
      expect(store.get('nonexistent')).to be_nil
    end
  end

  describe '#delete' do
    it 'removes a trace' do
      store.store(semantic_trace)
      store.delete(semantic_trace[:trace_id])
      expect(store.get(semantic_trace[:trace_id])).to be_nil
    end
  end

  describe '#retrieve_by_type' do
    it 'returns traces of specified type' do
      store.store(semantic_trace)
      store.store(episodic_trace)

      results = store.retrieve_by_type(:semantic)
      expect(results.size).to eq(1)
      expect(results.first[:trace_type]).to eq(:semantic)
    end

    it 'filters by min_strength' do
      weak_trace = trace_helper.new_trace(type: :semantic, content_payload: {})
      weak_trace[:strength] = 0.1
      store.store(weak_trace)
      store.store(semantic_trace)

      results = store.retrieve_by_type(:semantic, min_strength: 0.4)
      expect(results.size).to eq(1)
    end

    it 'respects limit' do
      3.times { store.store(trace_helper.new_trace(type: :semantic, content_payload: {})) }
      results = store.retrieve_by_type(:semantic, limit: 2)
      expect(results.size).to eq(2)
    end
  end

  describe '#retrieve_by_domain' do
    it 'returns traces matching domain tag' do
      store.store(semantic_trace)
      store.store(episodic_trace)

      results = store.retrieve_by_domain('programming')
      expect(results.size).to eq(1)
    end
  end

  describe '#record_coactivation and #retrieve_associated' do
    it 'links traces after reaching coactivation threshold' do
      store.store(semantic_trace)
      store.store(episodic_trace)

      threshold = Legion::Extensions::Memory::Helpers::Trace::COACTIVATION_THRESHOLD
      threshold.times { store.record_coactivation(semantic_trace[:trace_id], episodic_trace[:trace_id]) }

      associated = store.retrieve_associated(semantic_trace[:trace_id])
      expect(associated.size).to eq(1)
      expect(associated.first[:trace_id]).to eq(episodic_trace[:trace_id])
    end

    it 'does not link before threshold' do
      store.store(semantic_trace)
      store.store(episodic_trace)

      store.record_coactivation(semantic_trace[:trace_id], episodic_trace[:trace_id])

      associated = store.retrieve_associated(semantic_trace[:trace_id])
      expect(associated.size).to eq(0)
    end
  end

  describe '#all_traces' do
    it 'returns all stored traces' do
      store.store(semantic_trace)
      store.store(episodic_trace)
      expect(store.all_traces.size).to eq(2)
    end

    it 'filters by min_strength' do
      weak = trace_helper.new_trace(type: :semantic, content_payload: {})
      weak[:strength] = 0.01
      store.store(weak)
      store.store(semantic_trace)

      expect(store.all_traces(min_strength: 0.1).size).to eq(1)
    end
  end

  describe '#count' do
    it 'returns number of stored traces' do
      expect(store.count).to eq(0)
      store.store(semantic_trace)
      expect(store.count).to eq(1)
    end
  end

  describe '#firmware_traces' do
    it 'returns only firmware traces' do
      store.store(firmware_trace)
      store.store(semantic_trace)

      results = store.firmware_traces
      expect(results.size).to eq(1)
      expect(results.first[:trace_type]).to eq(:firmware)
    end
  end
end
