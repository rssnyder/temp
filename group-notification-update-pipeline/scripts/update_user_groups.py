"""Sets one notification channel on each listed Harness user group.

Runs inside the pipeline's Run step with harness-platform-sdk installed. Env vars:
  HARNESS_BASE_URL, HARNESS_API_KEY, ACCOUNT_ID, ORG_ID, PROJECT_ID,
  USER_GROUPS (comma-separated), NOTIFICATION_TYPE, NOTIFICATION_VALUE

Group scope is sensed per group:
  "account.<id>"  -> account-level group
  "org.<id>"      -> group in ORG_ID
  "<id>"          -> looked up in the project, then the org, then the account
                     (first hit wins)

Groups whose identifier starts with "_" are Harness built-ins (e.g.
_account_all_users) and are skipped, whatever scope prefix they carry.

The update API replaces the whole group, so the group is fetched and written
back with only the entry of NOTIFICATION_TYPE changed; other channel types
already on the group are kept. EMAIL is additive: the group's email list is
comma-separated, new addresses are appended, and addresses already present
(case-insensitive) are not added again. Every other type replaces its entry.
A group that already has the requested value is left untouched (no write).
Webhook URLs and keys are secrets and are never printed.

Output variables (markdown links to the groups in the Harness UI):
  UPDATED_GROUPS    groups that were modified
  UNCHANGED_GROUPS  groups that already had the requested value
"""
import os
import sys

from harness_platform_sdk import ApiError, HarnessClient
from pydantic import ValidationError
from harness_platform_sdk.models.ng_api.user_groups import UserGroupCreateRequest
from harness_platform_sdk.scope import Scope

BASE_URL = os.environ["HARNESS_BASE_URL"].rstrip("/")
ACCOUNT = os.environ["ACCOUNT_ID"]
ORG = os.environ["ORG_ID"]
PROJECT = os.environ["PROJECT_ID"]
NTYPE = os.environ["NOTIFICATION_TYPE"]
NVALUE = os.environ["NOTIFICATION_VALUE"]
GROUPS = [g.strip() for g in os.environ["USER_GROUPS"].split(",") if g.strip()]

# Config key that carries the target for each channel type.
VALUE_FIELD = {
    "EMAIL": "groupEmail",
    "SLACK": "slackWebhookUrl",
    "PAGERDUTY": "pagerDutyKey",
    "MSTEAMS": "microsoftTeamsWebhookUrl",
}

BUILT_IN_PREFIX = "_"

ACCOUNT_SCOPE = Scope(account_id=ACCOUNT)
ORG_SCOPE = Scope(account_id=ACCOUNT, org=ORG)
PROJECT_SCOPE = Scope(account_id=ACCOUNT, org=ORG, project=PROJECT)
SCOPE_LABEL = {ACCOUNT_SCOPE: "account", ORG_SCOPE: "org", PROJECT_SCOPE: "project"}

# No default_org/default_project: the SDK would merge them into account- and
# org-level calls and send the wrong scope.
client = HarnessClient(
    api_key=os.environ["HARNESS_API_KEY"],
    account_id=ACCOUNT,
    base_url=BASE_URL,
)


def group_url(scope, identifier):
    """Harness UI page of a user group. Kept in one place: UI routes differ by scope."""
    base = f"{BASE_URL}/ng/account/{ACCOUNT}"
    if scope.project:
        return f"{base}/all/orgs/{scope.org}/projects/{scope.project}/settings/access-control/user-groups/{identifier}"
    if scope.org:
        return f"{base}/all/orgs/{scope.org}/settings/access-control/user-groups/{identifier}"
    return f"{base}/all/settings/access-control/user-groups/{identifier}"


def markdown_link(scope, group):
    # Brackets in a group name would break the link text.
    name = (group.name or group.identifier).replace("[", "(").replace("]", ")")
    return f"[{name}]({group_url(scope, group.identifier)})"


def emit(name, values):
    """Publishes a Run-step output variable (single line; "none" when empty).

    For shell: Python, Harness appends code after this script that exports each
    declared output variable from os.environ. So the script must end normally on
    success: sys.exit(), even sys.exit(0), would skip that code and the variables
    would not exist.
    """
    os.environ[name] = ", ".join(values) or "none"


def candidates(ref):
    """Returns (identifier, [Scope, ...]) to try, in order."""
    if ref.startswith("account."):
        return ref[len("account."):], [ACCOUNT_SCOPE]
    if ref.startswith("org."):
        return ref[len("org."):], [ORG_SCOPE]
    return ref, [PROJECT_SCOPE, ORG_SCOPE, ACCOUNT_SCOPE]


