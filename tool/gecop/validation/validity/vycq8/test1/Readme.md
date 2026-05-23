# Validity VYCQ-8

This [test](.) is exercising the condition [8](../Readme.md) of the validity rule [VYCQ](../../vycq/Readme.md).

### Description

In this test, class `BB` declares a conversion query of the form `f: {like c}`
but the type contains an anchored type. This violates `VYCQ-8`.

### Notes

* ISE Eiffel (as of 25.12.9.8922 and after) reports this validity rule violation
  using the code `VNCP`.
  