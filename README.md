# runme

[![CI](https://github.com/sigoden/runme/actions/workflows/ci.yaml/badge.svg)](https://github.com/sigoden/runme/actions/workflows/ci.yaml)
[![Crates](https://img.shields.io/crates/v/runme.svg)](https://crates.io/crates/runme)

A task management & automation tool using bash.

- [runme](#runme)
  - [Install](#install)
    - [With cargo](#with-cargo)
    - [Binaries on macOS, Linux, Windows](#binaries-on-macos-linux-windows)
    - [GitHub Actions](#github-actions)
  - [CLI](#cli)
  - [Usage](#usage)
    - [Linux, MacOS, and Windows are supported](#linux-macos-and-windows-are-supported)
    - [Task is just function](#task-is-just-function)
    - [Task accepts flags, options and positional arguments](#task-accepts-flags-options-and-positional-arguments)
    - [Task can have aliases](#task-can-have-aliases)
    - [Task can have pre and post dependencies](#task-can-have-pre-and-post-dependencies)
    - [Task can be semantically grouped](#task-can-be-semantically-grouped)
    - [The default task](#the-default-task)
    - [Informative tasks listings and beautiful help printings](#informative-tasks-listings-and-beautiful-help-printings)
    - [Customize shell](#customize-shell)
    - [Customize script name](#customize-script-name)
  - [Completions](#completions)
  - [License](#license)

## Install

### With cargo

```
cargo install runme
```

### Binaries on macOS, Linux, Windows

Download from [Github Releases](https://github.com/sigoden/runme/releases), unzip and add runme to your $PATH.

### GitHub Actions

[extractions/setup-crate](https://github.com/marketplace/actions/setup-just) can be used to install just in a GitHub Actions workflow.

```yaml
- uses: extractions/setup-crate@v1
  with:
    owner: sigoden
    name: runme
```

## CLI

```
A task management & automation tool using bash - https://github.com/sigoden/runme

USAGE:
    runme --runme-eval SCRIPT [ARGS...]        Parse arguments `eval $(runme --runme-eval "$0" "$@")`
    runme --runme-create [TASKS...]            Create a boilerplate runmefile
    runme --runme-help                         Print help information
    runme --runme-version                      Print version information
```

All runme options are prefixed with `--runme` in order to distinguish with script options.

`runme --help` display script help information, `runme --runme-help` display runme cli help information.

`runme --runme-create foo bar` will generate boilerplate `runmefile.sh` as show bellow.

```
#!/usr/bin/env bash

set -e

# @cmd
foo() {
    echo Run foo
}

# @cmd
bar() {
    echo Run bar
}

eval $(runme --runme-eval "$0" "$@")
```

## Usage

![task automation](https://user-images.githubusercontent.com/4012553/183369248-a898021b-bf5b-414b-b353-786522d85f13.png)

Using runme script for task automation has the following disadvantages:

- Not work in some shell such as powershell.
- No shell completions.
- Need to locate script file manually e.g. `../../script.sh`

`runme` will automatically search for the `runmefile.sh` file in the current project or its parent directory, then run it with `bash`.

`runme` runs `runmefile.sh` like `make` runs `makefile`.

### Linux, MacOS, and Windows are supported

`runme` binaries are available in linux, macos, and windows.

`runme` require `bash` which already builtin in macos/linux. In windows, most developers already have git installed, `runme` automatically locate and use git bash.

GNU tools like `ls`, `rm`, `grep`, `find`, `sed`, `awk`... are also available, use them freely and confidently.

### Task is just function

Adds a task by putting `@cmd` above a function.

```sh
# @cmd Build project
build() {
  echo Build...
}

# @cmd Run tests
test() {
  echo Test...
}

helper() {
  :;
}

eval $(runme --runme-eval "$0" "$@")
```

```
$ runme
runmefile.sh 

USAGE:
    runmefile.sh <SUBCOMMAND>

OPTIONS:
    -h, --help    Print help information

SUBCOMMANDS:
    build    Build project
    test     Run tests 

$ runme build
Build...
```

### Task accepts flags, options and positional arguments

```sh
# @cmd     A simple task
# @flag    -f --flag      A flag
# @option  --opt          A option
# @arg     arg            A positional argument
cmd() {
  echo "flag: $runme_flag"
  echo "opt:  $runme_opt"
  echo "arg:  $runme_arg"
}
```

```
$ runme cmd -h
runmefile.sh
A simple task

USAGE:
    runmefile.sh cmd [OPTIONS] [ARG]

ARGS:
    <ARG>    A positional argument

OPTIONS:
    -f, --flag         A flag
    -h, --help         Print help information
        --opt <OPT>    A option

$ runme cmd -f --opt foo README.md
flag: 1
opt:  foo
arg:  README.md
```

`@cmd`, `@flag`, `option`, `@arg` are comment tags. see [argc comment tags](https://github.com/sigoden/argc#comment-tags) for more details.

*Shell variables are also available.*

```sh
# @cmd
build() {
  echo $2 $1
}
```

```
$ runme build foo bar
bar foo
```

### Task can have aliases

```sh
# @cmd
# @alias t,tst
test() {
  echo "Test..."
}
```

```
$ runme t
Test...
```

### Task can have pre and post dependencies

Tasks can depend on other tasks. Dependencies are resolved by calling functions.

```sh
# @cmd
bar() { foo;
  echo bar
baz; }

# @cmd
foo() {
  echo foo
}

# @cmd
baz() { 
  echo baz
}
```

```
$ runme bar
foo
bar
baz
```

### Task can be semantically grouped

Tasks can be grouped with `_`, `-`, `@`, `.`, `:`.

```sh
# @cmd
test@unit() {}
# @cmd
test@bin() {}

# @cmd
app.build() {}
# @cmd
app.test() {}
```

### The default task

If the `main` function exists, calling `runme` without any subcommands will call the function, otherwise print a help message and exit.

```sh
# @cmd
foo() {
  echo foo
}
# @cmd
bar() {
  echo baz
}
main() {
  foo
  bar
}
```

```
$ runme
foo
bar
```

### Informative tasks listings and beautiful help printings

See snippets above, `runme` prints a beautiful help message listing all tasks along with their descriptions and aliases.

You can also use `runme <task> -h` to print a help message containing the description of task flags, options and positional arguments.

### Customize shell

runme uses built-in bash in macos/linux, uses git bash in windows.

You can use environment variable `RUNME_SHELL` to customize shell.

```
RUNME_SHELL=/usr/bin/bash
RUNME_SHELL="C:\\Program Files\\Git\\bin\\bash.exe"
```

### Customize script name

By default, runme searches for runme script file of the following:

- runmefile.sh
- Runmefile.sh
- runmefile
- Runmefile

You can use environment variable `RUNME_SCRIPT` to custom script name.

```
RUNME_SCRIPT=taskfile.sh
```

## Completions

[Shell completion scripts](completions) are available for bash/zsh/powershell.

There are two types of completion scripts:

-  `runme.*` is for runme command, they will provide completions for tasks and task parameters.
-  `script.*` is for scripts written with runme.

Please refer to your shell's documentation for how to install them.

## License

Copyright (c) 2022 runme-developers.

runme is made available under the terms of either the MIT License or the Apache License 2.0, at your option.

See the LICENSE-APACHE and LICENSE-MIT files for license details.