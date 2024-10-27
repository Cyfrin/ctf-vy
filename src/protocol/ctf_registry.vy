"""
@ pragma version ^0.4.0
@ title ctf_registry
@ author Patrick Collins
@ notice NFT contract for tracking CTF/Challenge completions
@ dev Acts as a hub for the entire CTF system
"""
from src.interfaces import i_challenge
from src.interfaces import i_ctf_registry

from snekmate.utils import base64
from snekmate.auth import ownable as ow
from snekmate.tokens import erc721

initializes: ow
initializes: erc721[ownable := ow]

implements: i_ctf_registry

# ------------------------------------------------------------------
#                            EXPORTS
# ------------------------------------------------------------------
exports: (
    erc721.owner,
    erc721.balanceOf,
    erc721.ownerOf,
    erc721.getApproved,
    erc721.approve,
    erc721.setApprovalForAll,
    erc721.transferFrom,
    erc721.safeTransferFrom,
    # erc721.tokenURI,
    erc721.totalSupply,
    erc721.tokenByIndex,
    erc721.tokenOfOwnerByIndex,
    erc721.burn,
    # erc721.safe_mint,
    # erc721.set_minter,
    erc721.permit,
    erc721.DOMAIN_SEPARATOR,
    erc721.transfer_ownership,
    erc721.renounce_ownership,
    erc721.name,
    erc721.symbol,
    erc721.isApprovedForAll,
    erc721.is_minter,
    erc721.nonces,
)

# ------------------------------------------------------------------
#                        STATE VARIABLES
# ------------------------------------------------------------------
# Immutable & Constant
DEFAULT_ATTRIBUTE: constant(String[32]) = "Getting learned!"
BASE_URI: constant(String[32]) = "data:application/json;base64,"
FINAL_STRING_SIZE: constant(uint256) = (4 * base64._DATA_OUTPUT_BOUND) + 80
BASE_URI_SIZE: constant(uint256) = 29

# Storage
token_id_to_challenge_contract: public(HashMap[uint256, address])
user_to_challenge_to_has_solved: public(
    HashMap[address, HashMap[address, bool]]
)
challenge_contracts: DynArray[address, 1000]  # Max 1000 challenges

# ------------------------------------------------------------------
#                             EVENTS
# ------------------------------------------------------------------
event ChallengeAdded:
    challenge_contract: address


event ChallengeReplaced:
    old_challenge: address
    new_challenge: address


event BaseTokenImageUriChanged:
    new_uri: String[256]


event ChallengeSolved:
    solver: address
    challenge: address
    twitter_handle: String[100]


event OwnershipTransferStarted:
    previous_owner: address
    new_owner: address


# ------------------------------------------------------------------
#                       EXTERNAL FUNCTIONS
# ------------------------------------------------------------------
@deploy
def __init__(
    ctf_name: String[25],
    symbol: String[5],
    name_eip712_: String[50],
    version_eip712_: String[20],
):
    """
    @notice Initialize the contract
    @param ctf_name Name of the CTF
    @param symbol Token symbol
    """
    ow.__init__()
    erc721.__init__(ctf_name, symbol, BASE_URI, name_eip712_, version_eip712_)


@external
def addChallenge(challenge_contract: address) -> address:
    """
    @notice Add a new challenge contract
    @param challenge_contract Address of challenge to add
    """
    ow._check_owner()
    self.challenge_contracts.append(challenge_contract)
    log ChallengeAdded(challenge_contract)
    return challenge_contract


@external
def replace_challenge(challenge_index: uint256, new_challenge: address):
    """
    @notice Replace an existing challenge
    @param challenge_index Index of challenge to replace
    @param new_challenge Address of new challenge
    """
    ow._check_owner()
    old_challenge: address = self.challenge_contracts[challenge_index]
    self.challenge_contracts[challenge_index] = new_challenge
    log ChallengeReplaced(old_challenge, new_challenge)


