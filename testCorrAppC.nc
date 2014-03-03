#include <Timer.h>
#include "testCorr.h"
#include "BitVecUtils.h"

configuration testCorrAppC{
}
implementation{
	components MainC;
	components LedsC;
	components BitVecUtilsC;
	components testCorrC as App;
	components new TimerMilliC() as Timer0;
	components ActiveMessageC;
	components new AMSenderC(AM_CORR);
	components new AMReceiverC(AM_CORR);
	components PrintfC, SerialStartC;
	App.Boot -> MainC;
	App.Leds -> LedsC;
	App.Timer0 -> Timer0;
	App.Timer1 -> Timer0;
	App.Packet -> AMSenderC;
	App.AMPacket -> AMSenderC;
	App.AMSend -> AMSenderC;
	App.AMControl -> ActiveMessageC;
	App.Receive -> AMReceiverC;
	App.BitVecUtils->BitVecUtilsC;
}
