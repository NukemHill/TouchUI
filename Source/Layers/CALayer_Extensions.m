//
//  CALayer_Extensions.m
//  TouchCode
//
//  Created by Jonathan Wight on 04/24/08.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//     1. Redistributions of source code must retain the above copyright notice, this list of
//        conditions and the following disclaimer.
//
//     2. Redistributions in binary form must reproduce the above copyright notice, this list
//        of conditions and the following disclaimer in the documentation and/or other materials
//        provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY JONATHAN WIGHT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JONATHAN WIGHT OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of toxicsoftware.com.

#import "CALayer_Extensions.h"

@implementation CALayer (CALayer_Extensions)

@dynamic name;

- (id)initWithFrame:(CGRect)inFrame
{
if ((self = [self init]) != NULL)
	{
	self.frame = inFrame;
	}
return(self);
}

#pragma mark -

- (CGFloat)zoom
{
const CATransform3D theTransform = self.transform;
if ((theTransform.m11 == theTransform.m22) && (theTransform.m22 == theTransform.m33))
	{
	return(theTransform.m11);
	}
else
	{
	return((theTransform.m11 + theTransform.m22 + theTransform.m33) / 3.0f);
	}
}

- (void)setZoom:(CGFloat)inZoom
{
CATransform3D theTransform = self.transform;
theTransform.m11 = theTransform.m22 = theTransform.m33 = inZoom;
self.transform = theTransform;
}

- (void)setZoom:(CGFloat)inZoom centeringAtPoint:(CGPoint)inPoint
{
CATransform3D theTransform = self.transform;

theTransform = CATransform3DTranslate(theTransform, inPoint.x, inPoint.y, 0.0f);

theTransform.m11 = theTransform.m22 = theTransform.m33 = inZoom;

theTransform = CATransform3DTranslate(theTransform, -inPoint.x, -inPoint.y, 0.0f);

self.transform = theTransform;
}

- (CAScrollLayer *)scrollLayer
{
CALayer *theLayer = self.superlayer;
while (theLayer && [theLayer isKindOfClass:[CAScrollLayer class]] == NO)
	{
	theLayer = theLayer.superlayer;
	}
return((CAScrollLayer *)theLayer);
}

@end
