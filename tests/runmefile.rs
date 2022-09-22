use assert_fs::{fixture::PathChild, TempDir};
use rstest::rstest;

use crate::fixtures::{get_path_env_var, tmpdir, Error};
use assert_cmd::prelude::*;
use std::process::Command;

#[rstest]
fn runmefile(tmpdir: TempDir) -> Result<(), Error> {
    let path_env_var = get_path_env_var();
    Command::cargo_bin("runme")?
        .current_dir(tmpdir.child("dir1").path())
        .env("PATH", path_env_var.clone())
        .assert()
        .stdout(predicates::str::contains("dir1-runmefile.sh"))
        .success();

    Command::cargo_bin("runme")?
        .current_dir(tmpdir.child("dir1").child("subdir1").path())
        .env("PATH", path_env_var.clone())
        .assert()
        .stdout(predicates::str::contains("dir1-subdir1-runmefile.sh"))
        .success();

    Command::cargo_bin("runme")?
        .current_dir(
            tmpdir
                .child("dir1")
                .child("subdir1")
                .child("subsubdir1")
                .path(),
        )
        .env("PATH", path_env_var.clone())
        .assert()
        .stdout(predicates::str::contains("dir1-subdir1-runmefile.sh"))
        .success();

    Command::cargo_bin("runme")?
        .current_dir(tmpdir.child("dir2").path())
        .env("PATH", path_env_var.clone())
        .assert()
        .stdout(predicates::str::contains("dir2-Runmefile.sh"))
        .success();

    Command::cargo_bin("runme")?
        .current_dir(tmpdir.child("dir3").path())
        .env("PATH", path_env_var.clone())
        .assert()
        .stdout(predicates::str::contains("dir3-runmefile"))
        .success();

    Command::cargo_bin("runme")?
        .current_dir(tmpdir.child("dir4").path())
        .env("PATH", path_env_var)
        .assert()
        .stdout(predicates::str::contains("dir4-Runmefile"))
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
            tmpdir
                .child("dir1")
                .join("runmefile.sh")
                .display()
                .to_string(),
        ))
        .success();
    Ok(())
}
