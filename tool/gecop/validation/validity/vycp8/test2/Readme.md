# Validity VYCP-8

This [test](.) is exercising the condition [8](../Readme.md) of the validity rule [VYCP](../../vycp/Readme.md).

### Description

In this test, class `BB` declares a conversion procedure of the form `f ({CC [like g]})`
but the type contains an anchored type. This violates `VYCP-8`.

### Notes

* ISE Eiffel (as of 25.12.9.8922 and after) reports this validity rule violation
  using the code `VNCP`.
  