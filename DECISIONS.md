#### Decisions Log:

My logs about decisions I took for the challenges faced, and its documentation. It goes along these lines, what happened, what was
decided, any alternative, why I chose this one, tradeoffs accepted. Written at that moment, not from memory!

----

## Sep-28, 26 - Separate bootstrap project for Terraform State

**Decision:** Created a standalone Terraform config ('infra'/'bootstrap') whose only job is provisioning the storage_account + container that will hold 
the *main* project's remote state-kept entirely separate from the actual project.

**Alternative Considered**: There is a happy alternative way to create the resources required via portal GUI, and then use 'Terraform' for the actual project resources.

**Why I chose, this?**: 
**Why this won:** A dedicated bootstrap layer is a pre-req for managing
infrastructure safely, not part of the actual application deployment —
it creates the meta-infra required for that. This ensures the main
project can use a remote state backend from its first commit, instead
of falling back to local state (which was already ruled out separately —
see the Terraform vs Bicep entry). Keeps responsibilities separate:
state-management infra and workload infra are different concerns, and
mixing them into one Terraform project risks a `terraform destroy` on
the real pipeline also nuking the thing tracking what was built.



**Tradeoff accepted**: This bootstrap project's own state stays local (not remote) - a deliberate exception, acceptable because it
is small (3 resources), low-change, low-risk! It solves the state needs somewhere to live before it can manage itself, problem. Doing it right off from the bat, makes it easy, and helps maintain the actal project's state properly.


## 2026-09-28 — HNS enabled on main storage account

**Decision:** `is_hns_enabled = true` on `sabikesharefleetproject` (main_infra),
left `false` (default) on `sabikeshareprj` (bootstrap's state-only storage account).

**Alternative considered:** Leave HNS off everywhere, treat paths like
`bronze/2024/01/trips.csv` as flat blob-name prefixes.

**Why this won:** HNS enables a real hierarchical namespace — actual folder
objects with atomic rename/move and folder-level ACLs — rather than paths
that are just string prefixes baked into a flat blob name. This is what
ADLS Gen2 actually means, and it's what ADF/Synapse/Databricks expect for
partition-style medallion layouts (bronze/silver/gold). Bootstrap's storage
account only holds a single tfstate blob, so it never needed this.

**Tradeoff accepted:** None significant — HNS has no real downside for this
use case; it's simply the correct setting for a data lake account.

---

## 2026-09-28 — Three separate containers (bronze/silver/gold) vs. one container with folder prefixes

**Decision:** Three separate containers: `bronze`, `silver`, `gold`.

**Alternative considered:** One container (e.g. `data`) with `bronze/`,
`silver/`, `gold/` as folder prefixes inside it.

**Why this won:** Separate containers keep each medallion layer cleanly
isolated — avoids the layers becoming "clumsy folders" mixed together in
one namespace, and keeps future concerns (different RBAC per layer,
different lifecycle/retention policies, easier versioning of what
changed where) simpler to reason about and apply independently.

**Tradeoff accepted:** Slightly more Terraform boilerplate (three resource
blocks instead of one), and cross-layer operations (e.g. "list everything
across all layers") require touching three containers instead of one
prefix scan.

---

## 2026-09-28 — Key Vault: purge_protection_enabled = false

**Decision:** `purge_protection_enabled = false` on the dev Key Vault.

**Alternative considered:** `true` (production-recommended default).

**Why this won:** This is a small-scale dev/portfolio project where the
vault may need to be destroyed and recreated under the same name during
iteration. Purge protection would block that by keeping a "deleted" vault
name reserved and unrecoverable-but-blocking for a mandatory retention
window.

**Tradeoff accepted:** No safety net against accidental permanent deletion
of secrets. Explicitly not the right setting for production — purge
protection exists specifically to prevent unrecoverable data loss, and a
real production vault should have it enabled. Noting this now so the
tradeoff is defensible if asked in an interview.