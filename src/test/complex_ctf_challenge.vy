"""
@ pragma version 0.4.0
@ title Override CTF Challenge
@ author Patrick Collins
@ notice A simple CTF challenge that only allows one successful solve
@ dev Inherits from base challenge contract
"""

from src.protocol import challenge
from src.interfaces import i_challenge  


implements: i_challenge  
initializes: challenge

exports: (
    challenge.__interface__
)

# Constants
BLANK_TWITTER_HANDLE: constant(String[1]) = ""
BLANK_IMAGE_URI: constant(String[1]) = ""
ATTRIBUTE: constant(String[16]) = "Getting learned!"
DESCRIPTION: constant(String[50]) = "This is a simple CTF challenge."

# Storage
minted: bool

@deploy
def __init__(address_registry: address):
    """
    @notice Contract constructor
    @param address_registry The address of the CTF registry
    """
    challenge.__init__(address_registry, ATTRIBUTE, DESCRIPTION, BLANK_IMAGE_URI)
    self.minted = False

@internal
def _update_and_reward_solver(twitter_handle: String[100]):
    """
    @notice Internal function to mint NFT for solver, only allows one successful solve
    @param twitter_handle Twitter handle of the solver
    """
    assert not self.minted, "Already minted"
    challenge._update_and_reward_solver(twitter_handle)
    self.minted = True

@external
def solve_challenge():
    """
    @notice Function to solve the challenge
    """
    self._update_and_reward_solver(BLANK_TWITTER_HANDLE)


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
