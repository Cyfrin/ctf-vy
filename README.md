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
- [uv](https://docs.astral.sh/uv/)
  - You'll know you've done it right if you can run `uv --version` and get an output like: `uv v0.1.0`
## Installation

```bash
git clone https://github.com/cyfrin/ctf-vy
cd ctf-vy
```

## Quickstart

1. Install the packge 

```bash
mox install cyfrin/ctf-vy
```

2. Create a registry contract

```python
from src.protocol import ctf_registry

initializes: ctf_registry  

exports: (
    ctf_registry.__interface__
)

NAME: constant(String[25]) = "Our CTF"
SYMBOL: constant(String[5]) = "CTF"
NAME_EIP712_: constant(String[50]) = "CTF Registry"
VERSION_EIP712_: constant(String[20]) = "1.0.0"

@deploy
def __init__():
    ctf_registry.__init__(NAME, SYMBOL, NAME_EIP712_, VERSION_EIP712_)
```

3. Create your challenges 

```python
from src.protocol import challenge
from src.interfaces import i_challenge

implements: i_challenge
initializes: challenge

exports: (
    challenge.__interface__
)

IMAGE_URI: constant(String[100]) = "ipfs://QmZg79jdDNBTi3fxwnjXTvbM9Gtd1C84Axo55Ht2kYCeDH"
BLANK_TWITTER_HANDLE: constant(String[1]) = ""
ATTRIBUTE: constant(String[16]) = "Getting learned!"
DESCRIPTION: constant(String[50]) = "This is a simple CTF challenge."

@deploy
def __init__(address_registry: address):
    challenge.__init__(address_registry, ATTRIBUTE, DESCRIPTION, IMAGE_URI)

@external
def solveChallenge():
    challenge._update_and_reward_solver(BLANK_TWITTER_HANDLE)

@external
@view
def extraDescription(user: address) -> String[1024]:
    return ""

@external
@view
def attribute() -> String[256]:
    return challenge.attribute

@external
@view
def description() -> String[1024]:
    return challenge.description
```

4. Deploy and test

```python
def test_deploy_and_add_challenge():
    # Deploy registry
    registry = simple_ctf_registry.deploy()
    
    # Deploy challenge
    challenge = simple_ctf_challenge.deploy(registry.address)
    
    # Add challenge to registry
    registry.addChallenge(challenge.address)
    
    # Verify challenge was added
    assert registry.is_challenge_contract(challenge.address) is True
```

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