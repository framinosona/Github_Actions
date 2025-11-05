# 🌳 Debug Directory Tree Action

A simple GitHub Action that displays directory tree structures for debugging purposes.

## Usage

### Basic Example

```yaml
- name: Show directory structure
  uses: laerdal/github_actions/debug-tree@main
```

### With Custom Options

```yaml
- name: Debug project structure
  uses: laerdal/github_actions/debug-tree@main
  with:
    path: "./src"
    depth: "2"
    show-hidden: "false"
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `path` | Path to display | No | `"."` |
| `depth` | Maximum depth (0 for unlimited) | No | `"5"` |
| `show-hidden` | Show hidden files | No | `"true"` |

## Examples

### Debug Build Output

```yaml
- name: Show build directory
  uses: laerdal/github_actions/debug-tree@main
  with:
    path: "./dist"
    depth: "2"
```

### Show Project Root

```yaml
- name: Debug project structure
  uses: laerdal/github_actions/debug-tree@main
  with:
    path: "."
    depth: "3"
    show-hidden: "false"
```

## How it Works

- Uses the `tree` command if available (Linux/macOS)
- Falls back to `find` if `tree` is not installed
- Simple console output, just like running `tree` directly

## Output

The action outputs a tree structure directly to the console:

```
🌳 Directory tree for: ./src
├── components/
│   ├── Button.tsx
│   └── Modal.tsx
└── utils/
    └── helpers.ts
```

That's it! Simple and effective for debugging directory structures in your workflows.
