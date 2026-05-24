# Validity VYCP-4

This [test](.) is exercising the condition [4](../Readme.md) of the validity rule [VYCP](../../vycp/Readme.md).

### Description

In this test, class `BB [G]` declares two conversion procedures of the form `f ({CC [INTEGER]})`
and `g ({CC [G]})`, but the two convert types have the same base class. This violates
`VYCP-4`.

### Notes

* ISE Eiffel (as of 25.12.9.8922 and after) does not report this validity error.
  But for `BB [INTEGER]` there is an ambiguity between `f` and `g`.
  