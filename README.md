# ep4ce6e22c8n-ws2811-fpga-driver

FPGA driver application for `WS2811` designed with `SystemVerilog HDL` for `Cyclone IV` `EP4CE6E22C8N` model.  
Used `M9K` embedded memory blocks of `Cyclone IV` family, configured as ROM, to store color patterns.  
The `rom.mif` file of color patterns can be generated with `gradient_generator.js` script by running it with `Node.JS`  
Implemented `NEC Infrared Transmission Protocol` receiver, to switch color patterns by receiving commands from the remote control through the built-in IR receiver.  

## Hardware:  
* `EasyFPGA A2.2` board [documentation](https://forum.maxiol.com/lofiversion/index.php/t5332.html)
* `WS2811` based 50x RGB LED string from [aliexpress](https://www.aliexpress.com/item/32788470822.html)
* Car MP3 `SE-020401` Infrared (IR) remote control [scan codes and specification](https://gist.github.com/steakknife/e419241095f1272ee60f5174f7759867)

## Connection:  
* IR in -> PIN_100
* WS2811 out -> PIN_105
