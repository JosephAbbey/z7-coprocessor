#include "sleep.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "xil_types.h"
#include "xparameters.h"

// Get devices from xparameters.h
#define BTNS_BASEADDR XPAR_AXI_GPIO_BTNS_BASEADDR
#define LEDS_BASEADDR XPAR_AXI_GPIO_LEDS_BASEADDR
#define SWS_BASEADDR XPAR_AXI_GPIO_SWS_BASEADDR
#define BTN_MASK 0b1111
#define LEDS_MASK 0b1111
#define SWS_MASK 0b1111

#define OPPERATION_A 0
#define OPPERATION_B 4
#define OPPERATION_O 8

// #define ADDER_BASEADDR XPAR_INTEGER_ADDER_0_BASEADDR
// #define ADDER_BASEADDR_A ADDER_BASEADDR + OPPERATION_A
// #define ADDER_BASEADDR_B ADDER_BASEADDR + OPPERATION_B
// #define ADDER_BASEADDR_O ADDER_BASEADDR + OPPERATION_O

#define FLOAT_ADDER_BASEADDR XPAR_FLOAT_ADDER_0_BASEADDR
#define FLOAT_ADDER_BASEADDR_A FLOAT_ADDER_BASEADDR + OPPERATION_A
#define FLOAT_ADDER_BASEADDR_B FLOAT_ADDER_BASEADDR + OPPERATION_B
#define FLOAT_ADDER_BASEADDR_O FLOAT_ADDER_BASEADDR + OPPERATION_O

#define FLOAT_MULTIPLIER_BASEADDR XPAR_FLOAT_MULTIPLIER_0_BASEADDR
#define FLOAT_MULTIPLIER_BASEADDR_A FLOAT_MULTIPLIER_BASEADDR + OPPERATION_A
#define FLOAT_MULTIPLIER_BASEADDR_B FLOAT_MULTIPLIER_BASEADDR + OPPERATION_B
#define FLOAT_MULTIPLIER_BASEADDR_O FLOAT_MULTIPLIER_BASEADDR + OPPERATION_O

#define FLOAT_DIVIDER_BASEADDR XPAR_FLOAT_DIVIDER_0_BASEADDR
#define FLOAT_DIVIDER_BASEADDR_A FLOAT_DIVIDER_BASEADDR + OPPERATION_A
#define FLOAT_DIVIDER_BASEADDR_B FLOAT_DIVIDER_BASEADDR + OPPERATION_B
#define FLOAT_DIVIDER_BASEADDR_O FLOAT_DIVIDER_BASEADDR + OPPERATION_O

#define FLOAT_SQRT_BASEADDR XPAR_FLOAT_SQRT_0_BASEADDR
#define FLOAT_SQRT_BASEADDR_A FLOAT_SQRT_BASEADDR + OPPERATION_A
#define FLOAT_SQRT_BASEADDR_O FLOAT_SQRT_BASEADDR + OPPERATION_O

#define FLOAT_RANDOM_BASEADDR XPAR_FLOAT_RANDOM_0_BASEADDR
#define FLOAT_RANDOM_BASEADDR_O FLOAT_RANDOM_BASEADDR + OPPERATION_O

union int_float {
  u32 i;
  float f;
};
#define to_bits(x) ((union int_float){.f = x}.i)
#define to_float(x) ((union int_float){.i = x}.f)

