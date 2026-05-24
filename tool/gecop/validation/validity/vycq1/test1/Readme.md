# Validity VYCQ-1

This [test](.) is exercising the condition [1](../Readme.md) of the validity rule [VYCQ](../../vycq/Readme.md).

### Description

In this test, class `BB` declares a conversion query of the form `f: {CC}`
but `f` is not the final name of a feature in `BB`. This violates `VYCQ-1`.

### Notes

* ISE Eiffel (as of 25.12.9.8922 and after) reports this validity rule violation
  using the code `VNCP`.
  