# Runme

Please note: This repository is currently unmaintained. Use [argc](https://github.com/sigoden/argc) instead.

[![CI](https://github.com/sigoden/runme/actions/workflows/ci.yaml/badge.svg)](https://github.com/sigoden/runme/actions/workflows/ci.yaml)
[![Crates](https://img.shields.io/crates/v/runme.svg)](https://crates.io/crates/runme)

A shell-script based task runner.

![demo](https://user-images.githubusercontent.com/4012553/224712229-fdb08a5b-f04a-4b32-85b5-aae020f87096.gif)

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

First, run `runme --runme-create build test` to quickly create boilerplate `Runmefile.sh`

```sh
#!/usr/bin/env bash

# @cmd build project
# @alias b
build() {
    echo Run build
}

# @cmd test project
test() {
    echo Run test
}

eval "$(runme --runme-eval "$0" "$@")"
```

> To define a new task, simply create the bash function and add the [`@cmd`](https://github.com/sigoden/argc#cmd) above it.  **Task is just function**

```
$ runme -h
USAGE: Runmefile.sh <COMMAND>

COMMANDS:
  build  build project [aliases: b]
  test   test project

$ runme test
Run test
$ runme b
Run build
```

> Runme uses [`argc`](https://github.com/sigoden/argc) to parse Runmefile.

## Features

### Cross platform

`runme` binary is available in linux, macos, and windows.

`runme` depends on bash which already built into linux/macos. In windows, runme automatically locates and uses bash that comes with **git** by default.

Gnu tools like `ls`, `rm`, `grep`, `sed`, `awk`... also provided with bash, so you can uses them freely and confidently in the Runmefile.

### Task parameters

Use [comment tags](https://github.com/sigoden/argc#comment-tags) to define task parameters.

- [`@arg`](https://github.com/sigoden/argc#arg): define positional argument
- [`@option`](https://github.com/sigoden/argc#option): define option argument
- [`@flag`](https://github.com/sigoden/argc#flag): define flag argument

```sh
# @cmd Download a file
# @alias    d
# @flag     -f --force              Override existing file
# @option   -t --tries <NUM>        Set number of retries to NUM
# @arg      source!                 Url to download from
# @arg      target                  Save file to
download() {
    echo "cmd:                      download"
    echo "flag:   --force           $argc_force"
    echo "option: --tries           $argc_tries"
    echo "arg:    source            $argc_source"
    echo "arg:    target            $argc_target"
}
```

```
$ runme download -h
Download a file

USAGE: Runmefile.sh download [OPTIONS] <SOURCE> [TARGET]

ARGS:
  <SOURCE>  Url to download from
  [TARGET]  Save file to

OPTIONS:
  -f, --force        Override existing file
  -t, --tries <NUM>  Set number of retries to NUM
  -h, --help         Print help information
```

```
$ runme download  -f --tries 3 from.txt to.txt
cmd:                      download
flag:   --force           1
option: --tries           3
arg:    source            from.txt
arg:    target            to.txt
```

You can also use shell variables to access task parameters.

```sh
# @cmd
run() {
  echo $2 $1 $#
}
```
```
$ runme run foo bar
bar foo 2
```

### Task aliases

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

### Task dependencies

Dependencies are established by function calling.

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

### Task group

Tasks can be semantically grouped with `_`, `-`, `@`, `.`, `:`.

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

### Default task

When `runme` is invoked without a task name, it runs the `main` function. 
If the `main` function does not exist, runme will print help information.

```sh
main() { 
  foo
}

# @cmd
foo() {
  echo foo
}
```

```
$ runme
foo
```

## Advanced Topics

### Completions

[Shell completion scripts](completions) are available for bash/zsh/fish/powershell.

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