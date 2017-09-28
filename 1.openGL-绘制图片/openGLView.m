//
//  openGLView.m
//  1.openGL-绘制图片
//
//  Created by 技术部mac1 on 2017/9/25.
//  Copyright © 2017年 技术部mac1. All rights reserved.
//

#import "openGLView.h"

@implementation openGLView


#pragma mark - 方法的调用
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
        [self setupContext];
        [self setupRenderBuffer];
        [self setupFramebuffer];
        [self compileShaders];
        [self setupVBOs];
        [self render];
    }
    return self;
}



#pragma mark - 方法的定义和实现
//1.设置layer class为CAEAGLLayer
+(Class)layerClass
{
    return [CAEAGLLayer class];
}

//2.设置layer不透明
-(void)setupLayer
{
    _englLayer = (CAEAGLLayer*)self.layer;
    _englLayer.opaque = YES;
    _englLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking:[NSNumber numberWithBool:NO],kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8};
}

//3.创建openGL 上下文
-(void)setupContext{
    _context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_context];
}

//4.创建渲染缓冲区render buffer
-(void)setupRenderBuffer{
    glGenRenderbuffers(1, &_colorRenderBuffer);//调用glGenRenderbuffers来创建一个新的render buffer object。这里返回一个唯一的integer来标记render buffer（这里把这个唯一值赋值到_colorRenderBuffer）
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);//  调用glBindRenderbuffer ，告诉这个OpenGL：我在后面引用GL_RENDERBUFFER的地方，其实是想用_colorRenderBuffer。其实就是告诉OpenGL，我们定义的buffer对象是属于哪一种OpenGL对象
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_englLayer];// 把渲染缓存绑定到渲染图层上CAEAGLLayer，并为它分配一个共享内存。 并且会设置渲染缓存的格式，和宽度
}

//5.创建帧缓冲区
-(void)setupFramebuffer{
    GLuint frameBuffer;
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
}