int main() {
  xil_printf("\r\n");
  xil_printf("\r\n");
  xil_printf("\r\n");
  xil_printf("\r\n");

  // u32 a = 11;
  // u32 b = 10;

  // Xil_Out32(ADDER_BASEADDR_A, a);
  // Xil_Out32(ADDER_BASEADDR_B, b);

  // while (1) {
  //     xil_printf("A: %x\t", Xil_In32(ADDER_BASEADDR_A));
  //     xil_printf("B: %x\t", Xil_In32(ADDER_BASEADDR_B));
  //     xil_printf("O: %x\t", Xil_In32(ADDER_BASEADDR_O));
  //     xil_printf("BTNS: %x \t", Xil_In32(BTNS_BASEADDR));
  //     xil_printf("SWS: %x \t", Xil_In32(SWS_BASEADDR));
  //     xil_printf("\r\n");

  //     // Xil_Out32(ADDER_BASEADDR_A, Xil_In32(BTNS_BASEADDR));
  //     // Xil_Out32(ADDER_BASEADDR_B, Xil_In32(SWS_BASEADDR));

  //     Xil_Out32(LEDS_BASEADDR, Xil_In32(ADDER_BASEADDR_O) & LEDS_MASK);

  //     usleep(10000);
  // }

  float a = 2.0f;
  float b = 3.0f;

  xil_printf("##########################################################\r\n");
  xil_printf("#\r\n");
  xil_printf("# ADDER: \r\n");
  xil_printf("#\r\n");
  xil_printf("##########################################################\r\n");
  xil_printf("\r\n");

  xil_printf("On ARM:\r\n");
  xil_printf("A: %x\t", to_bits(a));
  xil_printf("B: %x\t", to_bits(b));
  xil_printf("O: %x\t", to_bits(a + b));
  xil_printf("\r\n");

  Xil_Out32(FLOAT_ADDER_BASEADDR_A, to_bits(a));
  Xil_Out32(FLOAT_ADDER_BASEADDR_B, to_bits(b));

  xil_printf("On FPGA:\r\n");
  xil_printf("A: %x\t", Xil_In32(FLOAT_ADDER_BASEADDR_A));
  xil_printf("B: %x\t", Xil_In32(FLOAT_ADDER_BASEADDR_B));
  xil_printf("O: %x\t", Xil_In32(FLOAT_ADDER_BASEADDR_O));
  // xil_printf("O: %x\t", to_bits(to_float(Xil_In32(FLOAT_ADDER_BASEADDR_A)) +
  // to_float(Xil_In32(FLOAT_ADDER_BASEADDR_B))));
  xil_printf("\r\n");

  xil_printf("\r\n");
  xil_printf("\r\n");
  xil_printf("\r\n");
  xil_printf("\r\n");
  xil_printf("\r\n");

  xil_printf("##########################################################\r\n");
  xil_printf("#\r\n");
  xil_printf("# MULTIPLIER: \r\n");
  xil_printf("#\r\n");
  xil_printf("##########################################################\r\n");
  xil_printf("\r\n");

  xil_printf("On ARM:\r\n");
  xil_printf("A: %x\t", to_bits(a));
  xil_printf("B: %x\t", to_bits(b));
  xil_printf("O: %x\t", to_bits(a * b));
  xil_printf("\r\n");

  Xil_Out32(FLOAT_MULTIPLIER_BASEADDR_A, to_bits(a));
  Xil_Out32(FLOAT_MULTIPLIER_BASEADDR_B, to_bits(b));

  xil_printf("On FPGA:\r\n");
  xil_printf("A: %x\t", Xil_In32(FLOAT_MULTIPLIER_BASEADDR_A));
  xil_printf("B: %x\t", Xil_In32(FLOAT_MULTIPLIER_BASEADDR_B));
  xil_printf("O: %x\t", Xil_In32(FLOAT_MULTIPLIER_BASEADDR_O));
  xil_printf("\r\n");

  xil_printf("\r\n");
  xil_printf("\r\n");
  xil_printf("\r\n");
  xil_printf("\r\n");
  xil_printf("\r\n");

  xil_printf("##########################################################\r\n");
  xil_printf("#\r\n");
  xil_printf("# DIVIDER: \r\n");
  xil_printf("#\r\n");
  xil_printf("##########################################################\r\n");
  xil_printf("\r\n");

  xil_printf("On ARM:\r\n");
  xil_printf("A: %x\t", to_bits(a));
  xil_printf("B: %x\t", to_bits(b));
  xil_printf("O: %x\t", to_bits(a / b));
  xil_printf("\r\n");

  Xil_Out32(FLOAT_DIVIDER_BASEADDR_A, to_bits(a));
  Xil_Out32(FLOAT_DIVIDER_BASEADDR_B, to_bits(b));

  xil_printf("On FPGA:\r\n");
  xil_printf("A: %x\t", Xil_In32(FLOAT_DIVIDER_BASEADDR_A));
  xil_printf("B: %x\t", Xil_In32(FLOAT_DIVIDER_BASEADDR_B));
  xil_printf("O: %x\t", Xil_In32(FLOAT_DIVIDER_BASEADDR_O));
  xil_printf("\r\n");

  xil_printf("\r\n");
  xil_printf("\r\n");
  xil_printf("\r\n");
  xil_printf("\r\n");
  xil_printf("\r\n");

  xil_printf("##########################################################\r\n");
  xil_printf("#\r\n");
  xil_printf("# SQRT: \r\n");
  xil_printf("#\r\n");
  xil_printf("##########################################################\r\n");
  xil_printf("\r\n");

  Xil_Out32(FLOAT_SQRT_BASEADDR_A, to_bits(a));

  xil_printf("On FPGA:\r\n");
  xil_printf("A: %x\t", Xil_In32(FLOAT_SQRT_BASEADDR_A));
  //   xil_printf("O: %x\t", Xil_In32(FLOAT_SQRT_BASEADDR_O));
  xil_printf("\r\n");

  xil_printf("\r\n");
  xil_printf("\r\n");
  xil_printf("\r\n");
  xil_printf("\r\n");
  xil_printf("\r\n");

  xil_printf("##########################################################\r\n");
  xil_printf("#\r\n");
  xil_printf("# RANDOM: \r\n");
  xil_printf("#\r\n");
  xil_printf("##########################################################\r\n");
  xil_printf("\r\n");

  xil_printf("On FPGA:\r\n");
  xil_printf("O: %x\r\n", Xil_In32(FLOAT_RANDOM_BASEADDR_O));
  xil_printf("O: %x\r\n", Xil_In32(FLOAT_RANDOM_BASEADDR_O));
  xil_printf("O: %x\r\n", Xil_In32(FLOAT_RANDOM_BASEADDR_O));
  xil_printf("O: %x\r\n", Xil_In32(FLOAT_RANDOM_BASEADDR_O));
  xil_printf("O: %x\r\n", Xil_In32(FLOAT_RANDOM_BASEADDR_O));
  xil_printf("O: %x\r\n", Xil_In32(FLOAT_RANDOM_BASEADDR_O));
  xil_printf("O: %x\r\n", Xil_In32(FLOAT_RANDOM_BASEADDR_O));
  xil_printf("O: %x\r\n", Xil_In32(FLOAT_RANDOM_BASEADDR_O));
  xil_printf("O: %x\r\n", Xil_In32(FLOAT_RANDOM_BASEADDR_O));
  xil_printf("O: %x\r\n", Xil_In32(FLOAT_RANDOM_BASEADDR_O));

  xil_printf("\r\n");
  xil_printf("\r\n");
  xil_printf("\r\n");
  xil_printf("\r\n");
  xil_printf("\r\n");

  // for (int i = 0; i < 26000; i++) {
  //     xil_printf("%x\r\n", Xil_In32(FLOAT_RANDOM_BASEADDR_O));
  // }

  // u32 o, ans;
  // float af, bf;
  // for (u32 a = 1; a < 0xffffffff; a++) {
  //     af = to_float(a);
  //     xil_printf("%x\r\n", a);
  //     for (u32 b = 0; b < 0xffffffff; b++) {
  //         bf = to_float(b);
  //         Xil_Out32(FLOAT_ADDER_BASEADDR_A, a);
  //         Xil_Out32(FLOAT_ADDER_BASEADDR_B, b);
  //         o = Xil_In32(FLOAT_ADDER_BASEADDR_O);
  //         ans = to_bits(af + bf);
  //         if (o != ans) {
  //             xil_printf("%x + %x != %x = %x\r\n", a, b, o, ans);
  //         }
  //     }
  // }
  // xil_printf("done");

  xil_printf("##########################################################\r\n");
  xil_printf("#\r\n");
  xil_printf("# Calculate PI: \r\n");
  xil_printf("#\r\n");
  xil_printf("##########################################################\r\n");
  xil_printf("\r\n");

  // Calculate PI using the Leibniz formula:
  // pi = 4 * (1 - 1/3 + 1/5 - 1/7 + 1/9 - ...)
  float pi = 0.0f;
  int sign = 0;
  for (int i = 0; i < 1000000; i++) {
    Xil_Out32(FLOAT_DIVIDER_BASEADDR_A, to_bits(2.0f * i + 1.0f));
    if (sign == 1) {
      sign = 0;
      Xil_Out32(FLOAT_ADDER_BASEADDR_A, to_bits(pi));
      Xil_Out32(FLOAT_ADDER_BASEADDR_B, Xil_In32(FLOAT_DIVIDER_BASEADDR_O));
      pi = to_float(Xil_In32(FLOAT_ADDER_BASEADDR_O));
    } else {
      sign = 1;
      Xil_Out32(FLOAT_ADDER_BASEADDR_A, to_bits(pi));
      Xil_Out32(FLOAT_ADDER_BASEADDR_B, -Xil_In32(FLOAT_DIVIDER_BASEADDR_O));
      pi = to_float(Xil_In32(FLOAT_ADDER_BASEADDR_O));
    }
  }
  Xil_Out32(FLOAT_MULTIPLIER_BASEADDR_A, to_bits(pi));
  Xil_Out32(FLOAT_MULTIPLIER_BASEADDR_B, to_bits(4.0f));
  pi = to_float(Xil_In32(FLOAT_MULTIPLIER_BASEADDR_O));
  xil_printf("Calculated PI (Leibniz): %x\r\n", to_bits(pi));

  // Calculate PI using using circle area method
  // 1. Generate random points in a square of side length 2
  // 2. Count how many points fall inside the circle of radius 1
  // 3. The ratio of points inside the circle to total points is
  //    approximately pi/4
  int inside_circle = 0;
  int total_points = 1000000;  // Number of random points to generate
  for (int i = 0; i < total_points; i++) {
    // Generate random x and y coordinates in the range [-1, 1]
    // x = 2 * rnd - 1;
    Xil_Out32(FLOAT_MULTIPLIER_BASEADDR_A, Xil_In32(FLOAT_RANDOM_BASEADDR_O));
    Xil_Out32(FLOAT_MULTIPLIER_BASEADDR_B, to_bits(2.0f));
    Xil_Out32(FLOAT_ADDER_BASEADDR_A, to_bits(-1.0f));
    Xil_Out32(FLOAT_ADDER_BASEADDR_B, Xil_In32(FLOAT_MULTIPLIER_BASEADDR_O));
    float x = Xil_In32(FLOAT_ADDER_BASEADDR_O);
    // y = 2 * rnd - 1;
    Xil_Out32(FLOAT_MULTIPLIER_BASEADDR_A, Xil_In32(FLOAT_RANDOM_BASEADDR_O));
    Xil_Out32(FLOAT_MULTIPLIER_BASEADDR_B, to_bits(2.0f));
    Xil_Out32(FLOAT_ADDER_BASEADDR_A, to_bits(-1.0f));
    Xil_Out32(FLOAT_ADDER_BASEADDR_B, Xil_In32(FLOAT_MULTIPLIER_BASEADDR_O));
    float y = Xil_In32(FLOAT_ADDER_BASEADDR_O);

    // use sqrt to check if the point is inside the circle
    Xil_Out32(FLOAT_MULTIPLIER_BASEADDR_A, to_bits(x));
    Xil_Out32(FLOAT_MULTIPLIER_BASEADDR_B, to_bits(x));
    Xil_Out32(FLOAT_ADDER_BASEADDR_A, Xil_In32(FLOAT_MULTIPLIER_BASEADDR_O));
    Xil_Out32(FLOAT_MULTIPLIER_BASEADDR_A, to_bits(y));
    Xil_Out32(FLOAT_MULTIPLIER_BASEADDR_B, to_bits(y));
    Xil_Out32(FLOAT_ADDER_BASEADDR_B, Xil_In32(FLOAT_MULTIPLIER_BASEADDR_O));
    // Sqrt is actually completely unnecessary, but I want to use it!
    Xil_Out32(FLOAT_SQRT_BASEADDR_A, Xil_In32(FLOAT_ADDER_BASEADDR_O));
    float distance = to_float(Xil_In32(FLOAT_SQRT_BASEADDR_O));
    // Should use my own comparison at some point
    if (distance <= 1.0f) {
      inside_circle++;
    }
  }
  // Calculate pi using the ratio of points inside the circle to total points
  Xil_Out32(FLOAT_DIVIDER_BASEADDR_A, to_bits(inside_circle));
  Xil_Out32(FLOAT_DIVIDER_BASEADDR_B, to_bits(total_points));
  Xil_Out32(FLOAT_MULTIPLIER_BASEADDR_A, to_bits(4.0f));
  Xil_Out32(FLOAT_MULTIPLIER_BASEADDR_B, Xil_In32(FLOAT_DIVIDER_BASEADDR_O));
  xil_printf("Calculated PI (Circle Area): %x\r\n",
             Xil_In32(FLOAT_MULTIPLIER_BASEADDR_O));

  xil_printf("\r\n");
  xil_printf("\r\n");
  xil_printf("\r\n");
  xil_printf("\r\n");
  xil_printf("\r\n");

  Xil_Out32(LEDS_BASEADDR, 0x1);

  return 0;
}
