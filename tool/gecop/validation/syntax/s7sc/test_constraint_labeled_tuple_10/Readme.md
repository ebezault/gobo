# Syntax S7SC

This [test](.) is exercising the syntax rule [S7SC](../Readme.md).

### Description

In this test, the generic constraint in class `B` is a labeled tuple with no field declaration but a semicolon instead. This is valid according to the *Semicolon Optionality rule* `S7SC`.

### Notes

* ISE Eiffel (as of 24.05.10.7822 and after) erroneously reports a syntax error despite the Semicolon Optionality rule `S7SC`.
