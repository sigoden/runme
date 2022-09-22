use assert_cmd::prelude::*;
use std::process::Command;

#[test]
fn version() {
    Command::cargo_bin("runme")
        .unwrap()
        .arg("--runme-version")
        .assert()
        .stderr(predicates::str::contains(format!(
            "runme {}",
            env!("CARGO_PKG_VERSION")
        )))
        .failure();
}

#[test]
fn help() {
    Command::cargo_bin("runme")
        .unwrap()
        .arg("--runme-help")
        .assert()
        .stderr(predicates::str::contains(env!("CARGO_PKG_DESCRIPTION")))
        .failure();
}
