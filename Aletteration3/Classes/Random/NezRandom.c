//
//  NezRandom.c
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-30.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#include <stdlib.h>
#include "NezRandom.h"

float randomFloat() {
	return ((float)arc4random())/NEZ_ARC4RANDOM_MAX_FLOAT_CASTED;
}

float randomFloatInRange(float start, float length) {
	return randomFloat() * length + start;
}

int randomIntInRange(int start, int length) {
	return (int)(randomFloat() * length + start);
}
