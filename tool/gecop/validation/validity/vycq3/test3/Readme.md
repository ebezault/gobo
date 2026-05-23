# Validity VYCQ-3

This [test](.) is exercising the condition [3](../Readme.md) of the validity rule [VYCQ](../../vycq/Readme.md).

### Description

In this test, class `BB` declares a conversion query of the form `f: {CC [INTEGER]}`
but `CC` is a conforming ancestor of `BB`. This violates `VYCQ-3`.

### Notes

* ISE Eiffel (as of 25.12.9.8922 and after) does not report this validity error.
  Note that in this is case there is no ambiguity because there is no generic
  derivation of `BB` which conforms to `CC [INTEGER]`.