@external
def mintNft(receiver: address, twitter_handle: String[100]) -> uint256:
    """
    @notice Mint NFT for completing challenge
    @param receiver Address to receive NFT
    @param twitter_handle Twitter handle of solver
    """
    assert self._is_challenge_contract(msg.sender), "Not a challenge contract"
    # fmt: off
    assert not self.user_to_challenge_to_has_solved[receiver][msg.sender], "You already solved this!" 
    # fmt: on

    token_id: uint256 = erc721._counter
    erc721._counter = token_id + 1

    self.token_id_to_challenge_contract[token_id] = msg.sender
    self.user_to_challenge_to_has_solved[receiver][msg.sender] = True

    log ChallengeSolved(receiver, msg.sender, twitter_handle)

    erc721._safe_mint(receiver, token_id, b"")
    return token_id


# ------------------------------------------------------------------
#                     EXTERNAL VIEW AND PURE
# ------------------------------------------------------------------
@external
@view
def tokenURI(token_id: uint256) -> String[FINAL_STRING_SIZE]:
    """
    @notice Get token URI for NFT
    @param token_id ID of token
    """
    challenge: address = self.token_id_to_challenge_contract[token_id]
    if challenge == empty(address):
        return "Not a challenge token"

    challenge_contract: i_challenge = i_challenge(challenge)

    # Get token attributes
    image_uri: String[256] = staticcall challenge_contract.imageUri()
    attribute: String[256] = staticcall challenge_contract.attribute()
    if len(attribute) < 1:
        attribute = DEFAULT_ATTRIBUTE

    owner: address = erc721._owner_of(token_id)
    description: String[1024] = staticcall challenge_contract.description()
    extra_description: String[
        1024
    ] = staticcall challenge_contract.extraDescription(owner)

    # Build JSON metadata
    json_string: String[2677] = concat(
        '{"name":"',
        erc721.name,
        '", "description": "',
        description,
        extra_description,
        '", "attributes": [{"trait_type": "',
        attribute,
        '", "value": 100}], "image":"',
        image_uri,
        '"}',
    )
    json_bytes: Bytes[1024] = convert(json_string, Bytes[1024])
    encoded_chunks: DynArray[
        String[4], base64._DATA_OUTPUT_BOUND
    ] = base64._encode(json_bytes, True)

    result: String[FINAL_STRING_SIZE] = BASE_URI

    counter: uint256 = BASE_URI_SIZE
    for encoded_chunk: String[4] in encoded_chunks:
        result = self.set_indice_truncated(result, counter, encoded_chunk)
        counter += 4
    return result


@external
@view
def get_token_counter() -> uint256:
    return erc721._counter


@external
@view
def get_challenge_contract(index: uint256) -> address:
    return self.challenge_contracts[index]


@external
@view
def is_challenge_contract(contract_address: address) -> bool:
    return self._is_challenge_contract(contract_address)


@external
@view
def get_challenge_contract_full_description(token_id: uint256) -> String[2048]:
    challenge: address = self.token_id_to_challenge_contract[token_id]
    challenge_contract: i_challenge = i_challenge(challenge)
    owner: address = erc721._owner_of(token_id)
    description: String[1024] = staticcall challenge_contract.description()
    extra_description: String[
        1024
    ] = staticcall challenge_contract.extraDescription(owner)
    return concat(description, extra_description)


# ------------------------------------------------------------------
#                       INTERNAL FUNCTIONS
# ------------------------------------------------------------------
@internal
@view
def _is_challenge_contract(contract_address: address) -> bool:
    """
    @notice Check if address is a registered challenge
    @param contract_address Address to check
    """
    for challenge: address in self.challenge_contracts:
        if challenge == contract_address:
            return True
    return False


@internal
@pure
def set_indice_truncated(
    result: String[FINAL_STRING_SIZE], index: uint256, chunk_to_set: String[4]
) -> String[FINAL_STRING_SIZE]:
    """
    We set the index of a string, while truncating all values after the index
    """
    buffer: String[FINAL_STRING_SIZE * 2] = concat(
        slice(result, 0, index), chunk_to_set
    )
    return abi_decode(abi_encode(buffer), (String[FINAL_STRING_SIZE]))
