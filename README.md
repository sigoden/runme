# runme

[![CI](https://github.com/sigoden/runme/actions/workflows/ci.yaml/badge.svg)](https://github.com/sigoden/runme/actions/workflows/ci.yaml)
[![Crates](https://img.shields.io/crates/v/runme.svg)](https://crates.io/crates/runme)

A task runner using bash.

![demo](https://user-images.githubusercontent.com/4012553/192087589-241125ed-73b3-40e9-b753-9d6a5fc806ac.png)

- [runme](#runme)
  - [Install](#install)
    - [With cargo](#with-cargo)
    - [Binaries on macOS, Linux, Windows](#binaries-on-macos-linux-windows)
    - [GitHub Actions](#github-actions)
  - [Why use runme?](#why-use-runme)
    - [Linux, MacOS, and Windows are supported](#linux-macos-and-windows-are-supported)
    - [Task is just function](#task-is-just-function)
    - [Task accepts flags, options and positional arguments](#task-accepts-flags-options-and-positional-arguments)
    - [Task can have aliases](#task-can-have-aliases)
    - [Task can have pre and post dependencies](#task-can-have-pre-and-post-dependencies)
    - [Task can be semantically grouped](#task-can-be-semantically-grouped)
    - [The default task](#the-default-task)
    - [Informative tasks listings and beautiful help printings](#informative-tasks-listings-and-beautiful-help-printings)
  - [Advanced Topics](#advanced-topics)
    - [CLI Usage](#cli-usage)
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

[extractions/setup-crate](https://github.com/marketplace/actions/setup-just) can be used to install just in a GitHub Actions workflow.

```yaml
- uses: extractions/setup-crate@v1
  with:
    owner: sigoden
    name: runme
```

## Why use runme?

`runme` provides a cross platform way to define and execute custom commands specific to a codebase.

The less work you have to do when performing repetitive tasks like building, testing, running, etc, the easier your job becomes. After you've configured it through a `Runmefile.sh`, a task runner can do most of that mundane work for you—and your team—with basically zero effort.

### Linux, MacOS, and Windows are supported

`runme` binaries are available in linux, macos, and windows.

`runme` depends on bash. Linux/macos has built-in bash. If git is installed on windows, runme will automatically find and use git bash.

GNU tools like `ls`, `rm`, `grep`, `find`, `sed`, `awk`... are also available, use them freely and confidently.


### Task is just function

Adds a task by putting `@cmd` above a function.

```sh
# @cmd Build project
build() {
  echo Run build
}

# @cmd Run tests
test() {
  echo Run test
}

eval $(runme --runme-eval "$0" "$@")
```

> Run `runme --runme-crate build test` to quickly create a boilerplate Runmefile.sh.

### Task accepts flags, options and positional arguments

```sh
# @cmd     A simple task
# @flag    -f --flag      A flag
# @option  --opt          A option
# @arg     arg            A positional argument
cmd() {
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

## Advanced Topics

### CLI Usage

In order to distinguish with task script's flags and options, all runme cli options are prefixed with `--runme` 

`runme --help` display task script's help information, `runme --runme-help` display runme cli's help information.

```
A task management & automation tool using bash - https://github.com/sigoden/runme

USAGE:
    runme --runme-eval SCRIPT [ARGS...]        Parse arguments `eval $(runme --runme-eval "$0" "$@")`
    runme --runme-create [TASKS...]            Create a boilerplate runmefile
    runme --runme-help                         Print help information
    runme --runme-version                      Print version information
```

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