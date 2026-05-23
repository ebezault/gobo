# Validity VYCP-4

This [test](.) is exercising the condition [4](../Readme.md) of the validity rule [VYCP](../../vycp/Readme.md).

### Description

In this test, class `BB` declares two conversion procedures of the form `f ({CC})`
and `f ({DD})`, and the two convert types don't have the same base class.
In this test `VYCP-4` is not violated.

### Notes

* ISE Eiffel (as of 25.12.9.8922 and after) reports a violation of validity rule
  `VNCP`, complaining that it is not allowed to have to conversion procedures with
  the same name. This is not forbidden by the standard, and it is equivalent to
  `f ({CC, DD})`.
  