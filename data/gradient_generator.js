fs = require("fs");

const ROM_FILE_NAME = "rom.mif";
const COLORS_NUM = 128;
const COLORS_PATTERNS_NUM = 4;
const COLORS_PATTERNS = [
	[
		0xff0000,
		0xff0000,
		0xff00ff,
		0xff00ff,
		0x0000ff,
		0x0000ff,
		0xff00ff,
		0xff00ff,
		0xffff00,
		0xffff00,
		0x00ffff,
		0x00ffff,
		0x00ff00,
		0x00ff00,
		0xff0000
	],
	[
		0xff0000,
		0xff0000,
		0x00ff00,
		0x00ff00,
		0xff0000,
	],
	[
		0xff00ff,
		0xff00ff,
		0xffff00,
		0xffff00,
		0xff00ff,
		0xff00ff,
		0xffff00,
		0xffff00,
		0xff00ff,
	],
	[
		0xff0000,
		0xff0000,
		0x00ff00,
		0x00ff00,
		0xff0000,
		0xff0000,
		0x00ff00,
		0x00ff00,
		0xff0000,
		0xff0000,
		0x00ff00,
		0x00ff00,
		0xff0000,
		0xff0000,
		0x00ff00,
		0x00ff00,
		0xff0000,
	]
];

function getRed(color) {
	return ((color >> 16) & 0xff)
}
function getGreen(color) {
	return ((color >> 8) & 0xff)
}
function getBlue(color) {
	return ((color) & 0xff)
}
function toHex(d) {
	let result = Number(d).toString(16).toUpperCase();
	return result.length % 2 ? "0" + result : result;
}
function generate() {
	let result = "";
	let byteAddress = 0;

	result += "WIDTH = 24;                   -- The size of data in bits\n";
	result += "DEPTH = " + (COLORS_NUM * COLORS_PATTERNS_NUM) + ";                   -- The size of memory in words\n";
	result += "ADDRESS_RADIX = HEX;          -- The radix for address values\n";
	result += "DATA_RADIX = HEX;             -- The radix for data values\n";
	result += "CONTENT                       -- start of (address : data pairs)\n";
	result += "BEGIN\n";

	for (let colors of COLORS_PATTERNS) {
		for (let i = 0; i < COLORS_NUM; i++) {
			let index = i * (colors.length - 1) / COLORS_NUM;
			let colorA = colors[Math.floor(index)];
			let colorB = colors[Math.floor(index) + 1];
			let colorBValue = index % 1;
			let colorAValue = 1 - colorBValue;

			let red = Math.round(getRed(colorA) * colorAValue + getRed(colorB) * colorBValue);
			let green = Math.round(getGreen(colorA) * colorAValue + getGreen(colorB) * colorBValue);
			let blue = Math.round(getBlue(colorA) * colorAValue + getBlue(colorB) * colorBValue);

			result +=
			toHex(i + byteAddress) + " : " +
			toHex(red) +
			toHex(green) +
			toHex(blue) + ";\n";
		}
		
		byteAddress += COLORS_NUM;
	}
	
	result += "END;";
	return result;
}

fs.writeFile(ROM_FILE_NAME, generate(), (err) => {
	if (err) {
		console.log("Failed");
		console.log(err);
	} else {
		console.log("Success");
	}
});
