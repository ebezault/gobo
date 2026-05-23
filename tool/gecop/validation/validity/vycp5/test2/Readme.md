# Validity VYCP-5

This [test](.) is exercising the condition [5](../Readme.md) of the validity rule [VYCP](../../vycp/Readme.md).

### Description

In this test, class `BB` declares a conversion procedure of the form `f ({CC})`
but `CC` also declares a conversion query of the form `g: {BB [INTEGER]}`.
This violates `VYCP-5`.

### Notes

* ISE Eiffel (as of 25.12.9.8922 and after) reports this validity rule violation
  using the code `VNCP`, and only mentions `CC` and not `BB`.

* Gobo Eiffel also reports the violation of rule `VYCQ-5`
  