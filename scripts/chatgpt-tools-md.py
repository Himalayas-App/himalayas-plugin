#!/usr/bin/env python3
"""Write chatgpt/skills/himalayas-basics/references/tools.md from a live tools/list.

Usage:
  scripts/chatgpt-tools-md.py            # read https://mcp.himalayas.app/mcp/chatgpt
  scripts/chatgpt-tools-md.py --derive   # read /mcp and drop the tools /mcp/chatgpt leaves out

Set HIMALAYAS_MCP_TOKEN to send a bearer token, if the route needs one.
"""

import json
import os
import pathlib
import sys
import urllib.request

CHATGPT_URL = "https://mcp.himalayas.app/mcp/chatgpt"
CANONICAL_URL = "https://mcp.himalayas.app/mcp"

# Tools and parameters that exist on /mcp but not on /mcp/chatgpt.
EXCLUDED_TOOLS = {
    "get_plus_checkout_link",
    "get_billing_portal_link",
    "purchase_job_extras",
    "post_job_public",
    "check_job_payment_status",
    "get_verification_link",
    "join_radar_waitlist",
}
EXCLUDED_PARAMS = {"create_company_job": {"extras"}}

OUT = (
    pathlib.Path(__file__).resolve().parent.parent
    / "chatgpt/skills/himalayas-basics/references/tools.md"
)

HEADER = f"""# Himalayas tools

Every tool on the hosted Himalayas MCP (`{CHATGPT_URL}`), with its parameters. Allowed values are listed in parentheses. "Read-only" tools never change anything. For every other tool, confirm with the user before calling it.

Job, company and salary tools work without signing in. Every other tool uses the Himalayas account the user connected through OAuth; employer tools need an employer account.
"""


def fetch(url):
    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json, text/event-stream",
        "User-Agent": "himalayas-plugin-tools-md",
    }
    token = os.environ.get("HIMALAYAS_MCP_TOKEN")
    if token:
        headers["Authorization"] = f"Bearer {token}"
    body = json.dumps({"jsonrpc": "2.0", "id": 1, "method": "tools/list"}).encode()
    req = urllib.request.Request(url, data=body, headers=headers, method="POST")
    with urllib.request.urlopen(req, timeout=30) as resp:
        text = resp.read().decode()
    for line in text.splitlines():
        if line.startswith("data: "):
            text = line[len("data: "):]
            break
    return json.loads(text)["result"]["tools"]


def param_type(schema):
    if "enum" in schema:
        return "(" + "|".join(str(v) for v in schema["enum"]) + ")"
    return schema.get("type", "")


def effect(tool):
    hints = tool.get("annotations") or {}
    if hints.get("readOnlyHint"):
        return "Read-only."
    if hints.get("destructiveHint"):
        return "Changes, removes or sends; always confirm."
    return "Adds data; confirm first."


def render(tools):
    parts = [HEADER]
    for tool in tools:
        props = (tool.get("inputSchema") or {}).get("properties") or {}
        params = ", ".join(
            f"`{name}` {param_type(schema)}".rstrip() for name, schema in props.items()
        ) or "none"
        title = tool.get("title") or (tool.get("annotations") or {}).get("title") or tool["name"]
        parts.append(f"### `{tool['name']}`: {title}\n{effect(tool)} Params: {params}\n")
    return "\n".join(parts)


def main():
    derive = "--derive" in sys.argv[1:]
    tools = fetch(CANONICAL_URL if derive else CHATGPT_URL)
    if derive:
        tools = [t for t in tools if t["name"] not in EXCLUDED_TOOLS]
        for t in tools:
            for param in EXCLUDED_PARAMS.get(t["name"], ()):
                (t.get("inputSchema") or {}).get("properties", {}).pop(param, None)
    leaked = EXCLUDED_TOOLS & {t["name"] for t in tools}
    if leaked:
        sys.exit(f"tools/list still has excluded tools: {sorted(leaked)}")
    OUT.write_text(render(tools))
    print(f"wrote {OUT} with {len(tools)} tools ({'derived from /mcp' if derive else 'live /mcp/chatgpt'})")


if __name__ == "__main__":
    main()
