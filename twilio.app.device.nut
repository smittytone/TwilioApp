server.setsendtimeoutpolicy(RETURN_ON_ERROR, WAIT_TIL_SENT, 10);

function oud(reason) {
    if (reason != SERVER_CONNECTED) {
        imp.wakeup(30, function() {
            server.connect(oud, 29);
        });
    }
}

server.onunexpecteddisconnect(oud);

/**
 * HT16K33 registers and HT16K33-specific variables
 *
 * @enum
 *
 */
enum HT16K33_MATRIX_CLASS {
        // Command registers
        REGISTER_DISPLAY_ON  = "\x81",
        REGISTER_DISPLAY_OFF = "\x80",
        REGISTER_SYSTEM_ON   = "\x21",
        REGISTER_SYSTEM_OFF  = "\x20",
        // Display settings
        DISPLAY_ADDRESS      = "\x00",
        I2C_ADDRESS          = 0x70
}

/**
 * Squirrel class for 1.2-inch 8x8 LED matrix displays driven by the HT16K33 controller
 * For example: http://www.adafruit.com/products/1854
 *
 * Bus          I2C
 * Availibility Device
 * @author      Tony Smith (@smittytone)
 * @license     MIT
 *
 * @class
 *
 */
class HT16K33Matrix {

    /**
     * @property {string} VERSION - The library version
     *
     */
    static VERSION = "3.0.0";

    /**
     * @private
     *
     * @property {array} _pcharset - A proportionally spaced character set
     *                               NOTE Values are columns, 1 bit per pixel, bit 0
     *                                    at the bottom left of the matrix
     *
     */
    static _pcharset = [
        "\x00\x00",              // space - Ascii 32
        "\xfa",                  // !
        "\xc0\x00\xc0",          // "
        "\x24\x7e\x24\x7e\x24",  // #
        "\x24\xd4\x56\x48",      // $
        "\xc6\xc8\x10\x26\xc6",  // %
        "\x6c\x92\x6a\x04\x0a",  // &
        "\xc0",                  // '
        "\x7c\x82",              // (
        "\x82\x7c",              // )
        "\x10\x7c\x38\x7c\x10",  // *
        "\x10\x10\x7c\x10\x10",  // +
        "\x06\x07",              // ,
        "\x10\x10\x10\x10",      // -
        "\x06\x06",              // .
        "\x04\x08\x10\x20\x40",  // /
        "\x7c\x8a\x92\xa2\x7c",  // 0 - Ascii 48
        "\x42\xfe\x02",          // 1
        "\x46\x8a\x92\x92\x62",  // 2
        "\x44\x92\x92\x92\x6c",  // 3
        "\x18\x28\x48\xfe\x08",  // 4
        "\xf4\x92\x92\x92\x8c",  // 5
        "\x3c\x52\x92\x92\x8c",  // 6
        "\x80\x8e\x90\xa0\xc0",  // 7
        "\x6c\x92\x92\x92\x6c",  // 8
        "\x60\x92\x92\x94\x78",  // 9
        "\x36\x36",              // : - Ascii 58
        "\x36\x37",              // ;
        "\x10\x28\x44\x82",      // <
        "\x24\x24\x24\x24\x24",  // =
        "\x82\x44\x28\x10",      // >
        "\x60\x80\x9a\x90\x60",  // ?
        "\x7c\x82\xba\xaa\x78",  // @
        "\x7e\x90\x90\x90\x7e",  // A - Ascii 65
        "\xfe\x92\x92\x92\x6c",  // B
        "\x7c\x82\x82\x82\x44",  // C
        "\xfe\x82\x82\x82\x7c",  // D
        "\xfe\x92\x92\x92\x82",  // E
        "\xfe\x90\x90\x90\x80",  // F
        "\x7c\x82\x92\x92\x5c",  // G
        "\xfe\x10\x10\x10\xfe",  // H
        "\x82\xfe\x82",          // I
        "\x0c\x02\x02\x02\xfc",  // J
        "\xfe\x10\x28\x44\x82",  // K
        "\xfe\x02\x02\x02\x02",  // L
        "\xfe\x40\x20\x40\xfe",  // M
        "\xfe\x40\x20\x10\xfe",  // N
        "\x7c\x82\x82\x82\x7c",  // O
        "\xfe\x90\x90\x90\x60",  // P
        "\x7c\x82\x92\x8c\x7a",  // Q
        "\xfe\x90\x90\x98\x66",  // R
        "\x64\x92\x92\x92\x4c",  // S
        "\x80\x80\xfe\x80\x80",  // T
        "\xfc\x02\x02\x02\xfc",  // U
        "\xf8\x04\x02\x04\xf8",  // V
        "\xfc\x02\x3c\x02\xfc",  // W
        "\xc6\x28\x10\x28\xc6",  // X
        "\xe0\x10\x0e\x10\xe0",  // Y
        "\x86\x8a\x92\xa2\xc2",  // Z - Ascii 90
        "\xfe\x82\x82",          // [
        "\x40\x20\x10\x08\x04",  // \
        "\x82\x82\xfe",          // ]
        "\x20\x40\x80\x40\x20",  // ^
        "\x02\x02\x02\x02\x02",  // _
        "\xc0\xe0",              // '
        "\x04\x2a\x2a\x1e",      // a - Ascii 97
        "\xfe\x22\x22\x1c",      // b
        "\x1c\x22\x22\x22",      // c
        "\x1c\x22\x22\xfc",      // d
        "\x1c\x2a\x2a\x10",      // e
        "\x10\x7e\x90\x80",      // f
        "\x18\x25\x25\x3e",      // g
        "\xfe\x20\x20\x1e",      // h
        "\xbc\x02",              // i
        "\x02\x01\x21\xbe",      // j
        "\xfe\x08\x14\x22",      // k
        "\xfc\x02",              // l
        "\x3e\x20\x18\x20\x1e",  // m
        "\x3e\x20\x20 \x1e",     // n
        "\x1c\x22\x22\x1c",      // o
        "\x3f\x22\x22\x1c",      // p
        "\x1c\x22\x22\x3f",      // q
        "\x22\x1e\x20\x10",      // r
        "\x12\x2a\x2a\x04",      // s
        "\x20\x7c\x22\x04",      // t
        "\x3c\x02\x02\x3e",      // u
        "\x38\x04\x02\x04\x38",  // v
        "\x3c\x06\x0c\x06\x3c",  // w
        "\x22\x14\x08\x14\x22",  // x
        "\x39\x05\x06\x3c",      // y
        "\x26\x2a\x2a\x32",      // z - Ascii 122
        "\x10\x7c\x82\x82",      // {
        "\xee",                  // |
        "\x82\x82\x7c\x10",      // }
        "\x40\x80\x40\x80",      // ~
        "\x60\x90\x90\x60",      // Degrees sign - Ascii 127
    ];

