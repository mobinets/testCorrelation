COMPONENT=testCorrAppC
CFLAGS += -DPRINTF_BUFFER_SIZE=1024
CFLAGS += -I$(TOSDIR)/lib/printf/
CFLAGS += -DCC2420_DEF_RFPOWER=1
CFLAGS += -DCC2420_DEF_CHANNEL=20
include $(MAKERULES)
