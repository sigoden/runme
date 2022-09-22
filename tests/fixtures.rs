use assert_cmd::cargo::cargo_bin;
use assert_fs::fixture::TempDir;
use assert_fs::prelude::*;
use rstest::fixture;

#[allow(dead_code)]
pub type Error = Box<dyn std::error::Error>;

/// Test fixture which creates a temporary directory with a few files and directories inside.
/// The directories also contain files.
#[fixture]
#[allow(dead_code)]
pub fn tmpdir() -> TempDir {
    let tmpdir = assert_fs::TempDir::new().expect("Couldn't create a temp dir for tests");
    tmpdir
        .child("dir1")
        .child("runmefile.sh")
        .write_str(&get_file("dir1-runmefile.sh"))
        .unwrap();
    tmpdir
        .child("dir1")
        .child("subdir1")
        .child("runmefile.sh")
        .write_str(&get_file("dir1-subdir1-runmefile.sh"))
        .unwrap();
    tmpdir
        .child("dir1")
        .child("subdir1")
        .child("subsubdir1")
        .child("EMPTY")
        .write_str("")
        .unwrap();
    tmpdir
        .child("dir1")
        .child("subdir1")
        .child("subsubdir1")
        .child("EMPTY")
        .write_str("")
        .unwrap();
    tmpdir
        .child("dir2")
        .child("Runmefile.sh")
        .write_str(&get_file("dir2-Runmefile.sh"))
        .unwrap();
    tmpdir
        .child("dir3")
        .child("runmefile")
        .write_str(&get_file("dir3-runmefile"))
        .unwrap();
    tmpdir
        .child("dir4")
        .child("Runmefile")
        .write_str(&get_file("dir4-Runmefile"))
        .unwrap();
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

fn get_file(name: &str) -> String {
    format!(
        r#"
set -euo pipefail

main() {{
  echo "{name}"
}}

echo $PATH
eval $(runme --runme-eval "$0" "$@")
"#
    )
}
