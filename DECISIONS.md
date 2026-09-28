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
