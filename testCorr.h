#ifndef BLINKTORADIO_H
 #define BLINKTORADIO_H
 
 enum {
   TIMER_PERIOD_MILLI = 500,
   TOTAL_PKTS = 96,
   BIT_VEC_SIZE = TOTAL_PKTS/8, //req vector size.
   AM_CORR = 6,
   RECORD_LEN = 10, // how many dup to record.
 };
 
typedef nx_struct testCorrDataMsg{
  nx_uint8_t nodeid;
  nx_uint16_t seqno;
  nx_uint16_t counter;
}testCorrDataMsg;

typedef nx_struct testCorrReqMsg{ //a receiver request for missing packets in the TOTAL_PKTS packets.
   nx_uint8_t dest;
   nx_uint8_t nodeid;
   nx_uint8_t bv[BIT_VEC_SIZE];
}testCorrReqMsg;

#endif
