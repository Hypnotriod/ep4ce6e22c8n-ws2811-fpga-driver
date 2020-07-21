# ep4ce6e22c8n-ws2811-fpga-driver

FPGA driver application for `WS2811` designed with `SystemVerilog HDL` for `Cyclone IV` `EP4CE6E22C8N` model.  
Used `M9K` embedded memory blocks of `Cyclone IV` family, configured as ROM, to store color patterns.  
The `rom.mif` file of color patterns can be generated with `gradient_generator.js` script by running it with `Node.JS`  

## Hardware:  
* `EasyFPGA A2.2` board [documentation](https://forum.maxiol.com/lofiversion/index.php/t5332.html)
* `WS2811` based 50x RGB LED string from [aliexpress](https://www.aliexpress.com/item/32788470822.html)
