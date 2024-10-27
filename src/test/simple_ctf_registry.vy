"""
@ version 0.4.0
@ title simple_ctf_registry
"""

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