    // *********** Private Properties **********

    _buffer = null;
    _led = null;
    _defchars = null;

    _ledAddress = 0;
    _alphaCount = 96;
    _rotationAngle = 0;
    _rotateFlag = false;
    _inverseVideoFlag = false;
    _debug = false;
    _debugShowI2C = true;
    _logger = null;

    _aFrames = null;
    _aTimer = null;
    _aCb = null;
    _aSliceIndex = 0;
    _aCharIndex = 0;
    _aSeqIndex = 0;
    _aFlag = true;

    /**
     *  Instantiate the matrix LED
     *
     *  @constructor
     *
     *  @param {imp::i2c} impI2Cbus    - Whichever configured imp I2C bus is to be used for the HT16K33
     *  @param {integer}  [i2cAddress] - The HT16K33's I2C address. Default: 0x70
     *  @param {bool}     [debug ]     - Set/unset to log/silence extra debug messages. Default: false
     *
     *  @returns {instance} this
     *
     */
    constructor(impI2Cbus = null, i2cAddress = 0x70, debug = false) {
        // Check bus argument
        if (impI2Cbus == null) throw "HT16K33Matrix() requires a non-null imp I2C object";
        if (i2cAddress < 0x00 || i2cAddress > 0xFF) throw "HT16K33Matrix() requires a valid I2C address";

        _led = impI2Cbus;
        _ledAddress = i2cAddress << 1;

        if (typeof debug != "bool") debug = false;
        _debug = debug;

        _buffer = blob(8);
        _defchars = {};

        // Select logging target, which stored in '_logger', and will be 'seriallog' if 'seriallog.nut'
        // has been loaded BEFORE HT16K33Matrix is instantiated on the device, otherwise it will be
        // the imp API object 'server'
        _logger = "seriallog" in getroottable() ? seriallog : server;
    }

