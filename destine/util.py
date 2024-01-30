""" Utility functions
"""

import json
import subprocess


def sh(cmd):
    """run a shell command.

    This is a convenience function for running a shell command from python and
    capturing the resulting output as a return value. It's a light-weight
    wrapper around subproccess.run designed to provide a simple syntax for a
    common use-case. For example:

    >>> sh("ls Mak*").strip()
    'Makefile'

    """
    result = subprocess.run(cmd, shell=True, capture_output=True)
    if result.returncode != 0:
        raise RuntimeError(f"Command failed - return code {result.returncode}")
    else:
        return str(result.stdout, encoding="utf-8")


def pretty(obj):
    """pretty-print an object as JSON.

    >>> pretty({ 'a': 3, 'b': 4 })
    {
        "a": 3,
        "b": 4
    }

    """
    print(json.dumps(obj, indent=4))
