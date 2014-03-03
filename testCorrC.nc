#include <Timer.h>
#include "testCorr.h"
#include "BitVecUtils.h"
#include "printf.h"

module testCorrC {
   uses interface Boot;
   uses interface Leds;
   uses interface Timer<TMilli> as Timer0;
   uses interface Timer<TMilli> as Timer1; // for detecting packet loss.
   uses interface Packet;
   uses interface AMPacket;
   uses interface AMSend;
   uses interface SplitControl as AMControl;
   uses interface Receive;
   uses interface BitVecUtils;
 }
 implementation {
   uint16_t seqno = 0;
   uint16_t nextPkt;
   uint16_t ones;
   uint8_t txBv[BIT_VEC_SIZE];
   uint8_t rxBv[BIT_VEC_SIZE];
   bool busy = FALSE;
   bool finish=FALSE;
   message_t pkt;
   uint8_t i;
   uint8_t dup[RECORD_LEN][2]; // record the latest 10 dups.
   uint16_t txCnt;
   uint16_t lastPkt;
   //uint8_t dup[RECORD_LEN]; // record the latest RECORD_LEN*8 packets in bit vector.

 event void Boot.booted() {
     call AMControl.start();
   }
   
 event void AMControl.startDone(error_t err) {
   dbg("CORR", "node id: %d\n", TOS_NODE_ID);
    if (TOS_NODE_ID == 0){
      finish=TRUE;
      txCnt=0;
      for (i=0;i<BIT_VEC_SIZE;i++){ //init. the bit vector. 
      txBv[i] = 0xff; // 1 denotes a packet to transmit and 0 denotes a packet that has been transmitted.
      rxBv[i] = 0x00;
        }
      }
      else {
      lastPkt=0;
      for (i=0;i<BIT_VEC_SIZE;i++){ //init. the bit vector. 
      txBv[i] = 0x00;
      rxBv[i] = 0xff;
        }
      dup[i][0] = 0; // dup counter for each packet.
      }
    if (err == SUCCESS) {
      if (TOS_NODE_ID == 0){
      call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
      }
      else{
        call Timer1.startOneShot(3*TIMER_PERIOD_MILLI); // start req.
      }
    }
    else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
  }

   event void Timer0.fired() {
   if (TOS_NODE_ID !=0){
   return;
   }
   if (call BitVecUtils.indexOf(&nextPkt, 0, txBv, TOTAL_PKTS) != SUCCESS) {
   printf("Send Done, total count: %d\n", txCnt);
   printfflush();
   dbg("CORR", "Send Done, total count: %d\n", txCnt);
   call Timer0.stop();
   return;
   } else {   
	   if (!busy) {
	    testCorrDataMsg* btrpkt = (testCorrDataMsg*)(call Packet.getPayload(&pkt, sizeof (testCorrDataMsg)));
	    btrpkt->nodeid = TOS_NODE_ID;
	    btrpkt->seqno = nextPkt;
      btrpkt->counter = txCnt;
	    dbg("CORR", "sending %d th packet.\n", nextPkt);
      printf("sending %d th packet.\n", nextPkt);
	    if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(testCorrDataMsg)) == SUCCESS) {
	      busy = TRUE;
	    }
      call Leds.led0Toggle();
	    BITVEC_CLEAR(txBv,nextPkt); //sent.
     }
  }
}

event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
  if (len == sizeof(testCorrDataMsg)) {
    testCorrDataMsg* btrdatapkt = (testCorrDataMsg*)payload;
    printfflush();
    if (BITVEC_GET(rxBv,btrdatapkt->seqno) == 0){
     dbg("CORR", "pkt %d dupped.\n", btrdatapkt->seqno);
     printf("dup: %d\n", btrdatapkt->seqno);
     printfflush();
     if (btrdatapkt->counter - lastPkt < RECORD_LEN){
      if (dup[btrdatapkt->counter%RECORD_LEN][0] != btrdatapkt->seqno){
      dup[btrdatapkt->counter%RECORD_LEN][0] = btrdatapkt->seqno;  
      dup[btrdatapkt->counter%RECORD_LEN][1] = 0;
      }
     dup[btrdatapkt->counter%RECORD_LEN][1] ++; // this packet has been received more than once.
     }
    }
    else {
      for (i=1;i<(btrdatapkt->counter-lastPkt);i++){ // for obtaining the 0101 seq. for cal. corr.
        printf("0");
      }
      printf("1");
      lastPkt=btrdatapkt->counter;
     dbg("CORR", "pkt %d received.\n", btrdatapkt->seqno);
     //printf("pkt %d received.\n", btrdatapkt->seqno);
     //printfflush();
    BITVEC_CLEAR(rxBv,btrdatapkt->seqno); //received packet.
    }
    call BitVecUtils.countOnes(&ones, rxBv, TOTAL_PKTS);
    if (ones == 0) {
	//all packets received.
      printf("all pkts received. dup list:\n");
      finish = TRUE;
      dbg("CORR", "all pkts received. dup list:\n**********\n");
      call Leds.led2On(); // marking finish.
      for (i=0;i<RECORD_LEN;i++){
	      if (dup[i][0]!=0){
	        dbg("CORR", "%d:%d,  \n", dup[i][0], dup[i][1]);
	        printf("%d:%d,  \n", dup[i][0], dup[i][1]);
	      }
      }
      dbg("CORR", "\n**********\n");
      printf("\n");
      printfflush();
      call Leds.led0On();
    }
    else{
    call Leds.led0Toggle();
    call Timer1.stop();
    call Timer1.startOneShot(3*TIMER_PERIOD_MILLI); // wait for three packets time.
  }
  }

 if (len == sizeof(testCorrReqMsg)) {
    testCorrReqMsg* btrreq = (testCorrReqMsg*)payload;
    if (TOS_NODE_ID != 0){return msg;}
    //transmit requested packets.
    printf("receive req from %d\n", btrreq->nodeid);
    for (i=0;i<BIT_VEC_SIZE;i++){
      txBv[i] |= btrreq->bv[i];
      }
      call Leds.led2Toggle();
      call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
  }
  return msg;
 }

event void Timer1.fired(){
  if (TOS_NODE_ID ==0){
   return;
   }
//haven't received packets for 3 slots.
if (!finish){
dbg("CORR", "Not finished, Prepare req msgs for %d pkts!\n", ones);
printf("Not finished, Prepare req msgs for %d pkts!\n", ones);
printfflush();
if (!busy) {
      testCorrReqMsg* btrpkt = (testCorrReqMsg*)(call Packet.getPayload(&pkt, sizeof(testCorrReqMsg)));
      if (btrpkt == NULL) {
      dbg("CORR","REPORT NULL\n");
	return;
      }
      btrpkt->dest = 0;
      btrpkt->nodeid = TOS_NODE_ID;
      memcpy(btrpkt->bv, rxBv, BIT_VEC_SIZE);
      if (call AMSend.send(AM_BROADCAST_ADDR, 
          &pkt, sizeof(testCorrReqMsg)) == SUCCESS) {
        busy = TRUE;
      }
      call Leds.led1Toggle();
      call Timer1.startPeriodic(3*TIMER_PERIOD_MILLI);
    }
}
else {
  call Timer1.stop();
  printf("done\n");
  printfflush();
}
}

 event void AMSend.sendDone(message_t* msg, error_t error) {
    if (&pkt == msg) {
      busy = FALSE;
      if (TOS_NODE_ID == 0){
       txCnt++;
       }
    }
  }
}
