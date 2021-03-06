#include "scu_bus.h"
#include "display.h"



/*  for every found slave the slotnumber is added to the slave array
    e.g. [2,3] means slaves in slot 2 and 3
*/
void probe_scu_bus(volatile unsigned short* bus_addr, unsigned short system_addr, unsigned short group_addr, int* slaves) {
  int slot;
  unsigned short cid_sys, cid_group;
  for (slot = 1; slot <= SCU_BUS_MAX_SLOTS; slot++) {
    cid_sys = bus_addr[(slot<<16) + CID_SYS];     //CID system addr from slave
    cid_group = bus_addr[(slot<<16) + CID_GROUP]; //CID group addr from slave
    if (cid_sys == system_addr && cid_group == group_addr) 
      *(slaves++) = slot;  
  }
  *slaves = 0; // end of device list 
} 
