/*
 *  writePNG.h
 *  QREncoder
 *
 *  Created by Rafael Vega on 9/29/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import "qrencode.h"
#include <stdlib.h>
#include <png.h>

#ifndef __WRITE_PNG__
#define __WRITE_PNG__
int writePNG(QRcode *qrcode, const char *outfile);
#endif