"""
@ pragma version 0.4.0
@ title Simple CTF Challenge
@ author Patrick Collins
@ notice A simple CTF challenge where users must find the correct solution string
"""

from src.protocol import challenge

from src.interfaces import i_challenge

implements: i_challenge
initializes: challenge

exports: (
    challenge.__interface__
)

IMAGE_URI: constant(
    String[100]
) = "ipfs://QmZg79jdDNBTi3fxwnjXTvbM9Gtd1C84Axo55Ht2kYCeDH"
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
