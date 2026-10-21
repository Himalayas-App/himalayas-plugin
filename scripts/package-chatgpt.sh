#!/usr/bin/env bash
# Validate the OpenAI (ChatGPT and Codex) plugin package in chatgpt/ and zip it
# to dist/himalayas-chatgpt.zip, with chatgpt/ as the only top-level directory.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
pkg="chatgpt"
out="dist/himalayas-chatgpt.zip"
cd "$root"

echo "Checking JSON"
for file in "$pkg/plugin.json" "$pkg/mcp.json"; do
  python3 -m json.tool "$file" > /dev/null
done

echo "Checking manifest fields, limits and test cases"
python3 - "$pkg" <<'PY'
import json, pathlib, re, struct, sys

pkg = pathlib.Path(sys.argv[1])
errors = []
def fail(msg): errors.append(msg)

manifest = json.loads((pkg / "plugin.json").read_text())
mcp = json.loads((pkg / "mcp.json").read_text())

# Agent Plugins 1.0.0 schemas allow no other top-level or server keys.
allowed = {"$schema", "name", "version", "description", "author", "homepage",
           "repository", "license", "keywords", "extensions"}
if manifest.get("$schema") != "https://agent-plugins.org/schemas/1.0.0/plugin.schema.json":
    fail("plugin.json: wrong $schema")
if set(manifest) - allowed:
    fail(f"plugin.json: keys not in the schema: {sorted(set(manifest) - allowed)}")
if not re.fullmatch(r"[a-z0-9](?:[a-z0-9-]*[a-z0-9])?", manifest.get("name", "")) or "--" in manifest["name"]:
    fail("plugin.json: name must be lowercase letters, digits and single hyphens")
if not re.fullmatch(r"\d+\.\d+\.\d+", manifest.get("version", "")):
    fail("plugin.json: version must be a semantic version")
if len(manifest.get("description", "")) > 4000:
    fail("plugin.json: description over 4000 characters")

openai = manifest.get("extensions", {}).get("com.openai", {})
ui = openai.get("interface", {})
for field, limit in [("displayName", 30), ("shortDescription", 30),
                     ("longDescription", 4000), ("developerName", 80)]:
    value = ui.get(field, "")
    if not value.strip():
        fail(f"interface.{field} is required")
    elif len(value) > limit:
        fail(f"interface.{field} is {len(value)} characters, limit {limit}")
    if field != "longDescription" and "\n" in value:
        fail(f"interface.{field} must be one line")

categories = {"Productivity", "Creativity", "Developer Tools", "Business & Operations",
              "Data & Analytics", "Communication", "Education & Research", "Security",
              "Finance", "Healthcare", "Travel", "Entertainment", "Other"}
if ui.get("category") not in categories:
    fail("interface.category is not a supported category")

caps = ui.get("capabilities", [])
if len(caps) > 20 or any(not c.strip() or len(c) > 120 or "\n" in c for c in caps):
    fail("interface.capabilities: at most 20, each one line of 1 to 120 characters")

prompts = ui.get("defaultPrompt", [])
prompts = [prompts] if isinstance(prompts, str) else prompts
if len(prompts) > 3:
    fail("interface.defaultPrompt: at most 3")
if len({" ".join(p.split()).lower() for p in prompts}) != len(prompts):
    fail("interface.defaultPrompt: prompts must be unique")
for p in prompts:
    if not p.strip() or len(p) > 128 or "\n" in p:
        fail(f"interface.defaultPrompt over 128 characters or not one line: {p!r}")
    if "@" in p:
        fail(f"interface.defaultPrompt must not @mention: {p!r}")

for field in ("websiteURL", "supportURL", "privacyPolicyURL", "termsOfServiceURL"):
    url = ui.get(field, "")
    if not url.startswith("https://") or len(url) > 1024:
        fail(f"interface.{field} must be an HTTPS URL of at most 1024 characters")

color = ui.get("brandColor", "")
if not re.fullmatch(r"#[0-9A-Fa-f]{6}", color):
    fail("interface.brandColor must be #RRGGBB")
else:
    def channel(c):
        c = c / 255
        return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
    r, g, b = (channel(int(color[i:i + 2], 16)) for i in (1, 3, 5))
    contrast = 1.05 / (0.2126 * r + 0.7152 * g + 0.0722 * b + 0.05)
    if contrast < 2:
        fail(f"interface.brandColor contrast against white is {contrast:.2f}, needs 2")

for field in ("logo", "composerIcon"):
    path = ui.get(field, "")
    if not path.startswith("./"):
        fail(f"interface.{field} must start with ./")
        continue
    image = pkg / path
    if not image.is_file():
        fail(f"interface.{field}: {path} is missing")
        continue
    data = image.read_bytes()
    if data[:8] != b"\x89PNG\r\n\x1a\n" or len(data) > 5 * 1024 * 1024:
        fail(f"interface.{field}: {path} must be a PNG of at most 5 MiB")
        continue
    width, height = struct.unpack(">II", data[16:24])
    if width != height or width < 48 or width > 4096:
        fail(f"interface.{field}: {path} is {width}x{height}, needs square 48 to 4096")

