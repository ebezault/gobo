# Validity VUAR-4G

This [test](.) is exercising the condition [4G](../Readme.md) of the validity rule [VUAR](../../vuar/Readme.md).

### Description

In this test, there is a separate call to the procedure `f` from class `CC`. The type `DD [G]` of the actual argument of `f` is expanded, but it contains an attribute `name` whose type `detachable G`. The actual generic type may be a non-separate reference type (`STRING` in this test). This violates `VUAR-4G`.

### Notes

* ISE Eiffel (as of 23.09.10.7341 and after) fails to report this validity rule violation, resulting in a type issue where a `STRING` from another SCOOP region is not flagged as separate.

* Gobo Eiffel reports a validity error `V1EA-1G` instead. This is because the issue of having non-separate reference attributes in expanded classes is more general than just this particular case.
