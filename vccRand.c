/*
 *  vccRand.c
 *  Freecell
 *
 *  Created by Lowell on Sat Feb 26 2005.
 *
 * visual c cpp 6 srand and rand
 * adapted from implementation found on the internet
 * http://www.codeguru.com/forum/showthread.php?t=312416&goto=nextnewest
 */

#include "vccRand.h"

static unsigned long vcpp_holdrand = 1;

void vcpp_srand( unsigned int seed )
{
	vcpp_holdrand = (long)seed;
}

int vcpp_rand(void)
{
	// originally:
	// return(((holdrand = holdrand * 214013L + 2531011L) >> 16) & 0x7fff);
	vcpp_holdrand = vcpp_holdrand * 214013L + 2531011L;
	return ((vcpp_holdrand >> 16) & 0x7fff);
}
