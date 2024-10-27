> :exclamation: **IMPORTANT:** This codebase has not been audited, use at your own risk. 


# ctf-vy (Vyper)

This is the vyper implementation of the [challenge NFT](https://github.com/Cyfrin/ctf).

- [ctf-vy (Vyper)](#ctf-vy-vyper)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Quickstart](#quickstart)
- [Usage](#usage)
  - [Compile](#compile)
  - [Test](#test)
- [Formatting](#formatting)
  - [Python](#python)
  - [Vyper](#vyper)

# Getting Started

## Prerequisites

- [git](https://git-scm.com/)
  - You'll know you've done it right if you can run `git --version` and see a version number.
- [moccasin](https://github.com/Cyfrin/moccasin)
  - You'll know you've done it right if you can run `mox --version` and get an output like: `Moccasin CLI v0.3.3`

## Installation

```bash
git clone https://github.com/cyfrin/ctf-vy
cd ctf-vy
```

## Quickstart

(TODO)

# Usage

## Compile

```bash
mox compile
```

## Test

```bash
mox test
```

# Formatting

## Python

```
uv run ruff check --select I --fix
uv run ruff check . --fix
```

## Vyper 

```
uv run mamushi src
```