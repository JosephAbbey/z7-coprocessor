<!-- --------------------------------------------------------------------------------- -->
<!--  Distributed under MIT Licence -->
<!--    See https://github.com/josephabbey/z7-coprocessor/blob/main/LICENCE. -->
<!-- --------------------------------------------------------------------------------- -->

# Floats in Vitis

Vitis supports floating-point operations, but there are some considerations to keep in mind. Vitis has its own version of printf which does not support floating-point numbers. You can get around this by printing a hexadecimal representation of the floating-point number.

```c
union int_float { u32 i; float f; };
#define to_bits(x) ((union int_float){ .f = x }.i)
#define to_float(x) ((union int_float){ .i = x }.f)

printf("0x%08x\n", to_bits(my_float));
```
