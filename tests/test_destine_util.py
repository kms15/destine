# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2024, Kendrick Shaw

import unittest

from destine.util import sh


class TestDestineUtils(unittest.TestCase):

    def test_sh(self):
        assert sh("echo foo") == "foo\n"
        assert sh("printf foo") == "foo"
        try:
            sh("exit 2")
            assert False  # unreached
        except RuntimeError as e:
            assert str(e) == "Command failed - return code 2"