    /**
     *  Initialize the matrix LED
     *
     *  @param {integer} [brightness] - Display brightness, 1-15. Default: 15
     *  @param {integer} [angle]      - Display auto-rotation angle, 0 to -360 degrees. Default: 0
     *
     */
    function init(brightness = 15, angle = 0) {
        // Angle range can be -360 to + 360 - ignore values beyond this
        if (angle < -360 || angle > 360) angle = 0;

        // Convert angle in degrees to internal value:
        // 0 = none, 1 = 90 clockwise, 2 = 180, 3 = 90 anti-clockwise
        if (angle < 0) angle = 360 + angle;

        if (angle > 3) {
            if (angle < 45 || angle > 360) angle = 0;
            if (angle >= 45 && angle < 135) angle = 1;
            if (angle >= 135 && angle < 225) angle = 2;
            if (angle >= 225) angle = 3
        }

        _rotationAngle = angle;
        if (_rotationAngle != 0) _rotateFlag = true;

        // Power up and set the brightness
        powerUp();
        setBrightness(brightness);
        clearDisplay();

        _alphaCount = _pcharset.len();
    }

    /**
     *  Sets the matrix LED brightness
     *
     *  @param {integer} [brightness] - Display brightness, 1-15. Default: 15
     *
     */
    function setBrightness(brightness = 15) {
        // Check argument type/range
        if (typeof brightness != "integer" && typeof brightness != "float") brightness = 15;
        brightness = brightness.tointeger();

        if (brightness > 15) {
            brightness = 15;
            if (_debug) _error("HT16K33Segment.setBrightness() brightness out of range (0-15)");
        }

        if (brightness < 0) {
            brightness = 0;
            if (_debug) _error("HT16K33Segment.setBrightness() brightness out of range (0-15)");
        }

        if (_debug) _log("Brightness set to " + brightness);
        brightness = brightness + 224;

        // Write the new brightness value to the HT16K33
        _led.write(_ledAddress, brightness.tochar() + "\x00");
    }

    /**
     *  Sets the matrix LED to inverse (black on colour) or regular video
     *
     *  @param {bool} [state] - Whether inverse video is set (true) or unset (false). Default: true
     *
     */
    function setInverseVideo(state = true) {
        // Check argument type
        if (typeof state != "bool") state = true;
        if (_inverseVideoFlag != state) {
            if (_debug) _log(format("Switching the HT16K33 Matrix to %s", (state ? "inverse video" : "normal video")));
            // We're changing the video mode, so update what's on the LED
            for (local i = 0 ; i < 8 ; i++) _buffer[i] = ~_buffer[i];
            _writeDisplay();
        }
        _inverseVideoFlag = state;
    }

    /**
     *  Set the matrix LED to log extra debug info
     *
     *  @param {bool} [state]       - Whether debugging is enabled (true) or not (false). Default: true
     *  @param {bool} [showAddress] - Whether debug messages add I2C address (true) or not (false). Default: true
     *
     */
    function setDebug(state = true, showAddress = null) {
        // Check arguments/values
        if (typeof state != "bool") state = true;
        if (showAddress == null || typeof showAddress != "bool") showAddress = state;
        _debug = state;
        _debugShowI2C = showAddress;
    }

    /**
     *  Displays a custom character on the matrix
     *
     *  @param {string|blob|array} glyphMatrix - 1-8 8-bit values defining a pixel image. The data is passed as columns
     *                                           0 through 7, left to right. Bit 0 is at the bottom, bit 7 at the top
     *  @param {bool}              [center]    - Whether the icon should be displayed centred on the screen. Default: false
     *
     */
    function displayIcon(glyphMatrix, center = false) {
        local type = typeof glyphMatrix;
        if (glyphMatrix == null || (type != "array" && type != "string" && type != "blob")) {
            if (_debug) _error("HT16K33Matrix.displayIcon() passed undefined icon array");
            return;
        }

        if (glyphMatrix.len() < 1 || glyphMatrix.len() > 8) {
            if (_debug) _error("HT16K33Matrix.displayIcon() passed incorrectly sized icon array");
            return;
        }

        _buffer = blob(8);
        if (_inverseVideoFlag) _fill();

        for (local i = 0 ; i < glyphMatrix.len() ; i++) {
            local a = i;
            if (center) a = i + ((8 - glyphMatrix.len()) / 2).tointeger();
            _buffer[a] = _inverseVideoFlag ? ~glyphMatrix[i] : glyphMatrix[i];
        }

        _writeDisplay();
    }

    /**
     *  Get a reference to the buffer for direct manipulation of the image
     *
     *  @returns {blob} The display buffer
     *
     */
    function getIcon() {
        return _buffer;
    }

