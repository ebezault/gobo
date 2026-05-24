# Validity VYCP-7

This [test](.) is exercising the condition [7](../Readme.md) of the validity rule [VYCP](../../vycp/Readme.md).

### Description

In this test, class `BB` declares a conversion procedure of the form `f ({CC})`
but `CC` does not conform to the type of the argument of `f` in class `BB`.
This violates `VYCP-7`.

### Notes

* ISE Eiffel (as of 25.12.9.8922 and after) reports this validity rule violation
  using the code `VNCP`.
  