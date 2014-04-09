//
//  NezRandom.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-30.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#ifndef Aletteration3_NezRandom_h
#define Aletteration3_NezRandom_h

#define NEZ_ARC4RANDOM_MAX 0x100000000
#define NEZ_ARC4RANDOM_MAX_FLOAT_CASTED ((float)NEZ_ARC4RANDOM_MAX)

float randomFloat();
float randomFloatInRange(float start, float length);
int randomIntInRange(int start, int length);

#endif