    /**
     *  Display a single character specified by its Ascii value on the matrix
     *
     *  @param {integer} [asciiValue] - Character Ascii code. Default: 32 (space)
     *  @param {bool}    [center]     - Whether to center the character (true) or left-align (false). Default: false
     *
     */
    function displayCharacter(asciiValue = 32, center = false) {
        displayChar(asciiValue, center);
    }

    function displayChar(asciiValue = 32, center = false) {
        // Old method name, retained for compatibility
        // See displayCharacter() for details
        local inputMatrix;

        if (asciiValue < 32) {
            // A user-definable character has been chosen
            try {
                inputMatrix = _defchars[asciiValue];
            } catch(err) {
                if (_debug) _log("Use of undefined character (" + asciiValue + ") in HT16K33Matrix.displayCharacter()");
                inputMatrix = _pcharset[63];
            }
        } else {
            // A standard character has been chosen
            asciiValue -= 32;
            if (asciiValue < 0 || asciiValue > _alphaCount) asciiValue = 0;
            inputMatrix = _pcharset[asciiValue];
        }

        _buffer = blob(8);
        if (_inverseVideoFlag) _fill();

        for (local i = 0 ; i < inputMatrix.len() ; i++) {
            local a = i;
            if (center) a = i + ((8 - inputMatrix.len()) / 2).tointeger();
            _buffer[a] = _inverseVideoFlag ? ~inputMatrix[i] : inputMatrix[i];
        }

        _writeDisplay();
    }

    /**
     *  Bit-scroll through the characters in a string
     *
     *  @param {string} line - A string of text
     *
     */
    function displayLine(line) {
        // Check argument type/value
        if (line == null || line == "") {
            if (_debug) _error("HT16K33Matrix.displayLine() sent a null or zero-length string");
            return;
        }

        foreach (index, character in line) {
            local glyph;
            if (character < 32) {
                if (!(character in _defchars) || (typeof _defchars[character] != "string")) {
                    if (_debug) _log("Use of undefined character (" + character + ") in HT16K33Matrix.displayLine()");
                    glyph = _pcharset[63];
                } else {
                    glyph = _defchars[character];
                }
            } else {
                glyph = _pcharset[character - 32];

                // Add a blank column spacer
                // NOTE we'll convert for inverse video later
                if (glyph.len() < 8) glyph += "\x00";
            }

            foreach (column, columnValue in glyph) {
                local cursor = column;
                local glyphToDraw = glyph;
                local increment = 1;
                local outputFrame = blob(8);

                if (_inverseVideoFlag) _fill();

                for (local k = 0 ; k < 8 ; k++) {
                    if (cursor < glyphToDraw.len()) {
                        outputFrame[k] = glyphToDraw[cursor];
                        ++cursor;
                    } else {
                        if (index + increment < line.len()) {
                            if (line[index + increment] < 32) {
                                if (!(line[index + increment] in _defchars) || (typeof _defchars[line[index + increment]] != "string")) {
                                    if (_debug) _log("Use of undefined character (" + line[index + increment] + ") in HT16K33Matrix.displayLine()");
                                    glyphToDraw = _pcharset[0];
                                } else {
                                    glyphToDraw = _defchars[line[index + increment]];
                                }
                            } else {
                                glyphToDraw = _pcharset[line[index + increment] - 32];
                                glyphToDraw += "\x00";
                            }
                            increment++;
                            cursor = 1;
                            outputFrame[k] = glyphToDraw[0];
                        }
                    }
                }

                // Set the buffer, inversing if necessary
                for (local k = 0 ; k < 8 ; k++) _buffer[k] = _inverseVideoFlag ? ~outputFrame[k] : outputFrame[k];

                // Pause between frames according to level of rotation
                imp.sleep(_rotationAngle == 0 ? 0.060 : 0.045);
                _writeDisplay();
            }
        }
    }

    /**
     *  Set a user-definable chararacter for later use
     *
     *  @param  {integer}           [asciiCode] - Character's assigned Ascii code 0-31. Default: 0
     *  @param  {string|blob|array} glyphMatrix - 1-8 8-bit values defining a pixel image. The data is passed as columns,
     *                                            with bit 0 at the bottom and bit 7 at the top
     *
     */
    function defineCharacter(asciiCode = 0, glyphMatrix = null) {
        defineChar(asciiCode, glyphMatrix);
    }