tools_md = (pkg / "skills/himalayas-basics/references/tools.md").read_text()
tools = set(re.findall(r"^### `([a-z_]+)`", tools_md, re.M))
review = openai.get("review", {})
for key in ("test_credentials", "reviewer_instructions"):
    if key in review or key in openai:
        fail(f"{key} must not be in the package")
cases = review.get("test_cases", {})
positive, negative = cases.get("positive", []), cases.get("negative", [])
if len(positive) != 5:
    fail(f"review.test_cases.positive has {len(positive)} cases, needs exactly 5")
if len(negative) != 3:
    fail(f"review.test_cases.negative has {len(negative)} cases, needs exactly 3")
for i, case in enumerate(positive):
    for field in ("description", "prompt", "tools_triggered", "expected_behavior"):
        if not isinstance(case.get(field), str) or not case[field].strip():
            fail(f"positive case {i + 1}: {field} is required and must be a string")
    for name in re.split(r"\s*,\s*", case.get("tools_triggered", "")):
        if name and name not in tools:
            fail(f"positive case {i + 1}: {name} is not a /mcp/chatgpt tool")
for i, case in enumerate(negative):
    for field in ("description", "prompt"):
        if not isinstance(case.get(field), str) or not case[field].strip():
            fail(f"negative case {i + 1}: {field} is required")
if review.get("commerce") is not False:
    fail("review.commerce must be false")
if not openai.get("publication", {}).get("release_notes", "").strip():
    fail("publication.release_notes is required")

if mcp.get("$schema") != "https://agent-plugins.org/schemas/1.0.0/mcp.schema.json":
    fail("mcp.json: wrong $schema")
servers = mcp.get("mcpServers", {})
if len(servers) != 1:
    fail("mcp.json: plugin-level test cases need exactly one MCP server")
for name, server in servers.items():
    if set(server) - {"type", "url", "headers"}:
        fail(f"mcp.json {name}: keys not in the schema: {sorted(set(server) - {'type', 'url', 'headers'})}")
    if server.get("type") != "streamable-http" or not server.get("url", "").startswith("https://"):
        fail(f"mcp.json {name}: needs type streamable-http and an HTTPS url")
    if server.get("headers"):
        fail(f"mcp.json {name}: public submission rejects nonempty headers")

skills = sorted(p for p in (pkg / "skills").iterdir() if p.is_dir())
for skill in skills:
    text = (skill / "SKILL.md").read_text() if (skill / "SKILL.md").is_file() else ""
    front = re.match(r"---\n(.*?)\n---\n", text, re.S)
    if not front:
        fail(f"{skill.name}: SKILL.md needs front matter")
        continue
    meta = dict(line.split(": ", 1) for line in front.group(1).splitlines() if ": " in line)
    if meta.get("name") != skill.name:
        fail(f"{skill.name}: front matter name must match the directory")
    if not meta.get("description") or len(meta["description"]) > 1024:
        fail(f"{skill.name}: description must be 1 to 1024 characters")
    if len(f"{manifest['name']}:{skill.name}") > 64:
        fail(f"{skill.name}: plugin and skill name over 64 characters")
if len(skills) != 9:
    fail(f"expected 9 skills, found {len(skills)}")

for excluded in ("commands", "hooks", ".claude-plugin", ".codex-plugin", ".app.json"):
    if (pkg / excluded).exists():
        fail(f"{excluded} must not be in the package")

if errors:
    print("\n".join(f"  FAIL {e}" for e in errors))
    sys.exit(1)
print(f"  ok: {len(skills)} skills, {len(tools)} tools, {len(positive)} positive and {len(negative)} negative cases")
PY

echo "Checking for banned terms"
banned='claude|US\$|\$[0-9]|stripe|checkout|get_plus_checkout_link|get_billing_portal_link|purchase_job_extras|post_job_public|check_job_payment_status|get_verification_link|join_radar_waitlist|upgrade|subscribe|extras'
if grep -rniIE "$banned" "$pkg"; then
  echo "  FAIL banned terms found above"
  exit 1
fi
echo "  ok: none"

echo "Writing $out"
mkdir -p dist
rm -f "$out"
zip -qrX "$out" "$pkg" -x '*.DS_Store'
unzip -Z1 "$out" | awk -F/ '{print $1}' | sort -u | grep -qx "$pkg"
test "$(unzip -Z1 "$out" | awk -F/ '{print $1}' | sort -u | wc -l)" -eq 1
echo "  ok: $(unzip -Z1 "$out" | grep -vc '/$') files, $(wc -c < "$out" | tr -d ' ') bytes"
