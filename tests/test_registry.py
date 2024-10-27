import boa

from src.test import simple_ctf_challenge


def test_add_challenge_adds_challenge(registry_with_challenge, challenge):
    assert registry_with_challenge.is_challenge_contract(challenge.address) is True


def test_replace_challenge(registry_with_challenge, challenge):
    new_challenge = simple_ctf_challenge.deploy(registry_with_challenge.address)
    registry_with_challenge.replace_challenge(0, new_challenge.address)

    assert registry_with_challenge.is_challenge_contract(new_challenge.address) is True
    assert registry_with_challenge.is_challenge_contract(challenge.address) is False


def test_replace_challenge_only_owner(registry_with_challenge, random_account):
    new_challenge = simple_ctf_challenge.deploy(registry_with_challenge.address)
    with boa.env.prank(random_account.address):
        with boa.reverts():
            registry_with_challenge.replace_challenge(0, new_challenge.address)


def test_mint_nft(registry_with_challenge, challenge):
    challenge.solveChallenge()
    assert registry_with_challenge.balanceOf(boa.env.eoa) == 1


def test_user_can_only_mint_once(registry_with_challenge, challenge):
    challenge.solveChallenge()
    with boa.reverts("You already solved this!"):
        challenge.solveChallenge()


def test_get_token_uri(registry_with_challenge, challenge):
    expected_token_uri = "data:application/json;base64,eyJuYW1lIjoiT3VyIENURiIsICJkZXNjcmlwdGlvbiI6ICJUaGlzIGlzIGEgc2ltcGxlIENURiBjaGFsbGVuZ2UuIiwgImF0dHJpYnV0ZXMiOiBbeyJ0cmFpdF90eXBlIjogIkdldHRpbmcgbGVhcm5lZCEiLCAidmFsdWUiOiAxMDB9XSwgImltYWdlIjoiaXBmczovL1FtWmc3OWpkRE5CVGkzZnh3bmpYVHZiTTlHdGQxQzg0QXhvNTVIdDJrWUNlREgifQ=="
    challenge.solveChallenge()
    token_uri = registry_with_challenge.tokenURI(0)
    assert token_uri == expected_token_uri
