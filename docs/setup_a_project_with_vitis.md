# Using Vivado and Vitis

## New Project Wizard

1. Click `Next >`.

    ![Create a New Vivado Project](images/01.png)

2. Enter a project name and location. Click `Next >`.

    ![Project Name](images/02.png)

3. Select RTL Project, ensure that `Project is an extensible Vitis Platform` is not selected. Click `Next >`.

    ![Project Type](images/03.png)

4. Select the board that you are building for (this will allow you to use the preset GPIO packages). Click `Next >`.

    ![Default Part](images/04.png)

5. Click `Finish`.

    ![Project Summary](images/05.png)

6. You should now see the Vivado GUI. Click `Create Block Design`.

    ![Project Manager](images/06.png)

7. Click `OK`.

    ![Create Block Design](images/07.png)

8. Click `+`.

    ![Open Block Design](images/08.png)

9. Search for `ZYNQ` and double click on `ZYNQ7 Processing System`.

    ![Add ZYNQ7 Processing System](images/09.png)

10. Click `+` again and search for `AXI GPIO`. Double click on `AXI GPIO`.

    ![Add AXI GPIO](images/10.png)

11. Right click on the AXI GPIO block and click `Customize Block`.

    ![Customize AXI GPIO](images/11.png)

12. Select `leds 4bits` from the drop down menu. Click `OK`.

    ![Customize AXI GPIO 2](images/12.png)

13. Click `Run Block Automation`.

    ![Run Block Automation](images/13.png)

14. Click `OK`.

    ![Run Block Automation 2](images/14.png)

15. Click `Run Connection Automation`. Select `GPIO` and `S_AXI` and click `OK`.

    ![Run Connection Automation](images/15.png)

16. Your block design should now look like this.

    ![Block Design](images/16.png)

17. Click `Generate Block Design`.

    ![Generate Design](images/17.png)

18. Select `Global` and click `Generate`.

    ![Generate Design 2](images/18.png)

19. It is worth noting that you will see some warnings. These can be ignored. Click `OK`.

    ![Warnings](images/19.png)

20. Back in project manager, right click on `design_1` and click `Create HDL Wrapper`.

    ![Create HDL Wrapper](images/20.png)

21. Click `OK`.

    ![Create HDL Wrapper 2](images/21.png)

22. Click `Run Linter`.

23. Click `Run Synthesis`. Then click `OK`.

    ![Run Synthesis](images/23.png)

24. Select `Run Implementation` and click `OK`.

    ![Run Implementation](images/24.png)

25. Click `OK`.

    ![Run Implementation 2](images/25.png)

26. Select `Generate Bitstream` and click `OK`.

    ![Generate Bitstream](images/26.png)

27. Click `OK`.

    ![Generate Bitstream 2](images/27.png)

28. Click `File` -> `Export` -> `Export Hardware`.

    ![Export Hardware](images/28.png)

29. Click `Next >`.

    ![Export Hardware 2](images/29.png)

30. Click `Include Bitstream` and click `Next >`.

    ![Export Hardware 3](images/30.png)

31. Enter a name. Click `Next >`.

    ![Export Hardware 4](images/31.png)

32. Click `Finish`.

    ![Export Hardware 5](images/32.png)

33. Launch Vitis. Click `File` -> `New Component` -> `Platform`.

    ![New Platform](images/33.png)

34. Click `Next`.

    ![New Platform 2](images/34.png)

35. Click `Browse`.

    ![New Platform 3](images/35.png)

36. Navigate to the directory where you exported the hardware. Click `Next`.

    ![New Platform 4](images/36.png)

37. It will load for a minute.

    ![New Platform 5](images/37.png)

38. Click `Next`.

    ![New Platform 6](images/38.png)

39. Click `Finish`.

    ![New Platform 7](images/39.png)

40. Click `Build`.

    ![Build Platform](images/40.png)

41. Click `File` -> `New Component` -> `Application`.

    ![New Application](images/41.png)

42. Click `Next`.

    ![New Application 2](images/42.png)

43. Select your platform component. Click `Next`.

    ![New Application 3](images/43.png)

44. Click `Next`.

    ![New Application 4](images/44.png)

45. Click `Finish`.

    ![New Application 5](images/45.png)

46. Create a new file called `main.c`.

    ![New File](images/46.png)

47. Copy and paste the following code into `main.c`.

    ```c
    #include "xparameters.h"
    #include "sleep.h"
    #include "xil_printf.h"
    #include "xil_types.h"
    #include "xgpio.h"
    #include "xstatus.h"
    #include <xil_io.h>

    // Get device IDs from xparameters.h
    #define LEDS_BASE_ADDRESS XPAR_AXI_GPIO_0_BASEADDR
    #define LEDS_MASK 0b1111

    int main() {
        u32 leds;

        xil_printf("Entered function main\r\n");
        
        leds = 0;
        while (1) {
            sleep(1);
            leds++;
            xil_printf("Writing: %x\r\n", leds & LEDS_MASK);
            Xil_Out32(LEDS_BASE_ADDRESS, leds & LEDS_MASK);
        }
    }
    ```

    ![Main Code](images/47.png)

48. Click `Build`.

    ![Build Application](images/48.png)

49. Set the board jumpers to enable host and boot from JTAG. Connect the board to your computer.

    ![Board Jumpers](images/49.jpg)

50. Click `Run`.

    ![Run Application](images/50.png)

    Now the LEDs on the board should be counting up in binary. You will notice that even though we are logging data in the code, nothing is printed in the debug console (who knows why?), to see the logs, use the serial monitor. Press `F1` and search for `Serial Monitor`, then select the port and use `115200` as the baud rate.

51. Now go back to the block design and add an AXI GPIO for the buttons.

    ![Add AXI GPIO 2](images/51.png)

52. Click `Generate Block Design` again.

53. Click `Generate Bitstream` again.

54. Export the hardware again (you can overwrite the previous .xsa file).

55. In Vitis, update the platform. Open `vitis-comp.json` and click `Switch XSA`. Select your new .xsa file.

    ![Update Platform](images/55.png)

56. Click `Build` in the platform component.

57. Update the application component `main.c` file. Click `Build`. Click `Run`.

    ```c
    #include "xparameters.h"
    #include "sleep.h"
    #include "xil_printf.h"
    #include "xil_types.h"
    #include "xgpio.h"
    #include "xstatus.h"
    #include <xil_io.h>

    // Get device IDs from xparameters.h
    #define LEDS_BASE_ADDRESS XPAR_AXI_GPIO_0_BASEADDR
    #define LEDS_MASK 0b1111
    #define BTNS_BASE_ADDRESS XPAR_AXI_GPIO_1_BASEADDR
    
    int main() {
        u32 leds;
        u32 btns;
    
        xil_printf("Entered function main\r\n");
        
        leds = 0;
        while (1) {
            sleep(1);

            btns = Xil_In32(BTNS_BASE_ADDRESS);
            xil_printf("Reading: %x\r\n", btns);

            leds++;
            xil_printf("Writing: %x\r\n", leds & LEDS_MASK);
            Xil_Out32(LEDS_BASE_ADDRESS, leds & LEDS_MASK);
        }
    }
    ```
