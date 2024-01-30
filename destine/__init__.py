# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2024, Kendrick Shaw

from .util import pretty


def merge_plan(current, additions):
    """merge additions into a plan

    Plans for a deployment are typically split across different configuration
    files that can be combined, for example:

    >>> net_config = { "networks": {
    ...     "net_a": {"MTU": 1500, "qlen": 1000 },
    ...     "net_b": {"MTU": 1550 },
    ... } }
    >>> vm_config = { "machines": { "vm_a": {}, "vm_b": {} } }
    >>> pretty(merge_plan(net_config, vm_config))
    {
        "networks": {
            "net_a": {
                "MTU": 1500,
                "qlen": 1000
            },
            "net_b": {
                "MTU": 1550
            }
        },
        "machines": {
            "vm_a": {},
            "vm_b": {}
        }
    }

    By default keys with the same name that are dictionaries will have their
    contents merged, whereas keys with the same name that are other types will
    have their contents replaced:
    >>> net_config2 = { "networks": {
    ...     "net_a": { "MTU": 9000, "answer": 42 },
    ...     "net_b": { "MTU": 1550 },
    ...     "net_c": { "MTU": 3000 }
    ... } }
    >>> pretty(merge_plan(net_config, net_config2))
    {
        "networks": {
            "net_a": {
                "MTU": 9000,
                "qlen": 1000,
                "answer": 42
            },
            "net_b": {
                "MTU": 1550
            },
            "net_c": {
                "MTU": 3000
            }
        }
    }

    You can force replacement by prepending a "#destine:replace " to the key
    name:
    >>> net_config3 = { "networks": {
    ...     "#destine:replace net_a": { "question": "6 * 7" },
    ...     "net_b": { "answer": 42 },
    ... } }
    >>> pretty(merge_plan(net_config, net_config3))
    {
        "networks": {
            "net_a": {
                "question": "6 * 7"
            },
            "net_b": {
                "MTU": 1550,
                "answer": 42
            }
        }
    }

    In a similar fashion, you can remove an existing key by adding a the
    prefix "#destine:delete ":
    >>> net_config4 = { "networks": { "#destine:delete net_b" : {} } }
    >>> pretty(merge_plan(net_config, net_config4))
    {
        "networks": {
            "net_a": {
                "MTU": 1500,
                "qlen": 1000
            }
        }
    }

    """
    # for everything except for two dictionaries, merging is replacement
    if not isinstance(current, dict) or not isinstance(additions, dict):
        return additions

    result = current.copy()

    for key, value in additions.items():
        if key.startswith("#destine:replace "):
            result[key.removeprefix("#destine:replace ")] = value
        elif key.startswith("#destine:delete "):
            newkey = key.removeprefix("#destine:delete ")
            if newkey in result:
                del result[newkey]
        elif key in current:
            result[key] = merge_plan(current[key], value)
        else:
            result[key] = value
    return result
