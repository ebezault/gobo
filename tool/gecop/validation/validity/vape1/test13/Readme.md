# Validity VAPE-1

This test is exercising the condition 1 of the validity rule [VAPE](..).

### Description

In this test, feature `f` is exported to `ANY`. It has an `across` expression in its precondition, but the associated feature `new_cursor` is only available to `AA`. This violates `VAPE-1`.

### Notes

* ISE Eiffel (as of 18.11.10.2592 and above) fails to report this validity rule violation.