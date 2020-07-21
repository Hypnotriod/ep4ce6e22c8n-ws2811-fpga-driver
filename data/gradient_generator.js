fs = require("fs");

let ROM_FILE_NAME = "rom.mif";
let COLORS_NUM = 128;
let COLORS = [0xff0000, 0xff0000, 0xff00ff, 0xff00ff, 0x0000ff, 0x0000ff, 0xFF00FF, 0xFF00FF, 0xFFFF00, 0xFFFF00, 0x00FFFF, 0x00FFFF, 0x00FF00, 0x00FF00, 0xFF0000];

function getRed(color) { return ((color >> 16) & 0xFF) }
function getGreen(color) { return ((color >> 8) & 0xFF) }
function getBlue(color) { return ((color) & 0xFF) }
function toHex(d) { return ("0" + (Number(d).toString(16))).slice(-2).toUpperCase(); }
function generate() {
	let result = "";
	
	result += "WIDTH = 24;                   -- The size of data in bits\n";
	result += "DEPTH = " + COLORS_NUM + ";                   -- The size of memory in words\n";
	result += "ADDRESS_RADIX = HEX;          -- The radix for address values\n";
	result += "DATA_RADIX = HEX;             -- The radix for data values\n";
	result += "CONTENT                       -- start of (address : data pairs)\n";
	result += "BEGIN\n";

	for (let i = 0; i < COLORS_NUM; i++) {
		let index = i * (COLORS.length - 1) / COLORS_NUM;
		let colorA = COLORS[Math.floor(index)];
		let colorB = COLORS[Math.floor(index) + 1];
		let colorBValue = index % 1;
		let colorAValue = 1 - colorBValue;

		let red = Math.round(getRed(colorA) * colorAValue + getRed(colorB) * colorBValue);
		let green = Math.round(getGreen(colorA) * colorAValue + getGreen(colorB) * colorBValue);
		let blue = Math.round(getBlue(colorA) * colorAValue + getBlue(colorB) * colorBValue);
		
		result += 
			toHex(i) + " : " + 
			toHex(red) + 
			toHex(green) + 
			toHex(blue) + ";\n";
	}
	
	result += "END;";
	return result;
}

let romData = generate();
fs.writeFile(ROM_FILE_NAME, romData, (err) => {
	if (err) {
		console.log("Failed");
		console.log(err);
	}
	else {
		console.log("Success");
	}
});
