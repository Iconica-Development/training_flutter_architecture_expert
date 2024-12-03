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
## Riverpod is a dependency provision framework

Providers can request other providers
- Riverpod creates resources when needed, using a seperate line of dependencies
- The ref is similar to the buildcontext, as in it is your accesspoint to further lookup other providers.

Widgets have access to the providerRef through a custom build method in HookConsumers. Your own widgets can extend consumers to have a reference

---
## Riverpod is a state management framework

Riverpod allows watching and listening to state, this means that your UI can get notified when state changes.

