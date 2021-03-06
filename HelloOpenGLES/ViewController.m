//
//  ViewController.m
//  HelloOpenGLES
//
//  Created by Amit Gulati on 14/03/16.
//  Copyright © 2016 Amit Gulati. All rights reserved.
//

#import "ViewController.h"


float quad_vertices[] = {  0.5, 0.5, 0.0, 1.0, 0.0, 0.0, 1.0,  1, 0,
                          -0.5, 0.5, 0.0, 1.0, 0.0, 0.0, 1.0,  0, 0,
                           0.5, -0.5, 0.0, 1.0, 0.0, 0.0, 1.0, 1, 1,
                          -0.5, -0.5, 0.0, 1.0, 0.0, 0.0, 1.0, 0, 1};


@interface ViewController ()
-(void) initGL;
-(int) loadTexture:(NSString*) fileName;
@end

@implementation ViewController

-(int) loadTexture:(NSString *)fileName {
    //generate the texture ID
    GLuint texture;
    glGenTextures(1, &texture);
    
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    // 2
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte * spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,
                                                       CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    // 3
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    
    //bind to texture
    glBindTexture(GL_TEXTURE_2D, texture);
 
    //upload sprite image data to the texture objct
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    //specify the minification and maginfication parameters
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    
    //unbind from texture
    glBindTexture(GL_TEXTURE_2D, 0);
    free(spriteData);
    return texture;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //initialize the rendering context for OpenGL ES 2
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    //associate the context with the GLKView
    GLKView* view = (GLKView*)self.view;
    view.context = context;
    
    //make the context current or bind to the context
    [EAGLContext setCurrentContext:context];
    
    shaderHelper = [[ShaderHelper alloc] init];
    programObject = [shaderHelper createProgramObject];
    
    if( programObject < 0) {
        NSLog(@"Shader FaileD");
        return;
    } else {
        NSLog(@"Shader executable loaded successfully");
        //load the shader executable on GPU
        glUseProgram(programObject);
    }
    
    
    //get the index for attribute named "a_Position"
    positionIndex = glGetAttribLocation(programObject, "a_Position");
    colorIndex = glGetAttribLocation(programObject, "a_Color");
    textureCoordinateIndex = glGetAttribLocation(programObject, "a_TextureCoordinate");
    activeTexture1Index = glGetUniformLocation(programObject, "activeTexture1");
    activeTexture2Index = glGetUniformLocation(programObject, "activeTexture2");

    
    //initialize OpenGL state
    [self initGL];
}

-(void) initGL {
    
    //set the clear color
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClearDepthf(1.0);
    
    //enable texture mapping
    glEnable(GL_TEXTURE_2D);
    
    //upload texture datat ot the GPU
    textureID1 = [self loadTexture:@"image4.jpg"];
    textureID2 = [self loadTexture:@"earth.jpg"];
}

-(void) drawQuad {
    
    //make the texture unit 0 active
    glActiveTexture(GL_TEXTURE0);
    
    //bind the textute to active texture unit 0
    glBindTexture(GL_TEXTURE_2D, textureID1);
    
    //tell the fragment shader that texture unit 0 is active
    glUniform1i(activeTexture1Index, 0);
    
    // make the texture unit 1 active
    glActiveTexture(GL_TEXTURE1);
    //bind the texture to active texture unit 1
    glBindTexture(GL_TEXTURE_2D, textureID2);
    glUniform1i(activeTexture2Index, 1);
    
    //enable writing to the position variable
    glEnableVertexAttribArray(positionIndex);
    //enable writing to the color variable
    glEnableVertexAttribArray(colorIndex);
    glEnableVertexAttribArray(textureCoordinateIndex);
    
    
    
    glVertexAttribPointer(positionIndex, 3, GL_FLOAT, false, 36, quad_vertices);
    glVertexAttribPointer(colorIndex, 4, GL_FLOAT, false, 36, quad_vertices + 3);
    glVertexAttribPointer(textureCoordinateIndex, 2, GL_FLOAT, false, 36, quad_vertices + 7);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glDisableVertexAttribArray(positionIndex);
    glDisableVertexAttribArray(colorIndex);
    glDisableVertexAttribArray(textureCoordinateIndex);
    
}



-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect {
    //rendering function'
    
    //clear the color buffer
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    [self drawQuad];
    
    //flush the opengl pipeline so that the commands get sent to the GPU
    glFlush();
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
