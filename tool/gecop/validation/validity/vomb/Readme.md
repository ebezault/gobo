# Validity VOMB

These [tests](.) are exercising the validity rule below.  
Click on the `[tests]` label following the condition numbers below to see tests specific to these conditions.

## VOMB: Multi-branch rule

### ECMA 367-2, 8.17.13 page 98

A *Multi_branch* instruction is valid if and only if its unfolded form satisfies the following conditions.

1. [\[tests\]](../vomb1) Inspect values are all valid.
2. [\[tests\]](../vomb2) Inspect values are all constants.
3. The manifest values of any two inspect values are different.
4. If the inspect expression is of type `TYPE [T]` for some type `T`, all inspect values are types.
5. If case `4` does not apply, the inspect expression is one of the sized variants of
   `INTEGER`, `CHARACTER` or `STRING`.

### ECMA 367-3 (working version 115), 8.22.13 page 214

Same as above.

### Notes

* There is a missing condition:

  6. G. [\[tests\]](../vomb6g) The type of the inspect expression is attached.

  This condition is implemented both in ISE Eiffel (as of 25.12.9.8922 and after)
  and Gobo Eiffel (as of 26.06 and after).

* In the context of once classes, the condition `2` should be adapted to also
  accept values of the form `{C}.f` where `C` is a once class and `f` is one
  of its creation procedures (possibly with actual arguments).

  Once classes are not described in the ECMA Eiffel standard, therefore
  this condition extension is not part of the standard.

* In the context of once classes, another condition is needed (between `4` and `5`):

  7. G. [\[tests\]](../vomb7g) If the base class of the inspect expression is a once class,
     all inspect values as instances of a type with the same base class.

  Once classes are not described in the ECMA Eiffel standard, therefore
  this condition extension is not part of the standard.
