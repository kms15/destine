# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2024, Kendrick Shaw

import pytest

import destine


def test_merge_plan():

    # corner cases: merging non-dictionary arguments should just replace the argument
    assert destine.merge_plan({"a": "foo"}, 3) == 3
    assert destine.merge_plan(3, {"a": "foo"}) == {"a": "foo"}

    # should ignore an attempt to delete a missing key
    assert destine.merge_plan({"a": 3}, {"#destine:delete b": 2}) == {"a": 3}
    pass
