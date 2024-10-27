"""
@ version ^0.4.0
@ title challenge Contract
@ licence MIT
@ author Patrick Collins
@ notice Base contract for CTF challenges
"""

from src.interfaces import i_ctf_registry 
from src.interfaces import i_challenge  
from snekmate.auth import ownable

initializes: ownable

exports: (
    ownable.__interface__
)

# ------------------------------------------------------------------
#                        STATE VARIABLES
# ------------------------------------------------------------------
# Immutable & Constant
REGISTRY: public(immutable(i_ctf_registry))

# Storage
image_uri: String[256]
description: String[1024]
attribute: String[256]

# ------------------------------------------------------------------
#                             EVENTS
# ------------------------------------------------------------------
event AttributeChanged:
    new_attribute: String[256]

event DescriptionChanged:
    new_description: String[1024]

event ExtraDescriptionChanged:
    new_extra_description: String[1024]

event ImageUriChanged:
    new_image_uri: String[256]

@deploy
def __init__(
    registry: address,
    starting_attribute: String[256],
    starting_description: String[1024],
    image_uri: String[256]
):
    """
    @notice Contract constructor
    @param registry The address of the CTF registry
    @param starting_attribute Initial attribute string
    @param starting_description Initial description string
    @param image_uri Initial image URI
    """
    ownable.__init__()

    assert registry != empty(address), "Registry address cannot be empty"
    
    REGISTRY = i_ctf_registry(registry)
    self.attribute = starting_attribute
    self.description = starting_description
    self.image_uri = image_uri

@external
def admin_mint_solvers(solvers: DynArray[address, 100]):
    """
    @notice Allows admin to mint for solvers from past challenges
    @param solvers Array of solver addresses
    """
    ownable._check_owner()
    
    for solver: address in solvers:
        extcall REGISTRY.mintNft(solver, "")

@internal
def _update_and_reward_solver(twitter_handle: String[100]):
    """
    @notice Internal function to mint NFT for solver
    @param twitter_handle Twitter handle of the solver
    """
    extcall REGISTRY.mintNft(msg.sender, twitter_handle)

@external
def change_attribute(new_attribute: String[256]):
    """
    @notice Changes the attribute of the challenge
    @param new_attribute New attribute string
    """
    ownable._check_owner()
    
    log AttributeChanged(new_attribute)
    self.attribute = new_attribute

@external
def change_description(new_description: String[1024]):
    """
    @notice Changes the description of the challenge
    @param new_description New description string
    """
    ownable._check_owner()
    
    log DescriptionChanged(new_description)
    self.description = new_description

@external
def change_image(new_image_uri: String[256]):
    """
    @notice Changes the special image of the challenge
    @param new_image_uri New image URI
    """
    ownable._check_owner()
    
    log ImageUriChanged(new_image_uri)
    self.image_uri = new_image_uri

@external 
@view 
def imageUri() -> String[256]:
    return self.image_uri


# No overrides in Vyper
# @external
# @view
# def extra_description(user: address) -> String[1024]:
#     """
#     @notice Gets extra description for a specific user
#     @param user Address to get description for
#     @return Empty string by default
#     """
#     return ""

# Note: The main solve_challenge function should be implemented by inheriting contracts