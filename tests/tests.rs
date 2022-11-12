const SPEC_SCRIPT: &str = include_str!("spec.sh");

mod fixtures;

#[macro_use]
mod macros;
mod cli;
mod compgen;
mod create;
#[cfg(unix)]
mod interrupt;
mod runmefile;
