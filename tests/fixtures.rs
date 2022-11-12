use assert_cmd::cargo::cargo_bin;
use assert_fs::fixture::{ChildPath, TempDir};
use assert_fs::prelude::*;
use rstest::fixture;

#[allow(dead_code)]
pub type Error = Box<dyn std::error::Error>;

pub const SCRIPT_PATHS: [&str; 8] = [
    "dir1/Runmefile.sh",
    "dir1/subdir1/Runmefile.sh",
    "dir1/subdir1/subdirdir1/EMPTY",
    "dir2/runmefile.sh",
    "dir3/RUNMEFILE.sh",
    "dir4/Runmefile",
    "dir5/runmefile",
    "dir6/RUNMEFILE",
];

/// Test fixture which creates a temporary directory with a few files and directories inside.
/// The directories also contain files.
#[fixture]
#[allow(dead_code)]
pub fn tmpdir() -> TempDir {
    let tmpdir = assert_fs::TempDir::new().expect("Couldn't create a temp dir for tests");
    for path in SCRIPT_PATHS {
        write_file(&tmpdir, path);
    }
    tmpdir
}

#[fixture]
#[allow(dead_code)]
pub fn tmpdir2() -> TempDir {
    assert_fs::TempDir::new().expect("Couldn't create a temp dir for tests")
}

pub fn get_path_env_var() -> String {
    let runme_path = cargo_bin("runme");
    let runme_dir = runme_path.parent().unwrap();
    let path_env_var = std::env::var("PATH").unwrap();
    if cfg!(windows) {
        format!("{};{}", runme_dir.display(), path_env_var)
    } else {
        format!("{}:{}", runme_dir.display(), path_env_var)
    }
}

pub fn tmpdir_path(tmpdir: &TempDir, path: &str) -> ChildPath {
    let parts: Vec<&str> = path.split('/').collect();
    let cp = tmpdir.child(parts[0]);
    parts.iter().skip(1).fold(cp, |acc, part| acc.child(part))
}

fn write_file(tmpdir: &TempDir, path: &str) {
    let cp = tmpdir_path(tmpdir, path);
    if path.ends_with("EMPTY") {
        cp.write_str("").unwrap();
    } else {
        cp.write_str(&get_script(path)).unwrap();
    }
}

fn get_script(name: &str) -> String {
    format!(
        r#"#!/usr/bin/env bash
set -euo pipefail

main() {{
  echo "{name}"
}}

# @cmd
task1() {{
    sleep $1
}}

eval $(runme --runme-eval "$0" "$@")
"#
    )
}
