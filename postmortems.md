### 2026-09-28 — Git Bash silently mangled an Azure resource ID, disguised as a permissions error

**What happened:** Ran `az ad sp create-for-rbac --scopes /subscriptions/<id>`
from Git Bash on Windows. Got `(MissingSubscription) The request did not
have a subscription or a valid tenant level resource provider.` Looked
like an RBAC/permissions problem — spent time re-checking role
assignments, account context, and login state before finding the real
cause.

**Root cause:** Git Bash (MINGW) automatically rewrites any command-line
argument starting with a single `/` into a Windows filesystem path,
assuming it's a local file reference. `--scopes /subscriptions/451eeb79-...`
was silently rewritten to `C:/Program Files/Git/subscriptions/451eeb79-...`
before Azure CLI ever received it — visible only by reading the very
first line of verbose output closely, not the error message itself.

**Fix:** Ran the identical command from PowerShell instead, where no
path translation occurs. (Alternative fix: escape with a double leading
slash `//subscriptions/...` to survive Git Bash's translation.)

**What this taught me:** An error message can be technically accurate
about the symptom ("no valid subscription") while being misleading about
the cause (it wasn't a permissions issue at all). When a command that
"should obviously work" fails with a confusing error, check whether the
shell itself silently altered the input before assuming the Azure-side
logic or permissions are wrong. Also: Git Bash and PowerShell are not
interchangeable for Azure CLI work involving resource ID arguments.
