# Code citations

When showing or referencing code in responses:

- Referencing existing code — in Cursor: citation blocks in the ```startLine:endLine:filepath format, fences on their own line, never prefixed by list markers. In Claude Code: markdown links like [foo.ts:42](src/utils/foo.ts).
- Inside fenced code blocks and inline backticks, content is shown literally: do not use HTML character references.
- In code citations, skip large irrelevant chunks using `...` or pseudocode comments.
- In non-citation code blocks meant for copy-pasting, write full commands — no `...` omissions.
