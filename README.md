# FPG-8
FPG-8 is an implementation of Chip-8/S-Chip language for FPGAs using Verilog.

It was developed as a project for the [ECE-574] course at [Worcester Polytechnic Institute].

It definitelly is not the fastest or more optimized implementation, but it works pretty well.

It was written for the [Nexys 3] board, but should work well on other boards.

All the interaction with the system is done through the USB serial port and the game output is shown on a VGA display. Sound is generated using the [Digilent DA1 Module] connected to pins 1-6 of the PmodA port of the Nexys 3.

### Binaries
If you don't care about all the nerdy stuff in the following sections, you can simply download the [binaries]. The binary distribution contains the Java application compiled in a JAR file and a bit file to program your board using, for example, [Adept].

### Verilog and C code
The complete Verilog code is available under the **verilog** folder. It was developed using the ISE tools from Xilinx. It uses some cores from the IP Core Generator, specially the [Microblaze] microcontroller that handles the serial communication.

The Microblaze is programmed in C and the source is available under the **c** folder. [Here]'s an excelent tutorial about how to merge the C code into the bit file before programming the FPGA.

### Java code
It's impossible to play games typing commands to a serial port, so I wrote a Java application that uses the serial port to load the games, capture user input and also control the debugger. The complete code is under the **java** folder. It uses Maven to handle dependencies, except for the [SteelCheckbox], that is not available on the Maven Repository.

The application searches for games under the **games** folder on the application's directory. Games are stored in a ZIP file containing a `rom.ch8` file that is the Chip-8 ROM, a `logo.png` file that contains a 80x80 picture that is shown on the menu on the left, a `screenshot.png` file that contains a 510x253 picture that is shown on the center when the came is selected and a `description.json` file that contains some information about the game in [JSON] format. The `slowdown` should not be greater than 65535, because it's a 16-bit number. The `mapping` parameter maps the Chip-8 keyboard to your keyboard. Any letter is valid and also the special values `arrow-up`, `arrow-down`, `arrow-left`, `arrow-right`, `ctrl`, `alt`, `shift`, `enter` and `space`.

After days of Verilog development, I really wanted to play some games, so this application was written very fastly. It can't handle board disconnections, permission errors or any other thing your evil mind can think of.

### ASM code
I included the source for a simple application I wrote to test some opcodes of my implementation. It's available under the **asm** folder. It can be assembled by the [Mochi8 Assembler].

There is also a program that writes "Thank You!" on the screen, that I used in the end of the project presentation.

### Docs
Under the **docs** folder there are the slides I used for the presentation of this project.

There is also the project report that describes the implementation in details. Section 2 of the report summarizes all the information I could find about the Chip-8 on the web and can be used as a documentation for your own implementation.

### Miscelaneous
Under the **misc** folder you can find a OpenOffice Calc spreadsheet that I created to help me drawing the font for the "Thank You" program.

### Acknowledgements
I'd like to thank **Professor R. James Duckworth** for the great VHDL/Verilog course and the opportunity to develop this project and **Boyang Li** for being a great TA.

[binaries]: https://github.com/guimeira/fpg8/releases
[Adept]: http://www.digilentinc.com/Products/Detail.cfm?NavPath=2,66,69&Prod=ADEPT&CFID=6114451&CFTOKEN=b4315c79c33731b4-0CDF65D2-5056-0201-0284F3BE6330CA60
[ECE-574]: http://ece.wpi.edu/~rjduck/ece574.htm
[Worcester Polytechnic Institute]: http://www.wpi.edu
[Nexys 3]: http://www.digilentinc.com/Products/Detail.cfm?NavPath=2,400,897&Prod=NEXYS3
[Digilent DA1 Module]: http://www.digilentinc.com/Products/Detail.cfm?Prod=PMOD-DA1
[Microblaze]: http://www.xilinx.com/tools/microblaze.htm
[Here]: http://ece.wpi.edu/~rjduck/Microblaze%20MCS%20Tutorial%20v5.pdf
[SteelCheckbox]: http://harmoniccode.blogspot.com/2010/11/friday-fun-component-iii.html
[JSON]: http://json.org/
[Mochi8 Assembler]: http://mochi8.weebly.com/