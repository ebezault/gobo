# Validity VYCQ-3

This [test](.) is exercising the condition [3](../Readme.md) of the validity rule [VYCQ](../../vycq/Readme.md).

### Description

In this test, class `BB` declares a conversion query of the form `f: {CC [G]}`
but `CC` is a conforming ancestor of `BB`. This violates `VYCQ-3`.

### Notes

* ISE Eiffel (as of 25.12.9.8922 and after) does not report this validity error,
  ending up with an ambiguous behavior with `BB [INTEGER]` which both conforms and
  converts to `CC [INTEGER]`.
  