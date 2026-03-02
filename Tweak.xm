#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

#import "imgui.h"
#import "imgui_impl_metal.h"
#import "Menu.h"

static id<MTLCommandQueue> g_commandQueue = nil;
static id<MTLDevice> g_device = nil;
static bool g_initialized = false;

%hook MTKView

- (void)drawRect:(CGRect)rect {
    %orig;

    if (!g_initialized) {
        g_device = self.device;
        if (!g_device) return;
        
        g_commandQueue = [g_device newCommandQueue];
        
        IMGUI_CHECKVERSION();
        ImGui::CreateContext();
        ImGuiIO& io = ImGui::GetIO(); (void)io;
        
        io.IniFilename = NULL;
        
        ImGui::StyleColorsDark();
        
        ImGui_ImplMetal_Init(g_device);
        
        g_initialized = true;
    }
    
    ImGuiIO& io = ImGui::GetIO();
    io.DisplaySize = ImVec2(self.bounds.size.width, self.bounds.size.height);
    
    CGFloat scale = self.contentScaleFactor ?: [UIScreen mainScreen].scale;
    io.DisplayFramebufferScale = ImVec2(scale, scale);

    id<MTLCommandBuffer> commandBuffer = [g_commandQueue commandBuffer];
    
    MTLRenderPassDescriptor* renderPassDescriptor = self.currentRenderPassDescriptor;
    if (renderPassDescriptor != nil) {
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        [renderEncoder pushDebugGroup:@"ImGui_RenderNode"];

        ImGui_ImplMetal_NewFrame(renderPassDescriptor);
        ImGui::NewFrame();
        
        DrawMenu();
        
        ImGui::Render();
        ImDrawData* draw_data = ImGui::GetDrawData();
        ImGui_ImplMetal_RenderDrawData(draw_data, commandBuffer, renderEncoder);
        
        [renderEncoder popDebugGroup];
        [renderEncoder endEncoding];
    }
    
    [commandBuffer commit];
}

%end


%hook UIWindow

- (void)sendEvent:(UIEvent *)event {
    if (g_initialized && event.type == UIEventTypeTouches) {
        ImGuiIO& io = ImGui::GetIO();
        NSSet *touches = [event allTouches];
        
        UITouch *touch = [touches anyObject];
        if (touch) {
            CGPoint location = [touch locationInView:touch.view];
            
            if (touch.phase == UITouchPhaseBegan) {
                io.AddMousePosEvent(location.x, location.y);
                io.AddMouseButtonEvent(0, true);
            } else if (touch.phase == UITouchPhaseMoved) {
                io.AddMousePosEvent(location.x, location.y);
            } else if (touch.phase == UITouchPhaseEnded || touch.phase == UITouchPhaseCancelled) {
                io.AddMousePosEvent(location.x, location.y);
                io.AddMouseButtonEvent(0, false);
            }
        }
    }
    
    %orig;
}

%end


%ctor {
    NSLog(@"[ImGui-Metal-Tweak] Loaded inside %%ctor. Ready to hook.");
}