    function defineChar(asciiCode = 0, glyphMatrix = null) {
        // Old method name, retained for compatibility
        // See defineCharacter() for details
        local type = typeof glyphMatrix;
        if (glyphMatrix == null || (type != "array" && type != "string" && type != "blob")) {
            if (_debug) _error("HT16K33Matrix.defineChar() passed undefined icon array");
            return;
        }

        if (glyphMatrix.len() < 1 || glyphMatrix.len() > 8) {
            if (_debug) _error("HT16K33Matrix.defineChar() passed incorrectly sized icon array");
            return;
        }

        if (asciiCode < 0 || asciiCode > 31) {
            if (_debug) _error("HT16K33Matrix.defineChar() passed an incorrect character code");
            return;
        }

        if (_debug) {
            if (asciiCode in _defchars) {
                _log("Character " + asciiCode + " already defined so redefining it");
            } else {
                _log("Setting user-defined character " + asciiCode);
            }
        }

        // Convert input array to a string of bytes
        local matrix = "";
        for (local i = 0 ; i < glyphMatrix.len() ; i++) matrix += glyphMatrix[i].tochar();

        // Save the string in the defchars table with the supplied Ascii code as its key
        if (asciiCode in _defchars) {
            _defchars[asciiCode] = matrix;
        } else {
            _defchars[asciiCode] <- matrix;
        }
    }

    /**
     *  Plot a point on the matrix. (0,0) is bottom left as viewed
     *
     *  @param {integer} x     - X co-ordinate (0 - 7) left to right
     *  @param {integer} y     - Y co-ordinate (0 - 7) bottom to top
     *  @param {integer} [ink] - Pixel color: 1 = 'white', 0 = black. NOTE inverse video mode reverses this. Default: 1
     *  @param {bool}    [xor] - Whether an underlying pixel already of color ink should be inverted. Default: false
     *
     *  @returns {imstance} this
     *
     */
    function plot(x, y, ink = 1, xor = false) {
        // Check argument range and value
        if (x < 0 || x > 7) {
            _error("HT16K33Matrix.plot() X co-ordinate out of range (0-7)");
            return;
        }

        if (y < 0 || y > 7) {
            _error("HT16K33Matrix.plot() Y co-ordinate out of range (0-7)");
            return;
        }

        if (ink != 1 && ink != 0) ink = 1;
        if (_inverseVideoFlag) ink = ((ink == 1) ? 0 : 1);

        local col = _buffer[x];

        if (ink == 1) {
            // We want to set the pixel
            local bit = col & (1 << y);
            if (bit > 0 && xor) {
                // Pixel is already set, but 'xor' is true so clear the pixel
                col = col & (0xFF - (1 << y));
            } else {
                // Pixel is clear so set it
                col = col | (1 << y);
            }
        } else {
            // We want to clear the pixel
            local bit = col & (1 << y);
            if (bit == 0 && xor) {
                col = col | (1 << y);
            } else {
                col = col & (0xFF - (1 << y));
            }
        }

        _buffer[x] = col;
        return this;
    }

    /**
     *  Set the matrix to flash at one of three pre-defined rates
     *
     *  @param {integer} [flashRate] - Flash rate in Herz. Must be 0.5, 1 or 2 for a flash, or 0 for no flash. Default: 0
     *
     */
    function setDisplayFlash(flashRate = 0) {
        local values = [0, 2, 1, 0.5];
        local match = -1;
        foreach (i, value in values) {
            if (value == flashRate) {
                match = i;
                break;
            }
        }

        if (match == -1) {
            _logger.error("HT16K33Matrix.setDisplayFlash() passed an invalid blink frequency");
            return null;
        }

        match = 0x81 + (match << 1);
        _led.write(_ledAddress, match.tochar() + "\x00");
        if (_debug) _log(format("Display flash set to %d Hz", ((match - 0x81) >> 1)));
    }

    /**
     *  Clear the matrix buffer and write it to the display itself
     *
     */
    function clearDisplay() {
        _buffer = blob(8);
        if (_inverseVideoFlag) _fill();
        _writeDisplay();
    }

    /**
     *  Write out the instance's buffer to the display itself
     *
     */
    function draw() {
        _writeDisplay();
    }

    /**
     *  Turn the matrix off
     *
     */
    function powerDown() {
        if (_debug) _log("Turning the HT16K33 Matrix off");
        _led.write(_ledAddress, HT16K33_MATRIX_CLASS.REGISTER_DISPLAY_OFF);
        _led.write(_ledAddress, HT16K33_MATRIX_CLASS.REGISTER_SYSTEM_OFF);
    }

