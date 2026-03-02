#include "Menu.h"
#include "imgui.h"

static bool show_menu = true;
static bool enable_esp = false;
static float aim_fov = 90.0f;

void DrawMenu() {
    if (!show_menu)
        return;

    ImGui::SetNextWindowSize(ImVec2(400, 300), ImGuiCond_FirstUseEver);
    
    if (ImGui::Begin("Mod Menu by TheOnno | 0jumel (discord)", &show_menu)) {
        
        ImGui::Text("Welcome to ImGui");
        ImGui::Separator();
        
        ImGui::Checkbox("Enable ESP", &enable_esp);
        
        if (enable_esp) {
            ImGui::TextColored(ImVec4(0.0f, 1.0f, 0.0f, 1.0f), "[+] ESP is currently ACTIVE");
        }
        
        ImGui::SliderFloat("Aimbot FOV", &aim_fov, 0.0f, 180.0f);
        
        ImGui::Separator();
        
        ImGui::Text("Ready for Sideloadly");
        
        if (ImGui::Button("Close Menu")) {
            show_menu = false;
        }
    }
    
    ImGui::End();
}
