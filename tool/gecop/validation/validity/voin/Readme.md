# Validity VOIN

These [tests](.) are exercising the validity rule below.

## VOIN: Interval rule

### ECMA 367-2, 8.17.11 page 98

An *Interval* is valid if and only if its unfolded form is not empty.

### ECMA 367-3 (working version 115), 8.22.11 page 214

Same as above.

### Notes

* If one of the bound is a Unique attribute and the other bound is
  not a Unique attribute declared (or redeclared) in the same class,
  then the unfolded form of the interval is empty, which violates
  this validity rule.
  
  Unique attributes were described in ETL2, but have not been kept
  in the ECMA Eiffel standard.
