ds-forkable
===

The `ForkableDatastoreService` provides a set of virtual storage spaces ("datastores") which can be **forked**. Forking a datastore creates an exact copy at the time of the fork. This is achieved with a copy-on-write virtualization strategy, which means that the cost is amortized over all storage slot updates. A consequence of this cost structure is that `fork` must somehow be managed: it can only be called by the branch's `owner`, the address which can also `set` the branch's entries.


TODO:

* build a forkable token service by making a datastore adapter factory to interact with [`ds-token`s](https://github.com/nexusdev/ds-token).
* structure submodules properly
