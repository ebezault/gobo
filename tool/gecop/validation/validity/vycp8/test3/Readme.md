# Validity VYCP-8

This [test](.) is exercising the condition [8](../Readme.md) of the validity rule [VYCP](../../vycp/Readme.md).

### Description

In this test, class `BB` declares a conversion procedure of the form `f ({G})`
where `G` is a formal generic parameter. This violates `VYCP-8`.

### Notes

* ISE Eiffel (as of 25.12.9.8922 and after) does not report this validity error,
  ending up with an ambiguous behavior with `CC` which both conforms and
  converts to `BB [CC]`.
  