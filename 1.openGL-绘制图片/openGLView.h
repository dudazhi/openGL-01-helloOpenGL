//
//  openGLView.h
//  1.openGL-绘制图片
//
//  Created by 技术部mac1 on 2017/9/25.
//  Copyright © 2017年 技术部mac1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
@interface openGLView : UIView
{
    CAEAGLLayer * _englLayer;
    EAGLContext * _context;
    GLuint _colorRenderBuffer;
    GLuint _positionSlot;
    GLuint _colorSlot;
    
}
@end
