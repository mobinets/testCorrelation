#!/usr/bin/python
import sys
import random

size = 1
flashBegin = 0x4A00

def usage():
    print "Usage: makeImage.py FILE SIZE"
    print "  FILE   File name of output."
    print "  SIZE   Size of the binary code."

def generate():
    global size

    try:
        f = open("tos_image.xml", "w")
        f.write("<tos_image>\n")
        f.write("  <ident>\n")
        f.write("    <uidhash>%08XL</uidhash>\n" % random.randint(0, 0xffffffff))
        f.write("    <hostname>coLinux</hostname>\n")
        f.write("    <username>morning</username>\n")
        f.write("    <appname>IMG%05dBYTES</appname>\n" % size)
        f.write("    <userhash>95F9CEF9L</userhash>\n")
        f.write("    <timestamp>4AE837FDL</timestamp>\n")
        f.write("    <deluge_support>yes</deluge_support>\n")
        f.write("    <platform>telosb</platform>\n")
        f.write("  </ident>\n")
        f.write("  <image format=\"ihex\">\n")
        
        hex = open("main.ihex", "w")

        if size > 32:
            size -= 32
            len = size
            while len > 16:
                line = ":10"
                line += "%04X" % (flashBegin + size - len)
                line += "00"
                line += "0102030405060708090A0B0C0D0E0F10"
                line += "%02X\r\n" % (256 - (16+ 0x4000 + size - len + 136) % 256)
                len -= 16
                f.write(line)
                hex.write(line)
            line = ":%02X" % len
            line += "%04X" % (flashBegin + size - len)
            line += "00"
            sum = len + flashBegin + size - len
            for i in range(0, len):
                line += "%02X" % i
                sum += i
            line += "%02X\r\n" % (256 - sum % 256)
            f.write(line)
            hex.write(line)
        #endif size > 32
        hex.write(":10FFE0003A40D866D8643E610466B44068403A40FE\r\n")
        hex.write(":10FFF000F86762673A403A40C04BFA403A400040E6\r\n")
        hex.write(":0400000300004000B8\r\n")
        hex.write(":00000001FF\r\n")
        # then f
        f.write(":10FFE0003A40D866D8643E610466B44068403A40FE\r\n")
        f.write(":10FFF000F86762673A403A40C04BFA403A400040E6\r\n")
        f.write(":0400000300004000B8\r\n")
        f.write(":00000001FF\r\n")
        f.write("  </image>\n")
        f.write("</tos_image>\n")
    finally:
        f.close()
        hex.close()

if not len(sys.argv) == 2:
    usage()
    sys.exit()
else:
    size = int(sys.argv[1])
    generate()

