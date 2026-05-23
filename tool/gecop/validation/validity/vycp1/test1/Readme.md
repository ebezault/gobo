# Validity VYCP-1

This [test](.) is exercising the condition [1](../Readme.md) of the validity rule [VYCP](../../vycp/Readme.md).

### Description

In this test, class `BB` declares a conversion procedure of the form `f ({CC})`
but `f` is not the final name of a feature in `BB`. This violates `VYCP-1`.

### Notes

* ISE Eiffel (as of 25.12.9.8922 and after) reports this validity rule violation
  using the code `VNCP`.
  