use anyhow::{anyhow, bail, Result};
use clap::{Arg, ArgAction, Command};
use either::Either;
use std::{
    env, fs,
    path::{Path, PathBuf},
    process,
    sync::{
        atomic::{AtomicBool, Ordering},
        Arc,
    },
};
use which::which;

const SCRIPT_NAMES: [&str; 6] = [
    "Runmefile.sh",
    "Runmefile",
    "runmefile.sh",
    "runmefile",
    "RUNMEFILE.sh",
    "RUNMEFILE",
];

fn main() {
    match run() {
        Ok(code) => {
            if code != 0 {
                process::exit(code);
            }
        }
        Err(err) => {
            eprintln!("{}", err);
            process::exit(1);
        }
    }
}

fn run() -> Result<i32> {
    let mut runme_args: Vec<String> = vec![];
    let mut script_args: Vec<String> = vec![];
    let mut next_runme_arg = true;
    for arg in std::env::args() {
        if next_runme_arg {
            runme_args.push(arg);
            next_runme_arg = false;
            continue;
        }
        if script_args.is_empty() && arg.starts_with("--runme-") {
            runme_args.push(arg);
            continue;
        }
        next_runme_arg = false;
        script_args.push(arg);
    }
    let matches = Command::new(env!("CARGO_CRATE_NAME"))
        .version(env!("CARGO_PKG_VERSION"))
        .author(env!("CARGO_PKG_AUTHORS"))
        .override_usage(
            r#"
    runme --runme-eval SCRIPT [ARGS...]        Parse arguments `eval $(runme --runme-eval "$0" "$@")`
    runme --runme-create [TASKS...]            Create a boilerplate runmefile
    runme --runme-help                         Print help information
    runme --runme-version                      Print version information"#,
        )
        .help_template(r#"{bin} {version}
{author}
{about}

USAGE:{usage}"#)
        .disable_help_flag(true)
        .disable_version_flag(true)
        .disable_help_subcommand(true)
        .about(concat!(
            env!("CARGO_PKG_DESCRIPTION"),
            " - ",
            env!("CARGO_PKG_REPOSITORY")
        ))
        .arg(Arg::new("runme-eval").long("runme-eval").action(ArgAction::SetTrue))
        .arg(Arg::new("runme-create").long("runme-create").action(ArgAction::SetTrue))
        .arg(
            Arg::new("runme-compgen")
                .long("runme-compgen").action(ArgAction::SetTrue))
        .arg(
            Arg::new("runme-file")
                .long("runme-file").action(ArgAction::SetTrue)
        )
        .arg(
            Arg::new("runme-version")
                .long("runme-version")
                .action(ArgAction::Version)
        )
        .arg(
            Arg::new("runme-help")
                .long("runme-help")
                .action(ArgAction::Help)
        )
        .try_get_matches_from(&runme_args)?;

    if matches.get_flag("runme-eval") {
        let (source, cmd_args) = parse_script_args(&script_args)?;
        let cmd_args: Vec<&str> = cmd_args.iter().map(|v| v.as_str()).collect();
        match argc::eval(&source, &cmd_args)? {
            Either::Left(output) => {
                println!("{}", output)
            }
            Either::Right(error) => {
                if env::var_os("NO_COLOR").is_some() {
                    eprintln!("{}", error);
                } else {
                    eprintln!("{}", error.render().ansi());
                }
                if error.use_stderr() {
                    println!("exit 1");
                } else {
                    println!("exit 0");
                }
            }
        }
    } else if matches.get_flag("runme-create") {
        if let Some((_, script_file)) = get_script_path(false) {
            bail!("Already exist {}", script_file.display());
        }
        let content = generate_boilerplate(&script_args);
        let names = candidate_script_names();
        fs::write(&names[0], content).map_err(|err| anyhow!("Failed to create runme.sh, {err}"))?;
    } else if matches.get_flag("runme-file") {
        let (_, script_file) =
            get_script_path(true).ok_or_else(|| anyhow!("Not found script file"))?;
        print!("{}", script_file.display());
    } else if matches.get_flag("runme-compgen") {
        let (source, cmd_args) = parse_script_args(&script_args)?;
        let cmd_args: Vec<&str> = cmd_args.iter().map(|v| v.as_str()).collect();
        print!("{}", argc::compgen(&source, &cmd_args)?.join(" "))
    } else {
        let shell = get_shell_path().ok_or_else(|| anyhow!("Not found shell"))?;
        let (script_dir, script_file) = get_script_path(true).ok_or_else(|| {
            anyhow!("Not found script file, try `runme --runme-help` to get help.")
        })?;
        let interrupt = Arc::new(AtomicBool::new(false));
        let interrupt_me = interrupt.clone();
        ctrlc::set_handler(move || interrupt_me.store(true, Ordering::Relaxed))
            .map_err(|err| anyhow!("Failed to set CTRL-C handler: {}", err))?;
        let mut command = process::Command::new(&shell);
        command.arg(&script_file);
        command.args(&script_args);
        command.current_dir(script_dir);
        let status = command
            .status()
            .map_err(|err| anyhow!("Run `{}` throw {}", script_file.display(), err))?;
        let mut code = status.code().unwrap_or_default();
        if code == 0 && interrupt.load(Ordering::Relaxed) {
            code = 130;
        }
        return Ok(code);
    }
    Ok(0)
}

fn parse_script_args(args: &[String]) -> Result<(String, Vec<String>)> {
    if args.is_empty() {
        bail!("No script file");
    }
    let script_file = args[0].as_str();
    let args: Vec<String> = args[1..].to_vec();
    let source = fs::read_to_string(script_file)
        .map_err(|e| anyhow!("Failed to load '{}', {}", script_file, e))?;
    let name = Path::new(script_file)
        .file_name()
        .and_then(|v| v.to_str())
        .ok_or_else(|| anyhow!("Failed to get script name"))?;
    let mut cmd_args = vec![name.to_string()];
    cmd_args.extend(args);
    Ok((source, cmd_args))
}

fn generate_boilerplate(args: &[String]) -> String {
    let tasks = args
        .iter()
        .map(|cmd| {
            format!(
                r#"
# @cmd
{cmd}() {{
    echo Run {cmd}
}}
"#
            )
        })
        .collect::<Vec<String>>()
        .join("");

    format!(
        r#"#!/usr/bin/env bash

set -e
{tasks}
eval $(runme --runme-eval "$0" "$@")
"#
    )
}

fn get_script_path(recursive: bool) -> Option<(PathBuf, PathBuf)> {
    let candidates = candidate_script_names();
    let mut dir = env::current_dir().ok()?;
    loop {
        for name in candidates.iter() {
            let path = dir.join(name);
            if path.exists() {
                return Some((dir, path));
            }
        }
        if !recursive {
            return None;
        }
        dir = dir.parent()?.to_path_buf();
    }
}

fn candidate_script_names() -> Vec<String> {
    let mut names = vec![];
    if let Ok(name) = env::var("RUNME_SCRIPT") {
        names.push(name.clone());
        if !name.ends_with(".sh") {
            names.push(format!("{}.sh", name));
        }
    }
    names.extend(SCRIPT_NAMES.into_iter().map(|v| v.to_string()));
    names
}

fn get_shell_path() -> Option<PathBuf> {
    let shell = match env::var("RUNME_SHELL") {
        Ok(v) => Path::new(&v).to_path_buf(),
        Err(_) => get_bash_path()?,
    };
    if !shell.exists() {
        return None;
    }
    Some(shell)
}

#[cfg(windows)]
fn get_bash_path() -> Option<PathBuf> {
    if let Ok(bash) = which("bash") {
        if bash.display().to_string().to_lowercase() != "c:\\windows\\system32\\bash.exe" {
            return Some(bash);
        }
    }
    let git = which("git").ok()?;
    Some(git.parent()?.parent()?.join("bin").join("bash.exe"))
}

#[cfg(not(windows))]
fn get_bash_path() -> Option<PathBuf> {
    which("bash").ok()
}
