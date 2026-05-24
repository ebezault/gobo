# Validity VYCQ-4

This [test](.) is exercising the condition [4](../Readme.md) of the validity rule [VYCQ](../../vycq/Readme.md).

### Description

In this test, class `BB` declares two conversion queries of the form `f: {CC}`
and `g: {CC}`, but the two convert types have the same base class. This violates
`VYCQ-4`.

### Notes

* ISE Eiffel (as of 25.12.9.8922 and after) reports this validity rule violation
  using the code `VNCP`.
  