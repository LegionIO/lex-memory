# lex-memory

**Level 3 Documentation**
- **Parent**: `extensions-agentic/CLAUDE.md`
- **Grandparent**: `/Users/miverso2/rubymine/legion/CLAUDE.md`

## Purpose

Memory trace system for the LegionIO cognitive architecture. Implements typed trace storage, power-law decay with emotional modulation, reinforcement (with imprint window boost), Hebbian association, tiered retrieval scoring, and selective erasure.

## Gem Info

- **Gem name**: `lex-memory`
- **Version**: `0.1.0`
- **Module**: `Legion::Extensions::Memory`
- **Ruby**: `>= 3.4`
- **License**: MIT

## File Structure

```
lib/legion/extensions/memory/
  version.rb
  helpers/
    trace.rb          # Trace structure, TRACE_TYPES, decay constants, new_trace factory
    decay.rb          # compute_decay, compute_reinforcement, compute_retrieval_score, compute_storage_tier
    store.rb          # In-memory Store class (hash-backed, not DB-persisted)
  runners/
    traces.rb         # store_trace, get_trace, retrieve_by_type/domain/associated/ranked, delete_trace
    consolidation.rb  # reinforce, decay_cycle, migrate_tier, hebbian_link, erase_by_type/agent
spec/
  legion/extensions/memory/
    helpers/
      trace_spec.rb
      decay_spec.rb
      store_spec.rb
    runners/
      traces_spec.rb
      consolidation_spec.rb
    client_spec.rb
  legion/extensions/memory_spec.rb
```

## Key Constants (Helpers::Trace)

```ruby
E_WEIGHT               = 0.3    # emotional intensity weight on decay
R_AMOUNT               = 0.10   # base reinforcement per call
IMPRINT_MULTIPLIER     = 3.0    # multiplier during imprint window
AUTO_FIRE_THRESHOLD    = 0.85   # procedural auto-fire threshold
PRUNE_THRESHOLD        = 0.01   # traces below this are deleted
HOT_TIER_WINDOW        = 86_400     # 24h
WARM_TIER_WINDOW       = 7_776_000  # 90 days
RETRIEVAL_RECENCY_HALF = 3600       # 1h half-life for recency scoring
ASSOCIATION_BONUS      = 0.15   # Hebbian association retrieval bonus
MAX_ASSOCIATIONS       = 20     # max Hebbian links per trace
COACTIVATION_THRESHOLD = 3      # co-activations before link forms
```

## Store (Development vs Production)

`Helpers::Store` is an in-memory hash-backed store. The comment in `store.rb` explicitly states: "Production deployments should use a PostgreSQL + Redis backed store." The Store API:
- `store(trace)` / `get(trace_id)` / `delete(trace_id)`
- `retrieve_by_type(type, min_strength:, limit:)`
- `retrieve_by_domain(domain_tag, min_strength:, limit:)`
- `retrieve_associated(trace_id, min_strength:, limit:)`
- `record_coactivation(id_a, id_b)` - increments counter, links when >= COACTIVATION_THRESHOLD
- `all_traces(min_strength:)` / `count` / `firmware_traces`

## Runners

### Traces
CRUD operations. All runners accept `store:` keyword to inject a custom store instance (used in specs). Default store is `@default_store ||= Helpers::Store.new`.

### Consolidation
Lifecycle operations:
- `decay_cycle` - iterates all traces, applies power-law decay, prunes below PRUNE_THRESHOLD
- `reinforce` - boosts trace strength (firmware traces are skipped)
- `migrate_tier` - reassigns storage_tier based on last_reinforced timestamp
- `hebbian_link` - records co-activation, defers actual linking to Store
- `erase_by_type` / `erase_by_agent` - bulk delete (used by lex-privatecore)

## Integration Points

- **lex-coldstart**: `imprint_active:` flag passed to `reinforce` for the 3x multiplier
- **lex-emotion**: `emotional_intensity` on traces slows decay (E_WEIGHT)
- **lex-privatecore**: calls `erase_by_type` / `erase_by_agent` for cryptographic erasure
- **lex-tick**: `memory_retrieval` and `memory_consolidation` phases call into this extension

## Development Notes

- `new_trace` validates trace type and origin; raises `ArgumentError` on invalid values
- `firmware` traces: `base_decay_rate = 0.0`, `compute_decay` short-circuits to return `peak_strength`
- Retrieval score formula: `strength * recency_factor * emotional_weight * association_bonus`
- `retrieve_ranked` re-scores by retrieval score, not stored strength
- The gemspec uses `git ls-files` (differs from other LEX gems using `Dir.glob`) — both approaches are fine
