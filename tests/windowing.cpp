#include <cstdio>

#ifdef __WIN32
	#include <extlib/include/sdl-mingw/SDL.h>
	//#include <extlib/include/sdl-mingw/SDL_syswm.h>
#else 
	#if __APPLE__
		#include <extlib/include/sdl-osx/SDL.h>
		//#include <extlib/include/sdl-osx/SDL_syswm.h>
	#else
		#include <SDL3/SDL.h>
	#endif
#endif

#define BX_CONFIG_DEBUG 1
#include <bx/bx.h>
#include <bx/math.h>
#include <bx/allocator.h>
#include <extlib/include/bgfx/bgfx.h>
#define BGFXH_IMPL
#include <extlib/include/bgfxh/bgfxh.h>
#include <extlib/include/bgfxh/sdlWindow.h>



int main(int argv, char** args) {
	printf("Window test!\n");
	
	const int ww = 400;
	const int wh = 300;
	
	const uint32_t m_resetFlags = BGFX_RESET_MAXANISOTROPY;//BGFX_RESET_VSYNC |  | BGFX_RESET_FLIP_AFTER_RENDER ;// BGFX_RESET_MSAA_X4;  | 
	bgfx::Init init;
		init.type     = bgfx::RendererType::Count;
		init.deviceId = 0;
		init.vendorId = BGFX_PCI_ID_NONE;
		init.debug  = true;
		init.profile = true;
		init.resolution.width  = ww;
		init.resolution.height = wh;
		init.resolution.reset  = m_resetFlags;
	
	SDL_Window* mWindow = SDL_CreateWindow("Turf 2 Windowing Test", ww, wh, SDL_WINDOW_RESIZABLE);
	bgfxh::initSdlWindowAndBgfx (mWindow, &init);
	
	bgfxh::init (ww, wh, "shaders/" + bgfxh::getShaderDirectoryFromRenderType() + "/");
	
	bool wantsExit = false;
	while (!wantsExit) {
		SDL_Event event;
		while (SDL_PollEvent(&event)) {
			switch (event.type) {
				case SDL_EVENT_QUIT:
					wantsExit = true;
					break;

				case SDL_EVENT_WINDOW_CLOSE_REQUESTED:
					wantsExit = true;
					break;
			
				case SDL_EVENT_KEY_DOWN: {
					printf("Key down!");
					}
					break;
					
				case SDL_EVENT_MOUSE_BUTTON_DOWN: {
					printf("Mouse down!");
					}
				break;
				}
			}
		
		// render a blank screen
		bgfxh::initView2D(0, "v0", ww, wh, BGFX_INVALID_HANDLE);
		bgfx::dbgTextClear();
		bgfx::setDebug(BGFX_DEBUG_TEXT);
		bgfx::dbgTextPrintf(0,0,0x0f, "It works!");
		bgfx::dbgTextPrintf(0,1,0x1f, "Close the window to end the test!");	
		bgfx::touch(0);
		bgfx::frame();
		}

	bgfxh::deInit();
	bgfx::shutdown();
		
	SDL_DestroyWindow(mWindow);
	printf("Window test exited normally!\n");
	return 1;
	}