//6.创建着色器程序，创建着色器（1.编译着色器代码，2.创建着色器，3.编译着色器）
//编译vertex shader 和frament shader
-(void)compileShaders{
    //1.创建vertex object
    GLuint vertexShader = [self compileShader:@"SimpleVertex" withType:GL_VERTEX_SHADER];
    //2.创建片元着色器
    GLuint fragmentShader = [self compileShader:@"SimpleFragment" withType:GL_FRAGMENT_SHADER];
    //3.创建着色器程序
    GLuint program = glCreateProgram();
    //4.绑定着色器
    //绑定定点着色器
    glAttachShader(program, vertexShader);
    //绑定片段着色器
    glAttachShader(program, fragmentShader);
    //链接程序
    glLinkProgram(program);
    GLint linkSuccess;
    glGetProgramiv(program, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(program, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"---%@", messageString);
        exit(1);
    }
    //启动程序
    glUseProgram(program);
    //获取顶点着色器传入的变量指针
    _positionSlot = glGetAttribLocation(program, "Position");
    _colorSlot = glGetAttribLocation(program, "SourceColor");
    //启动这些数据
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
}
//7.创建VBO
-(void)setupVBOs{
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
}
//7.创建纹理对象
//8.yuv转rgb绘制纹理
//9.渲染缓存区到屏幕
//10.清理内存
-(void)render{
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);//设置一个RGB颜色和透明度，接下来会用这个颜色涂满全屏.
   glClear(GL_COLOR_BUFFER_BIT);//用来指定要用清屏颜色来清除由mask指定的buffer，mask可以是 GL_COLOR_BUFFER_BIT，GL_DEPTH_BUFFER_BIT和GL_STENCIL_BUFFER_BIT的自由组合。
   
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);//   调用glViewport 设置UIView中用于渲染的部分
    
    /*  调用glVertexAttribPointer来为vertex shader的两个输入参数配置两个合适的值。
     
     第二段这里，是一个很重要的方法，让我们来认真地看看它是如何工作的：
     
     ·第一个参数，声明这个属性的名称，之前我们称之为glGetAttribLocation
     
     ·第二个参数，定义这个属性由多少个值组成。譬如说position是由3个float（x,y,z）组成，而颜色是4个float（r,g,b,a）
     
     ·第三个，声明每一个值是什么类型。（这例子中无论是位置还是颜色，我们都用了GL_FLOAT）
     
     ·第四个，嗯……它总是false就好了。
     
     ·第五个，指 stride 的大小。这是一个种描述每个 vertex数据大小的方式。所以我们可以简单地传入 sizeof（Vertex），让编译器计算出来就好。
     
     ·最后一个，是这个数据结构的偏移量。表示在这个结构中，从哪里开始获取我们的值。Position的值在前面，所以传0进去就可以了。而颜色是紧接着位置的数据，而position的大小是3个float的大小，所以是从 3 * sizeof(float) 开始的。*/
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), 0);
   
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (GLvoid*) (sizeof(float) *3));
    
    /* 调用glDrawElements ，它最后会在每个vertex上调用我们的vertex shader，以及每个像素调用fragment shader，最终画出我们的矩形。
     
     它也是一个重要的方法，我们来仔细研究一下：
     
     ·第一个参数，声明用哪种特性来渲染图形。有GL_LINE_STRIP 和 GL_TRIANGLE_FAN。然而GL_TRIANGLE是最常用的，特别是与VBO 关联的时候。
     
     ·第二个，告诉渲染器有多少个图形要渲染。我们用到C的代码来计算出有多少个。这里是通过个 array的byte大小除以一个Indice类型的大小得到的。
     
     ·第三个，指每个indices中的index类型
     
     ·最后一个，在官方文档中说，它是一个指向index的指针。但在这里，我们用的是VBO，所以通过index的array就可以访问到了（在GL_ELEMENT_ARRAY_BUFFER传过了），所以这里不需要.*/
    glDrawElements(GL_TRIANGLES, sizeof(indices)/sizeof(indices[0]),
                   GL_UNSIGNED_BYTE, 0);
    [_context presentRenderbuffer:GL_RENDERBUFFER];

}

#pragma mark - 顶点数据
/*
 1 一个用于跟踪所有顶点信息的结构Vertex （目前只包含位置和颜色。）
 
 2 定义了以上面这个Vertex结构为类型的array。
 
 3 一个用于表示三角形顶点的数组。
 */
typedef struct{
    float Position[3];
    float Color[4];
}Vertex;
const Vertex Vertices[]={
    {{1, -1, 0}, {1, 0, 0, 1}},
    {{1, 1, 0}, {0, 1, 0, 1}},
    {{-1, 1, 0}, {0, 0, 1, 1}},
    {{-1, -1, 0}, {0, 0, 0, 1}}
};
const GLubyte indices[]={
    0,1,2,
    2,3,0
};

#pragma mark - 封装的方法

//初始化着色器
- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    //1.加载文件路径
    NSString *shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"glsl"];
    NSError * error;
    NSString * shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"%@",error.localizedDescription);
        exit(1);
    }
    
    //2.获取指向着色器对象的句柄
    GLuint shaderHandle = glCreateShader(shaderType);
    if (shaderHandle == 0) {
        NSLog(@"初始化着色器具柄失败");
    }else{
        NSLog(@"初始化着色器具柄成功");
    }
    
    //3.加载着色器源码
    const char * shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    //4.编译着色器
     glCompileShader(shaderHandle);
    //5.检查是否完成
    GLint complite ;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &complite);
    if (complite == 0) {
        
        //没有完成就直接删除着色器
//         NSLog(@"初始化着色器失败");
//        glDeleteShader(shaderHandle);
//        return 0;
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"-------%@", messageString);
        exit(1);
    }
    return  shaderHandle;
}



@end
