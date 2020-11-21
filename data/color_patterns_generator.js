fs = require("fs");

const MODE_REPEAT = "repeat";
const MODE_STRETCH = "stretch";
const MODE_GRADIENT_STRETCH = "gradient-stretch";

const ROM_FILE_NAME = "rom.mif";
const COLORS_NUM = 128;
const COLORS_PATTERNS = [{
		mode: MODE_GRADIENT_STRETCH,
		colors: [
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
			0xff0000,
		]
	}, {
		mode: MODE_STRETCH,
		colors: [
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
		]
	}, {
		mode: MODE_REPEAT,
		colors: [
			0xff0000,
			0xff0000,
			0xff0000,
			0xff0000,
			0xff0000,
			0xff0000,
			0xff0000,
			0xffffff,
			0xff00ff,
			0xff00ff,
			0xff00ff,
			0xff00ff,
			0xff00ff,
			0xff00ff,
			0xff00ff,
			0xffffff,
			0x0000ff,
			0x0000ff,
			0x0000ff,
			0x0000ff,
			0x0000ff,
			0x0000ff,
			0x0000ff,
			0xffffff,
			0xff00ff,
			0xff00ff,
			0xff00ff,
			0xff00ff,
			0xff00ff,
			0xff00ff,
			0xff00ff,
			0xffffff,
			0xffff00,
			0xffff00,
			0xffff00,
			0xffff00,
			0xffff00,
			0xffff00,
			0xffff00,
			0xffffff,
			0x00ffff,
			0x00ffff,
			0x00ffff,
			0x00ffff,
			0x00ffff,
			0x00ffff,
			0x00ffff,
			0xffffff,
			0x00ff00,
			0x00ff00,
			0x00ff00,
			0x00ff00,
			0x00ff00,
			0x00ff00,
			0x00ff00,
			0xffffff,
		]
	}, {
		mode: MODE_REPEAT,
		colors: [
			0xff0000,
			0xff0000,
			0x00ff00,
			0x00ff00,
			0xffff00,
			0xffff00,
			0xff0000,
			0xff0000,
			0xff0000,
			0x00ff00,
			0x00ff00,
			0x00ff00,
			0xffff00,
			0xffff00,
			0xffff00,
			0xff00ff,
			0xff00ff,
			0xff00ff,
			0xff00ff,
			0x00ff00,
			0x00ff00,
			0x00ff00,
			0x00ff00,
			0xffff00,
			0xffff00,
			0xffff00,
			0xffff00,
		]
	}
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
	result += "DEPTH = " + (COLORS_NUM * COLORS_PATTERNS.length) + ";                   -- The size of memory in words\n";
	result += "ADDRESS_RADIX = HEX;          -- The radix for address values\n";
	result += "DATA_RADIX = HEX;             -- The radix for data values\n";
	result += "CONTENT                       -- start of (address : data pairs)\n";
	result += "BEGIN\n";
	
	let red;
	let green;
	let blue;
	
	for (let pattern of COLORS_PATTERNS) {
		for (let i = 0; i < COLORS_NUM; i++) {
			if (pattern.mode === MODE_GRADIENT_STRETCH) {
				let index = i * (pattern.colors.length - 1) / COLORS_NUM;
				let colorA = pattern.colors[Math.floor(index)];
				let colorB = pattern.colors[Math.floor(index) + 1];
				let colorBValue = index % 1;
				let colorAValue = 1 - colorBValue;

				red = Math.round(getRed(colorA) * colorAValue + getRed(colorB) * colorBValue);
				green = Math.round(getGreen(colorA) * colorAValue + getGreen(colorB) * colorBValue);
				blue = Math.round(getBlue(colorA) * colorAValue + getBlue(colorB) * colorBValue);
			} else if (pattern.mode === MODE_STRETCH) {
				let index = Math.floor(i * pattern.colors.length / COLORS_NUM);
				let color = pattern.colors[index];

				red = getRed(color);
				green = getGreen(color);
				blue = getBlue(color);
			} else if (pattern.mode === MODE_REPEAT) {
				let index = i % pattern.colors.length;
				let color = pattern.colors[index];

				red = getRed(color);
				green = getGreen(color);
				blue = getBlue(color);
			}
			
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

try {
	fs.writeFileSync(ROM_FILE_NAME, generate());
	console.log("Success");
} catch (err) {
	console.log("Failed\n", err);
}
