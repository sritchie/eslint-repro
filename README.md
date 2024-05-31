# pre-commit / eslint bug repro

Install pre-commit:

```
pip install pre-commit
```

Run the `eslint` `pre-commit` step:

```
pre-commit run eslint --all
```

output:

```
NODE_PATH:
/Users/sritchie/.cache/pre-commit/repoxz3rawvg/node_env-default/lib/node_modules
NPM_CONFIG_PREFIX:
/Users/sritchie/.cache/pre-commit/repoxz3rawvg/node_env-default
contents of NODE_PATH:
corepack eslint globals npm pre_commit_placeholder_package

Oops! Something went wrong! :(

ESLint: 9.3.0

Error [ERR_MODULE_NOT_FOUND]: Cannot find package 'globals' imported from /Users/sritchie/code/mit/eslint-repro/eslint.config.mjs
Did you mean to import "globals/index.js"?
    at packageResolve (node:internal/modules/esm/resolve:841:9)
    at moduleResolve (node:internal/modules/esm/resolve:914:18)
    at defaultResolve (node:internal/modules/esm/resolve:1119:11)
    at ModuleLoader.defaultResolve (node:internal/modules/esm/loader:542:12)
    at ModuleLoader.resolve (node:internal/modules/esm/loader:511:25)
    at ModuleLoader.getModuleJob (node:internal/modules/esm/loader:241:38)
    at ModuleJob._link (node:internal/modules/esm/module_job:126:49)
```

I would have expected that this `eslint.config.mjs` should work fine, given that
`globals` is installed:

```
import globals from "globals";

export default [
  {
    languageOptions: { globals: globals.browser },
    files: ["src/**/*.js"],
  },
];

```

## Explanation of the issue

`.pre-commit-config.yaml` looks like this:

```
repos:
  - repo: local
    hooks:
    - id: eslint
      name: eslint
      language: node
      additional_dependencies:
      - eslint@9.3.0
      - globals@15.3.0
      entry: ./run_eslint.sh
```

This will install a node environment with the listed "additional dependencies"
(installed via `npm install`), and then trigger the `entry` point.

I used a shell script here, `run_eslint.sh`, so I could show that the
environment variables are set correctly, and that the `NODE_PATH` does indeed
have `eslint` and `globals` installed into it.

However, when I either run the script explicitly:

```
./run_eslint.sh
```

Or run it through `pre-commit`:

```
pre-commit run eslint --all
```

I see the following output:

```
NODE_PATH:
/Users/sritchie/.cache/pre-commit/repoxz3rawvg/node_env-default/lib/node_modules
NPM_CONFIG_PREFIX:
/Users/sritchie/.cache/pre-commit/repoxz3rawvg/node_env-default
contents of NODE_PATH:
corepack eslint globals npm pre_commit_placeholder_package

Oops! Something went wrong! :(

ESLint: 9.3.0

Error [ERR_MODULE_NOT_FOUND]: Cannot find package 'globals' imported from /Users/sritchie/code/mit/eslint-repro/eslint.config.mjs
Did you mean to import "globals/index.js"?
    at packageResolve (node:internal/modules/esm/resolve:841:9)
    at moduleResolve (node:internal/modules/esm/resolve:914:18)
    at defaultResolve (node:internal/modules/esm/resolve:1119:11)
    at ModuleLoader.defaultResolve (node:internal/modules/esm/loader:542:12)
    at ModuleLoader.resolve (node:internal/modules/esm/loader:511:25)
    at ModuleLoader.getModuleJob (node:internal/modules/esm/loader:241:38)
    at ModuleJob._link (node:internal/modules/esm/module_job:126:49)
```

telling me that `NODE_PATH` is set to a directory containing `globals`, but
`eslint` can't find the import in `eslint.config.mjs`.
