# Riverpod in Theory

> A Reactive Caching and Data-binding Framework

---
## Riverpod is a caching framework

Providers remember their state, until they are either:
- No longer being watched if marked with `autoDispose`
- Invalidated.

Invalidating of providers can be caused by the following situations:
- Another provider watched by this provider has a new state
- Something called `ref.invalidate(provider)` or `ref.invalidateSelf()`

---
## Riverpod is a dependency framework

---
## Riverpod is a state management framework

