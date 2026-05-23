# Validity VYCQ-9

This [test](.) is exercising the condition [9](../Readme.md) of the validity rule [VYCQ](../../vycq/Readme.md).

### Description

In this test, class `BB` declares a conversion query of the form `f: {detachable CC}`
with a convert type which is not attached. This violates `VYCQ-9`.

### Notes

* ISE Eiffel (as of 25.12.9.8922 and after) reports this validity rule violation
  using the code `VNCP`.
  