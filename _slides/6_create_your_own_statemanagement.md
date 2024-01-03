# Create your own state management solution

---
## Requirements
- Handles futures
- Allows editing of state through functions or events
- The public state is read only / final
- Can depend on other state
- Has a "statebuilder" that rebuilds on state changes
- Does not create memory leaks
- Has it's own lifecycle
- Is lazy
- Bonus: Autodisposing
- Bonus: Refetch data when a new ui element needs the data.
- Bonus: Add transition listening