import boa
from eth_account import Account


def test_can_solve_challenge(registry_with_challenge, challenge):
    challenge.solveChallenge()
    assert registry_with_challenge.balanceOf(boa.env.eoa) == 1


def test_solve_multiple_challenges(registry, challenge, complex_challenge):
    # Add both challenges to registry
    registry.addChallenge(challenge.address)
    registry.addChallenge(complex_challenge.address)

    # Solve both challenges
    challenge.solveChallenge()
    complex_challenge.solve_challenge()

    assert registry.balanceOf(boa.env.eoa) == 2


def test_admin_mint_solvers(registry_with_challenge, challenge):
    # Create test accounts
    solver1 = Account.create(1234)
    solver2 = Account.create(5678)

    # Create array of solver addresses
    solvers = [solver1.address, solver2.address]

    # Admin mint for solvers
    challenge.admin_mint_solvers(solvers)

    # Verify NFTs were minted
    assert registry_with_challenge.balanceOf(solver1.address) == 1
    assert registry_with_challenge.balanceOf(solver2.address) == 1
