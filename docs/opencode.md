# Open Code

## Coach Agent

When using the coach agent, make sure to add a local `opencode.json` file in the project with the following data.

```json
{
  "$schema": "https://opencode.ai/config.json",
  "default_agent": "coach",
  "instructions": [".ai/plan.md", ".ai/handoff.md"]
}
```

This will allow the coach to use local planning / progress files and default to the coach agents. Note, this file merges with your global `opencode.json` file so will inherit all gloabl settings.
