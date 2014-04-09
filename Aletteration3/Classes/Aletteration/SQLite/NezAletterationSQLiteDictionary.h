//
//  NezSQLiteDictionary.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-22.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezAletterationGameState.h"

typedef enum NezAletterationDictionaryInputType {
	NEZ_DIC_INPUT_ISNOT_SET = -1,
	NEZ_DIC_INPUT_ISNOTHING,
	NEZ_DIC_INPUT_ISPREFIX,
	NEZ_DIC_INPUT_ISWORD,
	NEZ_DIC_INPUT_ISBOTH,
	NEZ_DIC_INPUT_IS_NO_MORE,
} NezAletterationDictionaryInputType;

@interface NezAletterationSQLiteDictionary : NSObject

+(NezAletterationDictionaryInputType)getTypeWithInput:(char*)inputString LetterCounts:(NezAletterationLetterBag)letterCounter;
+(long)getPrefixCountWithInput:(char*)ins LetterCounts:(NezAletterationLetterBag)letterCounter;
+(long)getWordCountWithInput:(char*)ins LetterCounts:(NezAletterationLetterBag)letterCounter;

@end
