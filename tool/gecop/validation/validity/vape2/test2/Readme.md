# Validity VAPE-2

This test is exercising the condition 2 of the validity rule [VAPE](..).

### Description

In this test, feature `f` is exported to `ANY`. It has a creation expression in its precondition, but the implicit associated creation procedure `default_create` is only available to `AA`. This violates `VAPE-2`.

### Notes

* ISE Eiffel (as of 18.11.10.2592 and above) fails to report this validity rule violation.