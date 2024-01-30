# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2024, Kendrick Shaw

import pytest

from destine.util import sh


def test_sh():
    assert sh("echo foo") == "foo\n"
    assert sh("printf foo") == "foo"
    with pytest.raises(RuntimeError, match="Command failed - return code 2"):
        sh("exit 2")
