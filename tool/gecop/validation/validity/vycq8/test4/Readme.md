# Validity VYCQ-8

This [test](.) is exercising the condition [8](../Readme.md) of the validity rule [VYCQ](../../vycq/Readme.md).

### Description

In this test, class `BB` declares a conversion query of the form `f: {G}`
where `G` is a formal generic parameter. This violates `VYCQ-8`.

### Notes

* ISE Eiffel (as of 25.12.9.8922 and after) does not report this validity error,
  ending up with an ambiguous behavior with `BB [ANY]` which both conforms and
  converts to `ANY`.
  