def with_channel(group):
    """Builds the update request from the fetched group with the channel replaced."""
    # Rebuilt from the fetched group because the request model defaults
    # (e.g. users=[]) would otherwise overwrite the group's existing values.
    # None values are dropped because the SDK models type several fields as a
    # plain `str`/`list` with a None default, which rejects an explicit None.
    # The SDK's get() also leaves snake_case scope duplicates as extras; drop them.
    artifacts = {"account_identifier", "org_identifier", "project_identifier"}
    fields = {
        k: v
        for k, v in group.model_dump(by_alias=True).items()
        if v is not None and k not in artifacts
    }
    request = UserGroupCreateRequest(**fields)
    existing = request.notification_configs or []
    prior = next((c for c in existing if c.get("type") == NTYPE), {})
    field = VALUE_FIELD[NTYPE]

    if NTYPE == "EMAIL":
        # Additive: keep the current addresses and append the ones not yet present.
        current = [e.strip() for e in (prior.get(field) or "").split(",") if e.strip()]
        known = {e.lower() for e in current}
        added = []
        for email in (e.strip() for e in NVALUE.replace(";", ",").split(",")):
            if email and email.lower() not in known:
                known.add(email.lower())
                added.append(email)
        if not added:
            return request, False
        value = ",".join(current + added)
    else:
        if prior.get(field) == NVALUE:
            return request, False
        value = NVALUE

    entry = {"type": NTYPE, field: value}
    if NTYPE == "EMAIL":
        # Keep the group's existing "email all members" choice.
        entry["sendEmailToAllUsers"] = bool(prior.get("sendEmailToAllUsers", False))
    request.notification_configs = [c for c in existing if c.get("type") != NTYPE] + [entry]
    return request, True


def update(ref):
    """Returns (status, markdown link): status is "updated", "unchanged" or "skipped"."""
    identifier, scopes = candidates(ref)
    if identifier.startswith(BUILT_IN_PREFIX):
        print(f"SKIPPED built-in group '{ref}': built-in groups are not modified")
        return "skipped", None
    for scope in scopes:
        try:
            group = client.user_groups.get(identifier, scope=scope)
        except ApiError as e:
            if e.status_code in (400, 404):  # not at this scope; try the next one
                continue
            raise
        if not group:  # the SDK returns {} for an empty response
            continue
        link = markdown_link(scope, group)
        request, changed = with_channel(group)  # request validation errors surface here, before any write
        if not changed:
            print(f"UNCHANGED {SCOPE_LABEL[scope]} group '{identifier}': already has the requested {NTYPE} value")
            return "unchanged", link
        try:
            client.user_groups.update(identifier, request, scope=scope)
        except ValidationError:
            # The PUT succeeded (HTTP errors raise ApiError first); only the SDK's
            # parsing of the response body failed.
            print(f"WARNING: group '{identifier}' updated but the response could not be parsed")
        print(f"Updated {NTYPE} notification on {SCOPE_LABEL[scope]} group '{identifier}'")
        return "updated", link
    raise LookupError("not found at project, org or account scope")


def main():
    if NTYPE not in VALUE_FIELD:
        sys.exit(f"ERROR: unsupported notification type '{NTYPE}'")
    if not NVALUE:
        sys.exit("ERROR: notification value is empty")
    if not GROUPS:
        sys.exit("ERROR: no user groups given")

    failed = False
    links = {"updated": [], "unchanged": []}
    with client:
        for ref in GROUPS:
            try:
                status, link = update(ref)
                if link:
                    links[status].append(link)
            except Exception as e:  # keep going so one bad group doesn't block the rest
                # ApiError carries status/body only, never the API key.
                status = f" status={e.status_code}" if isinstance(e, ApiError) else ""
                print(f"FAILED group '{ref}': {type(e).__name__}{status}: {e}", file=sys.stderr)
                failed = True
    emit("UPDATED_GROUPS", links["updated"])
    emit("UNCHANGED_GROUPS", links["unchanged"])
    if not failed and not (links["updated"] or links["unchanged"]):
        # Every selected group was a skipped built-in; don't report a silent success.
        print("ERROR: no groups were updated", file=sys.stderr)
        failed = True
    if failed:
        sys.exit(1)  # only on failure: the step fails anyway, so no outputs are needed


main()
