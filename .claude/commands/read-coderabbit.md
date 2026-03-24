# Read CodeRabbit Annotations

Display CodeRabbit annotations stored locally in VS Code workspaceStorage for the current workspace. Does NOT post anything to GitHub.

## Usage
`/read-coderabbit`

## Steps

1. **Find the workspaceStorage folder** for the current repo.
   Use a file from the current branch's diff as an anchor to locate the right folder:
   ```
   git diff main --name-only | head -1
   ```
   Then search:
   ```
   grep -rl "<that file path>" \
     "/Users/ldy11/Library/Application Support/Code/User/workspaceStorage/" \
     --include="*.json" -l 2>/dev/null | grep coderabbit
   ```

2. **Pick the most recent review session**: Load the matched JSON file(s). The file contains an array of session objects with `startedAt`/`endedAt`. Pick the one with the latest `endedAt`.

3. **Extract and display all comments** grouped by file. For each comment show:

   ```
   [#N] path/to/file.rb:LINE  (severity)
   <full comment body>
   ---
   ```

   Include all comments regardless of severity or type — let the user judge.

4. **End with a summary**:
   ```
   총 N개 어노테이션 (critical: X, moderate: Y, minor: Z)
   원하는 번호를 알려주시면 GitHub PR 코멘트로 올려드립니다.
   ```

## Notes
- This command is read-only. Nothing is posted to GitHub.
- workspaceStorage location: `~/Library/Application Support/Code/User/workspaceStorage/`
- Each session file: `<hash>/coderabbit.coderabbit-vscode/<sha>.json`
- If no coderabbit data is found for the current workspace, report that clearly.
