# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Status

This is a newly initialized repository named "imagefront". There will be no development code specific to a given application in this repository. This is a generic framework for building image frontends of other application, this is not an instance of an end user application.

## Project Setup

The repository currently contains:
- README.md (minimal placeholder)
- .gitignore (Visual Studio/.NET template)


## Task Delegation Strategy

To optimize Claude Code token usage, delegate simple and repetitive tasks to the Antigravity assistant using CLI invocation.

### Delegation Rules

**ALWAYS delegate these tasks to Antigravity:**
- Creating/updating PRs for routine changes (version bumps, dependency updates)
- Simple git operations (commits with conventional messages, merges, rebases)
- Code formatting and linting fixes
- Running test suites and reporting results
- Generating boilerplate code (models, interfaces, basic CRUD)
- File/directory navigation and organization
- Documentation updates (README, CHANGELOG, inline comments)

**NEVER delegate these tasks (handle with Claude Code directly):**
- Architectural decisions and design patterns
- Complex debugging requiring deep reasoning
- Security-sensitive code review
- Performance optimization requiring profiling
- New feature design and implementation strategy

### How to Delegate to Antigravity

Use the Bash tool to invoke Antigravity's chat subcommand:

```bash
antigravity chat --mode agent "your task description here"
```

**Important Notes:**
- The `antigravity chat` command opens the Antigravity GUI and executes the task there
- Output is NOT returned to console - results appear in Antigravity's interface
- Use `--verbose` flag to make the command wait for completion (but output still goes to GUI)
- Best for fire-and-forget tasks that don't need immediate results back to Claude Code

**Available modes:**
- `agent` (default) - Full autonomous agent mode for complex tasks
- `edit` - Direct code editing tasks
- `ask` - Questions and information gathering

**Options:**
- `--add-file <path>` - Add specific files as context
- `--reuse-window` - Use existing Antigravity window (recommended for sequential tasks)
- `--new-window` - Open fresh window (for independent tasks)
- `--verbose` - Wait for task completion (implies --wait)

### Delegation Examples

**Example 1: Create a routine PR**
```bash
antigravity chat --mode agent --add-file package.json "Create a PR to bump all dev dependencies to latest versions. Run tests before creating the PR."
```

**Example 2: Format and commit code**
```bash
antigravity chat --mode agent "Run the code formatter on all .ts files, then create a conventional commit with message 'style: format TypeScript files'"
```

**Example 3: Generate boilerplate**
```bash
antigravity chat --mode agent "Create a new User model interface with id, name, email, and createdAt fields following the existing model patterns in this repo"
```

**Example 4: Update documentation**
```bash
antigravity chat --mode edit --add-file README.md "Add installation instructions section with steps for npm install and environment setup"
```

**Example 5: Run tests and report**
```bash
antigravity chat --mode agent "Run the full test suite, analyze any failures, and create a summary report of test coverage and failing tests"
```

### When Delegating

Before delegating, consider:
1. **Is the task well-defined?** - Antigravity works best with clear instructions
2. **Does it require context?** - Use `--add-file` to provide relevant files
3. **Is it repetitive/operational?** - Perfect for delegation
4. **Does it need reasoning?** - If yes, handle it yourself
5. **Can it run async?** - Since results go to GUI, best for tasks you don't need immediate feedback on

### Workflow Pattern

**Typical delegation flow:**
1. Claude Code identifies task as simple/repetitive
2. Invokes `antigravity chat --mode agent --reuse-window "task"`
3. Antigravity GUI opens and executes task
4. User can monitor progress in Antigravity interface
5. Results (commits, PRs, files) appear in the repository
6. Claude Code can verify results by reading modified files if needed

### Token Optimization

By delegating simple tasks to Antigravity, you preserve Claude Code's token budget for:
- Complex problem-solving
- Architectural decisions
- Deep code analysis
- Strategic refactoring

**Expected savings:** 60-70% reduction in token usage for routine operations
