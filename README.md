# runme

[![CI](https://github.com/sigoden/runme/actions/workflows/ci.yaml/badge.svg)](https://github.com/sigoden/runme/actions/workflows/ci.yaml)
[![Crates](https://img.shields.io/crates/v/runme.svg)](https://crates.io/crates/runme)

A cli task runner.

![demo](https://user-images.githubusercontent.com/4012553/193002743-1b3adc69-d00f-46af-9f64-b80f8648d690.gif)

- [runme](#runme)
  - [Install](#install)
    - [With cargo](#with-cargo)
    - [Binaries on macOS, Linux, Windows](#binaries-on-macos-linux-windows)
    - [GitHub Actions](#github-actions)
  - [Get Started](#get-started)
  - [Why use runme?](#why-use-runme)
    - [Cross-platform support for Windows / macOS and Linux](#cross-platform-support-for-windows--macos-and-linux)
    - [Task is just function](#task-is-just-function)
    - [Task accepts flags, options and positional arguments](#task-accepts-flags-options-and-positional-arguments)
    - [Task can have aliases](#task-can-have-aliases)
    - [Task can have pre and post dependencies](#task-can-have-pre-and-post-dependencies)
    - [Task can be semantically grouped](#task-can-be-semantically-grouped)
    - [The default task](#the-default-task)
    - [Informative tasks listings and beautiful help printings](#informative-tasks-listings-and-beautiful-help-printings)
  - [Advanced Topics](#advanced-topics)
    - [Completions](#completions)
    - [Customize shell path](#customize-shell-path)
    - [Customize script name](#customize-script-name)
  - [License](#license)

## Install

### With cargo

```
cargo install --force runme
```

### Binaries on macOS, Linux, Windows

Download from [Github Releases](https://github.com/sigoden/runme/releases), unzip and add runme to your $PATH.

### GitHub Actions

[extractions/setup-crate](https://github.com/marketplace/actions/setup-crate) can be used to install just in a GitHub Actions workflow.

```yaml
- uses: extractions/setup-crate@v1
  with:
    owner: sigoden
    name: runme
```

## Get Started

First, define a simple `Runmefile.sh` in your project.

```sh
#!/usr/bin/env bash

set -e

# @cmd build project
# @alias b
build() {
    echo Run build
}

# @cmd test project
test() {
    echo Run test
}

eval $(runme --runme-eval "$0" "$@")
```

Then, try running one of your commands!

```
runme build
runme test
```

You can also run `runme --runme-create build test` to quickly create boilerplate Runmefile.sh.

> Runme uses [`argc`](https://github.com/sigoden/argc) to parse Runmefile.

> `@cmd`, `@alias` are [comment tags](https://github.com/sigoden/argc#comment-tags).

## Why use runme?

`runme` provides a cross platform way to define and execute custom commands specific to a codebase.

The less work you have to do when performing repetitive tasks like building, testing, linting, etc, the easier your job becomes. After you've configured it through a `Runmefile.sh`, a task runner can do most of that mundane work for you—and your team—with basically zero effort.

### Cross-platform support for Windows / macOS and Linux

`runme` binary is available in linux, macos, and windows.

`runme` depends on bash. Linux/macos has built-in bash. In windows, git is frequently used, runme automatically locates and uses bash that comes with git.

Environments that support bash usually also support GNU tools, so you can use `ls`, `rm`, `grep`, `sed`, `awk`... in Runmefile freely and confidently.

### Task is just function

To define a new task `foo`, simply create the `foo` function and add the `@cmd` comment tag above it.

```sh
# @cmd
task1() {
  echo Run task1
}
```

### Task accepts flags, options and positional arguments

```sh
# @cmd     A simple task
# @flag    -f --flag      A flag
# @option  --opt          A option
# @arg     arg            A positional argument
task2() {
  echo "flag: $argc_flag"
  echo "opt:  $argc_opt"
  echo "arg:  $argc_arg"
}
```

```
$ runme cmd -h
A simple task

USAGE:
    Runmefile.sh cmd [OPTIONS] [ARG]

ARGS:
    <ARG>    A positional argument

OPTIONS:
    -f, --flag         A flag
    -h, --help         Print help information
        --opt <OPT>    A option

$ runme cmd -f --opt=v1 v2
flag: 1
opt:  v1
arg:  v2
```

*Shell variables are also available.*

```sh
# @cmd
build() {
  echo '$@:' $@
  echo '$1:' $1
  echo '$2:' $2
  echo '$#:' $#
}
```

```
$ runme build foo bar
$@: foo bar
$1: foo
$2: bar
$#: 2
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

Tasks can depend on other tasks. Dependencies are established by calling functions.

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

When `runme` is invoked without a task name, it runs the `main` function. 
If the `main` function does not exist, runme will print help information.

```sh
main() { 
  foo
  bar
}

# @cmd
foo() {
  echo foo
}

# @cmd
bar() {
  echo baz
}
```

```
$ runme
foo
bar
```

### Informative tasks listings and beautiful help printings

`runme --help`  or `runme --h` will print a help text listing all tasks along with their descriptions and aliases.

`runme <task> --help` or `runme <task> -h` will print a help text containing the description of task's flags, options and positional arguments.

## Advanced Topics

### Completions

[Shell completion scripts](completions) are available for bash/zsh/powershell.

### Customize shell path

You can use environment variable `RUNME_SHELL` to customize shell path.

```
RUNME_SHELL="C:\\Program Files\\Git\\bin\\bash.exe"
```
### Customize script name

By default, runme searches for runme script file of the following:

- Runmefile.sh or Runmefile
- runmefile.sh or runmefile
- RUNMEFILE.sh or RUNMEFILE

You can use environment variable `RUNME_SCRIPT` to custom script name.

```
RUNME_SCRIPT=taskfile.sh
```
## License

Copyright (c) 2022 runme-developers.

runme is made available under the terms of either the MIT License or the Apache License 2.0, at your option.

See the LICENSE-APACHE and LICENSE-MIT files for license details.