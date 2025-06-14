# ---------------------------------------------------------------------------------
#  Distributed under MIT Licence
#    See https://github.com/josephabbey/z7-coprocessor/blob/main/LICENCE.
# ---------------------------------------------------------------------------------

import matplotlib.pyplot as plt

def ieee745(N): # ieee-745 bits (max 32 bit)
    # print(N)

    a = int(N[0])                                 # sign,     1 bit
    b = int(N[1:9], 2) - 127                      # exponent, 8 bits
    c = float(int("1" + N[9:32], 2)) * (2 ** -23) # mantissa, 1+23 bits

    # print(f"Sign: {N[0]}, Exponent: {N[1:9]}, Mantissa: 1{N[9:32]}")
    # print(f"Sign: {a}, Exponent: {b}, Mantissa: {c}")

    return (-1 if a == 1 else 1) * c * (2 ** b)

with open("./nums.txt", "r") as file:
    hex_nums = [line.strip() for line in file.readlines()]
    # convert hex representation of ieee 754 f32 to decimal
    nums = [ieee745(bin(int(hex_num, 16))[2:].rjust(32, "0")) for hex_num in hex_nums]
    plt.hist(nums, bins=50)
    plt.show()