    /**
     *  Turn the matrix on
     *
     */
    function powerUp() {
        if (_debug) _log("Turning the HT16K33 Matrix on");
        _led.write(_ledAddress, HT16K33_MATRIX_CLASS.REGISTER_SYSTEM_ON);
        _led.write(_ledAddress, HT16K33_MATRIX_CLASS.REGISTER_DISPLAY_ON);
    }

    // ****** PRIVATE FUNCTIONS - DO NOT CALL ******

    /**
     *  Takes the contents of _buffer and writes it to the LED matrix.
     *  Data is sent column (one byte) by column, left to right (0-7)
     *
     *  @private
     *
     */
    function _writeDisplay() {
        local dataString = HT16K33_MATRIX_CLASS.DISPLAY_ADDRESS;
        local writedata = clone(_buffer);
        if (_rotationAngle != 0) writedata = _rotateMatrix(writedata, _rotationAngle);
        for (local i = 0 ; i < 8 ; i++) dataString += ((_processByte(writedata[i])).tochar() + "\x00");
        _led.write(_ledAddress, dataString);
    }

    /**
     *  Rotate an 8-integer matrix through the specified angle in 90-degree increments:
     *  0 = none, 1 = 90 clockwise, 2 = 180, 3 = 90 anti-clockwise
     *
     *  @private
     *
     *  @param {blob|string|array} inputMatrix - The matrix to be rotated
     *  @param {integer}           [angle]     - The angle of rotation. Default: 0
     *
     *  @returns {string} The rotated matrix
     *
     */
    function _rotateMatrix(inputMatrix, angle = 0) {
        if (angle == 0) return inputMatrix;

        local a = 0;
        local lineValue = 0;
        local outputMatrix = blob(8);

        // NOTE It's quicker to have three case-specific
        //      code blocks than a single, generic block
        switch(angle) {
            case 1:
                for (local y = 0 ; y < 8 ; y++) {
                    lineValue = inputMatrix[y];
                    for (local x = 7 ; x > -1 ; --x) {
                        a = lineValue & (1 << x);
                        if (a != 0) outputMatrix[7 - x] = outputMatrix[7 - x] + (1 << y);
                    }
                }
                break;

            case 2:
                for (local y = 0 ; y < 8 ; y++) {
                    lineValue = inputMatrix[y];
                    for (local x = 7 ; x > -1 ; --x) {
                        a = lineValue & (1 << x);
                        if (a != 0) outputMatrix[7 - y] = outputMatrix[7 - y] + (1 << (7 - x));
                    }
                }
                break;

            case 3:
                for (local y = 0 ; y < 8 ; y++) {
                    lineValue = inputMatrix[y];
                    for (local x = 7 ; x > -1 ; --x) {
                        a = lineValue & (1 << x);
                        if (a != 0) outputMatrix[x] = outputMatrix[x] + (1 << (7 - y));
                    }
                }
                break;
        }

        return outputMatrix.tostring();
    }

    /**
     *  Adafruit 8x8 matrix requires some data manipulation:
     *  Bits 7-0 of each line need to be sent 0 through 7, and bit 0 rotated to bit 7
     *
     *  @private
     *
     *  @param {integer} byteValue - The value to be processed
     *
     *  @returns {integer} The processed value
     *
     */
    function _processByte(byteValue) {
        local bit0 = byteValue & 0x01;
        local result = byteValue >> 1;
        if (bit0 > 0) result += 0x80;
        return result;
    }

    /**
     *  Write the message to the logger, prefixing with the LED's I2C address if required to ID units in a multi-LED display
     *
     *  @private
     *
     *  @param {string} message - The string to be written
     *
     */
    function _log(message) {
        if (_debugShowI2C) message = format("[%02X] ", (_ledAddress >> 1)) + message;
        _logger.log(message);
    }

    /**
     *  Write the error message to the logger, prefixing with the LED's I2C address if required to ID units in a multi-LED display
     *
     *  @private
     *
     *  @param {string} message - The string to be written
     *
     */
    function _error(message) {
        if (_debugShowI2C) message = format("[%02X] ", (_ledAddress >> 1)) + message;
        _logger.error(message);
    }

    /**
     *  Fill the buffer with the specified value
     *
     *  @private
     *
     *  @param {integer} value - The pixel fill value
     *
     */
    function _fill(value = 0xFF) {
        for (local i = 0 ; i < 8 ; i++) _buffer[i] = value;
    }

