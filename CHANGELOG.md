# Changelog

## [0.2.0] - 2026-03-17

### Added
- `PersistentStore`: Sequel-backed durable memory storage per agent (write, read, touch, count, total_bytes, eviction)
- `Quota`: per-agent trace count and byte size limits with LRU/confidence eviction strategies
- `BatchDecay`: periodic DB-backed confidence reduction with configurable rate and min threshold

## [0.1.2] - 2026-03-16

### Fixed
- Add missing `require 'client'` to entry point — `Memory::Client` was never auto-loaded at runtime, causing dream cycle and other consumers to skip memory integration

## [0.1.1] - 2026-03-16

### Fixed
- Strip default procs from associations hash before Memcached serialization in `CacheStore#flush` to prevent `can't dump hash with default proc` marshalling error

### Added
- `spec/legion/extensions/memory/actors/decay_spec.rb` (7 examples) — tests for the Decay actor (Every 60s)
- `spec/legion/extensions/memory/actors/tier_migration_spec.rb` (7 examples) — tests for the TierMigration actor (Every 300s)

## [0.1.0] - 2026-03-13

### Added
- Initial release
