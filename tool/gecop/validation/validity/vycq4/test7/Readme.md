# Validity VYCQ-4

This [test](.) is exercising the condition [4](../Readme.md) of the validity rule [VYCQ](../../vycq/Readme.md).

### Description

In this test, class `BB` declares a conversion query of the form `f: {CC}`
and a conversion procedure of the form `g ({CC})`. In this test `VYCQ-4` is
not violated, even though the convert type `CC` is declared twice, because
it is declared in only one conversion query.
  