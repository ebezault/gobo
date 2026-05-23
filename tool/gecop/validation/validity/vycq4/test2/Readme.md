# Validity VYCQ-4

This [test](.) is exercising the condition [4](../Readme.md) of the validity rule [VYCQ](../../vycq/Readme.md).

### Description

In this test, class `BB` declares two conversion queries of the form `f: {CC [INTEGER]}`
and `g: {CC [STRING]}`, but the two convert types have the same base class. This violates
`VYCQ-4`.

### Notes

* ISE Eiffel (as of 25.12.9.8922 and after) does not report this validity error.
  This is case there is no ambiguity, but it is forbidden by the standard.
  