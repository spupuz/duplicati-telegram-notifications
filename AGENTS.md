# Duplicati Telegram Notifications — Agent Rules

## Overview
Bash scripts that send Duplicati backup notifications via Telegram Bot API.

## Data Protection
- **NEVER commit secrets**: no `telegram.conf`, `.env`, API keys, tokens.
- `telegram.conf` is gitignored — only `telegram.conf.example` is tracked.

## OmniState Memory Protocol
Use the OmniState MCP server (`omnistate`) for persistent memory:
1. `project_register` → `session_start` at session start
2. `task_add` before significant work, `task_update` to done when finished
3. `memory_remember` for decisions (project/shared scope appropriately)
4. `session_snapshot` at end

If MCP is unreachable, say so once and continue without blocking.