#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

SNIP=$(python3 - <<'PY'
import pathlib
s=pathlib.Path('_related_snippet.html').read_text()
# escape for perl replacement
s=s.replace('\\','\\\\').replace('$','\\$').replace('@','\\@')
print(s)
PY
)

while IFS= read -r -d '' f; do
  # Remove injected blocks (if present). Use ~ delimiter so # in CSS doesn't break.
  perl -0777 -i -pe 's~\n\s*<section style="margin-top:60px;\s*padding:40px 0;\s*border-top:1px solid \\#ddd;">.*?</body>~\n</body>~s' "$f"

  # Insert the clean related guides block before the footer (except guides overview)
  if [[ "$f" != *"/guides/index.html" ]]; then
    if ! grep -q "related-guides-block" "$f" && grep -q '<footer class="footer"' "$f"; then
      perl -0777 -i -pe "s~<footer class=\"footer\"~${SNIP}\n\n<footer class=\"footer\"~s" "$f"
    fi
  fi

done < <(find . -type f -name '*.html' -print0)