    // ********** EXPERIMENTAL ***********

    // Display the strings in the array as per displayLine()
    // but with the strings displayed alternately to provide
    // a basic animation feature as the two scroll
    function animate(frames = null, completeCallback = null) {
        if (frames == null || typeof frames != "array") {
            if (_debug) _error("HT16K33Matrix.animate() takes an array of strings or blobs");
            return;
        }

        // 'animate()' needs at least two strings/blobs
        if (frames.len() < 2) {
            if (_debug) _error("HT16K33Matrix.animate() takes an array of two or more strings");
            return;
        }

        // Adjacent strings/blobs must be the same length
        for (local i = 1 ; i < frames.len() ; i++) {
            local a = frames[i - 1];
            local b = frames[i];

            if (a.len() != b.len()) {
                if (_debug) _error("HT16K33Matrix.animate() takes an array of strings or blobs of equal length");
                return;
            }
        }

        // Set/initialise the animation variables
        _aFrames = frames;
        _aCharIndex = 0;        // Character in the string
        _aSliceIndex = 0;       // Column inset at which the frame starts
        _aSeqIndex = 0;         // Which string to display
        _aCb = completeCallback;

        // Start animating
        _animateFrame();
    }

    // Stop the animation flow
    function stopAnimate() {
        if (_aTimer != null) imp.cancelwakeup(_aTimer);
        _aTimer = null;
    }

    // Animate a single frame
    function _animateFrame() {
        // Clear the buffer
        this._buffer = blob(8);

        local glyph;
        local index = 0;
        local sliceIndex = this._aSliceIndex;
        local charIndex = this._aCharIndex;

        // Get the current string
        local frame = _aFrames[this._aSeqIndex];

        do {
            local c;

            try {
                // Get the current character from the current string
                c = frame[charIndex];
            } catch(err) {
                break;
            }

            if (c < 32) {
                // Display a user-defined character
                if (this._defchars[c] == -1 || (typeof this._defchars[c] != "string")) {
                    // Character not defined; present a space instead
                    glyph = this._pcharset[0];
                    glyph += "\x00";
                } else {
                    glyph = this._defchars[c];
                }
            } else {
                // Display a standard Ascii character
                glyph = this._pcharset[c - 32];
                glyph += "\x00";
            }

            for (local i = sliceIndex ; i < glyph.len() ; i++) {
                // Display however many rows of the 8x8 matrix will be taken up
                // by the visible rows of the lead character glyph
                this._buffer[index] = glyph[i];
                index++;

                // Break if the character glyph contains more rows than there
                // are free rows in the buffer
                if (index > 7) break;
            }

            // Start at the first row of the next character and advance
            // the character index by one
            sliceIndex = 0;
            charIndex++;

        } while (index < 8)

        // Handle any required rotation and write the buffer to the matrix
        if (this._rotateFlag) this._buffer = _rotateMatrix(this._buffer, this._rotationAngle);
        _writeDisplay();

        // Load in the current glyph to see if we're at its end
        local c = frame[this._aCharIndex];

        if (c < 32) {
            // User-defined character?
            if (this._defchars[c] == -1 || (typeof this._defchars[c] != "string")) {
                // Yes, but it's undefined so use a space
                glyph = this._pcharset[0];
                glyph += "\x00";
            } else {
                glyph = clone(this._defchars[c]);
            }
        } else {
            // No, so use a standard Ascii character
            glyph = this._pcharset[c - 32];
            glyph += "\x00";
        }

        // If the start row is greater than the characters length, we
        // start the next frame with a new character from the string
        if (this._aSliceIndex > glyph.len()) {
            this._aSliceIndex = 0;
            ++this._aCharIndex;
        }

        // If we still have sufficient characters to animate onto the matrix,
        // set the next frame to be rendered in 0.1s' time
        if (this._aCharIndex < frameString.len() - 1) {
            // Move on to the next string
            _aSeqIndex++;

            if (_aSeqIndex == _aStrings.len()) {
                // We've run through the x strings, so go back to the first
                // and move on a column
                _aSeqIndex = 0;
                this._aSliceIndex++;
            }
        } else {
            _aCb();
        }

        _aTimer = imp.wakeup(0.1, _animateFrame.bindenv(this));
    }
}

