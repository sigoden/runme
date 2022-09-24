use assert_fs::{fixture::PathChild, TempDir};
use rstest::rstest;

use crate::fixtures::{get_path_env_var, tmpdir, tmpdir_path, Error, SCRIPT_PATHS};
use assert_cmd::prelude::*;
use std::process::Command;

#[rstest]
fn runmefile(tmpdir: TempDir) -> Result<(), Error> {
    let path_env_var = get_path_env_var();

    for path in SCRIPT_PATHS {
        if path.ends_with("EMPTY") {
            continue;
        }
        Command::cargo_bin("runme")?
            .current_dir(tmpdir_path(&tmpdir, path).path().parent().unwrap())
            .env("PATH", path_env_var.clone())
            .assert()
            .stdout(predicates::str::contains(path))
            .success();
    }

    Command::cargo_bin("runme")?
        .current_dir(tmpdir_path(&tmpdir, "dir1/subdir1/subdirdir1"))
        .env("PATH", path_env_var)
        .assert()
        .stdout(predicates::str::contains("dir1/subdir1/Runmefile.sh"))
        .success();

    Ok(())
}

#[rstest]
fn runmefile_path(tmpdir: TempDir) -> Result<(), Error> {
    Command::cargo_bin("runme")?
        .arg("--runme-file")
        .current_dir(tmpdir.child("dir1").path())
        .assert()
        .stdout(predicates::str::contains(
            tmpdir_path(&tmpdir, "dir1/Runmefile.sh")
                .display()
                .to_string(),
        ))
        .success();
    Ok(())
}
