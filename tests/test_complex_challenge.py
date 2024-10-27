import boa


def test_can_mint_once(registry, complex_challenge):
    # Add challenge to registry
    registry.addChallenge(complex_challenge.address)

    # Solve challenge
    complex_challenge.solve_challenge()

    # Check NFT was minted
    assert registry.balanceOf(boa.env.eoa) == 1


def test_can_only_mint_once(registry, complex_challenge):
    # Add challenge to registry
    registry.addChallenge(complex_challenge.address)

    # First solve should work
    complex_challenge.solve_challenge()

    # Second solve should fail
    with boa.reverts("Already minted"):
        complex_challenge.solve_challenge()


def test_owner_can_change_attribute(registry, complex_challenge):
    new_attribute = "new attribute"
    complex_challenge.change_attribute(new_attribute)
    assert complex_challenge.attribute() == new_attribute


def test_non_owner_cannot_change_attribute(registry, complex_challenge, random_account):
    with boa.env.prank(random_account.address):
        with boa.reverts():
            complex_challenge.change_attribute("new attribute")


def test_change_description(registry, complex_challenge):
    new_description = "New challenge description"
    with boa.env.prank(registry.owner()):
        complex_challenge.change_description(new_description)
        assert complex_challenge.description() == new_description