// GLOBALS
isShowing <- false;
leds <- [];
holding <- [];
matrix <- null;
msgLen <- 0;
count <- 0;
state <- true;
flashCount <- 0;
speed <- 0.04;
iconOne <- "\x00\x00\xFF\xC1\xA1\x91\x89\x89\x89\x89\x91\xA1\xC1\xFF\x00\x00";
iconTwo <- "\xFF\xFF\x00\x3E\x5E\x6E\x76\x76\x76\x76\x6E\x5E\x3E\x00\xFF\xFF";
iconThree <- "\x38\x44\xAA\x82\xAA\x44\x38\x00";
waitingText <- null;
twilioText <- null;


// FUNCTIONS
function displayAlert() {
    // Flash the envelope icon before running the animation
    local icon = state ? iconOne : iconTwo;
    local k = 8;
    for (local j = 0 ; j < icon.len() ; j++) {
        matrix[k] = icon[j];
        k++;
    }

    updateMatrix(0);
    state = !state;

    if (flashCount < 10) {
        flashCount++;
        imp.wakeup(speed * 3, displayAlert);
    } else {
        scrollMessage();
    }
}

function updateMatrix(start) {
    // Write a chunk of the message blob to the LEDs
    for (local i = 0 ; i < 4 ; i++) {
        matrix.seek(start, 'b');
        leds[i].displayIcon(matrix.readblob(8));
        start += 8
    }
}

function scrollMessage() {
    updateMatrix(count)
    count += 1;

    if (count < msgLen - 31) {
        imp.wakeup(speed, scrollMessage);
    } else {
        if (holding.len() > 0) {
            // A message arrived while we were showing the last one
            // so display it now
            prep(holding[0]);
            holding.remove(0);
        } else {
            // All done... wait four seconds then show the
            // 'waiting' message
            isShowing = false;
            imp.wakeup(4, showWaiting);
        }
    }
}

function prep(message) {
    // Set up to display the message text
    isShowing = true;
    setMessage(message);
    count = 0;
    flashCount = 0;
    displayAlert();
}

function setMessage(msg) {
    // Assemble the message blob which we'll write to the display:
    // icon + message + icon + Twilio
    msgLen = getLength(msg);
    matrix = blob(msgLen);
    local k = 32;
    for (local i = 0 ; i < msg.len() ; i++) {
        local c = HT16K33Matrix._pcharset[msg[i] - 32];
        for (local j = 0 ; j < c.len() ; j++) {
            matrix[k] = c[j];
            k++;
        }

        // Add space
        k++;
    }

    matrix.seek(-32, 'e');
    matrix.writeblob(twilioText);
}

function getLength(msg) {
    // Calculate the length of the message text blob
    local length = 80;
    for (local i = 0 ; i < msg.len() ; i++) {
        length += (HT16K33Matrix._pcharset[msg[i] - 32]).len();
        length += 1;
    }
    return length;
}

function showWaiting() {
    // Display the waiting text
    for (local i = 0 ; i < 4 ; i++) {
        waitingText.seek(i * 8, 'b');
        leds[i].displayIcon(waitingText.readblob(8));
    }
}

function writeText(text, store, start = 0, quirk = false) {
    // Write the specified text into the specified blob at the
    // specified start byte
    local k = start;
    for (local i = 0 ; i < text.len() ; i++) {
        local c = HT16K33Matrix._pcharset[text[i] - 32];
        for (local j = 0 ; j < c.len() ; j++) {
            store[k] = c[j];
            k++;
        }
        if (quirk && k == 13) continue;
        k++;
    }
}

// Set up the I2c bus and the four LED matrices
local address = 0x70;
hardware.i2c89.configure(CLOCK_SPEED_400_KHZ);
for (local i = 0 ; i < 4 ; i++) {
    local led = HT16K33Matrix(hardware.i2c89, address);
    led.init(4);
    leds.append(led);
    address++;

    // Quirk - one non-sequential LED address
    if (i == 2) address = 0x74;
}

// Set up waiting text
waitingText = blob(32);
writeText("Waiting", waitingText);

// Set up the Twilio text
twilioText = blob(32);
for (local j = 0 ; j < iconThree.len() ; j++) {
    twilioText[j] = iconThree[j];
}
writeText("Twilio", twilioText, 8, true);

// Register the handler for incoming SMS messages
agent.on("show.sms", function(message) {
    if (isShowing) {
        // Park messages coming in while we're displaying another message
        holding.append(message);
    } else {
        // Display the incoming message
        prep(message);
    }
});

// Wait for incoming...
showWaiting();
