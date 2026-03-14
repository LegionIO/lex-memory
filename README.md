# lex-memory

Memory trace system for brain-modeled agentic AI. Implements trace storage, power-law decay, reinforcement, Hebbian association, and tiered retrieval.

## Overview

`lex-memory` models the agent's long-term memory as a collection of typed traces. Traces decay over time according to a power-law formula, are strengthened by reinforcement, and form associative links through co-activation (Hebbian learning). Storage tiers (hot/warm/cold) reflect recency of access.

## Trace Types

| Type | Starting Strength | Base Decay Rate | Notes |
|------|------------------|----------------|-------|
| `firmware` | 1.0 | 0.0 | Never decays — hardcoded values |
| `identity` | 1.0 | 0.001 | Self-model |
| `procedural` | 0.4 | 0.005 | How-to knowledge |
| `trust` | 0.3 | 0.008 | Agent trust records |
| `semantic` | 0.5 | 0.010 | Conceptual knowledge |
| `episodic` | 0.6 | 0.020 | Event memories |
| `sensory` | 0.4 | 0.100 | Transient perceptual data |

## Storage Tiers

| Tier | Condition |
|------|-----------|
| `hot` | Last accessed within 24 hours |
| `warm` | Last accessed within 90 days |
| `cold` | Older than 90 days |
| `erased` | Strength <= 0.01 (pruned) |

## Installation

Add to your Gemfile:

```ruby
gem 'lex-memory'
```

## Usage

### Storing Traces

```ruby
require 'legion/extensions/memory'

# Store a new trace
result = Legion::Extensions::Memory::Runners::Traces.store_trace(
  type: :episodic,
  content_payload: { event: "first conversation", summary: "..." },
  emotional_intensity: 0.7,
  domain_tags: [:conversation]
)
# => { trace_id: "uuid", trace_type: :episodic, strength: 0.6 }
```

### Retrieving Traces

```ruby
# By type
Legion::Extensions::Memory::Runners::Traces.retrieve_by_type(type: :semantic, min_strength: 0.3)

# By domain tag
Legion::Extensions::Memory::Runners::Traces.retrieve_by_domain(domain_tag: :conversation)

# Associated traces (Hebbian links)
Legion::Extensions::Memory::Runners::Traces.retrieve_associated(trace_id: "uuid")

# Ranked retrieval (composite score: strength * recency * emotion * association)
Legion::Extensions::Memory::Runners::Traces.retrieve_ranked(trace_ids: ["uuid1", "uuid2"])
```

### Memory Consolidation

```ruby
# Reinforce a trace (strengthens it; 3x multiplier during imprint window)
Legion::Extensions::Memory::Runners::Consolidation.reinforce(
  trace_id: "uuid",
  imprint_active: false
)

# Run decay cycle (called each tick)
Legion::Extensions::Memory::Runners::Consolidation.decay_cycle(tick_count: 1)

# Migrate traces to appropriate storage tiers
Legion::Extensions::Memory::Runners::Consolidation.migrate_tier

# Form Hebbian link between co-activated traces
Legion::Extensions::Memory::Runners::Consolidation.hebbian_link(
  trace_id_a: "uuid1",
  trace_id_b: "uuid2"
)

# Selective erasure (for lex-privatecore integration)
Legion::Extensions::Memory::Runners::Consolidation.erase_by_type(type: :sensory)
Legion::Extensions::Memory::Runners::Consolidation.erase_by_agent(partition_id: "agent-123")
```

## Decay Formula

```
new_strength = peak_strength * (ticks_since_access + 1)^(-base_decay_rate / (1 + emotional_intensity * 0.3))
```

High emotional intensity slows decay. Firmware traces have `base_decay_rate = 0.0` and never decay.

## Reinforcement Formula

```
new_strength = min(1.0, current_strength + 0.10 * imprint_multiplier)
```

During the imprint window (first 7 days), the multiplier is 3.0.

## Hebbian Association

Traces that co-activate 3 or more times form a permanent associative link. Each trace stores up to 20 links. Linked traces receive a 15% bonus in retrieval scoring.

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
