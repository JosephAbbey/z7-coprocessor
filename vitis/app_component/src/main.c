#include "xparameters.h"
#include "xil_printf.h"
#include "xil_types.h"
#include "xil_io.h"
#include "sleep.h"


// Get devices from xparameters.h
#define BTNS_BASEADDR XPAR_AXI_GPIO_BTNS_BASEADDR
#define LEDS_BASEADDR XPAR_AXI_GPIO_LEDS_BASEADDR
#define SWS_BASEADDR XPAR_AXI_GPIO_SWS_BASEADDR
#define BTN_MASK 0b1111
#define LEDS_MASK 0b1111
#define SWS_MASK 0b1111

#define ADDER_BASEADDR XPAR_INTEGER_ADDER_0_BASEADDR

#define ADDER_BASEADDR_A XPAR_INTEGER_ADDER_0_BASEADDR
#define ADDER_BASEADDR_B XPAR_INTEGER_ADDER_0_BASEADDR + 4
#define ADDER_BASEADDR_O XPAR_INTEGER_ADDER_0_BASEADDR + 8

#define FLOAT_ADDER_BASEADDR_A XPAR_FLOAT_ADDER_0_BASEADDR
#define FLOAT_ADDER_BASEADDR_B XPAR_FLOAT_ADDER_0_BASEADDR + 4
#define FLOAT_ADDER_BASEADDR_O XPAR_FLOAT_ADDER_0_BASEADDR + 8

union int_float { int i; float f; };
#define to_bits(x) ((union int_float){ .f = x }.i)
#define to_float(x) ((union int_float){ .i = x }.f)

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
    float b = 10.0f;
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
    // xil_printf("O: %x\t", to_bits(to_float(Xil_In32(FLOAT_ADDER_BASEADDR_A)) + to_float(Xil_In32(FLOAT_ADDER_BASEADDR_B))));
    xil_printf("\r\n");
}
