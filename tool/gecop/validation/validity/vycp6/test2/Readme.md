# Validity VYCP-6

This [test](.) is exercising the condition [6](../Readme.md) of the validity rule [VYCP](../../vycp/Readme.md).

### Description

In this test, class `BB` declares a conversion procedure of the form `f ({CC})`
but `f` is the final name of a creation procedure in `BB` with two arguments.
This violates `VYCP-6`.

### Notes

* ISE Eiffel (as of 25.12.9.8922 and after) reports this validity rule violation
  using the code `VNCP`.
  