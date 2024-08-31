# Requires:
# - nada
macro(CheckOpenGLES)
  set(HAVE_OPENGLES FALSE)
  check_c_source_compiles("
      #include <GLES/gl.h>
      #include <GLES/glext.h>
      int main (int argc, char** argv) { return 0; }" HAVE_OPENGLES_V1)
  if(HAVE_OPENGLES_V1)
    set(HAVE_OPENGLES TRUE)
    set(SDL_VIDEO_OPENGL_ES 1)
    set(SDL_VIDEO_RENDER_OGL_ES 1)
  endif()
  check_c_source_compiles("
      #include <GLES2/gl2.h>
      #include <GLES2/gl2ext.h>
      int main (int argc, char** argv) { return 0; }" HAVE_OPENGLES_V2)
  if(HAVE_OPENGLES_V2)
    set(HAVE_OPENGLES TRUE)
    set(SDL_VIDEO_OPENGL_ES2 1)
    set(SDL_VIDEO_RENDER_OGL_ES2 1)
  endif()
endmacro()

macro(CheckLibUnwind)
  set(found_libunwind FALSE)
  set(_libunwind_src "#include <libunwind.h>\nint main() {unw_context_t context; unw_getcontext(&context); return 0;}")

  if(NOT found_libunwind)
    cmake_push_check_state()
    check_c_source_compiles("${_libunwind_src}" LIBC_HAS_WORKING_LIBUNWIND)
    cmake_pop_check_state()
    if(LIBC_HAS_WORKING_LIBUNWIND)
      set(found_libunwind TRUE)
    endif()
  endif()

  if(NOT found_libunwind)
    cmake_push_check_state()
    list(APPEND CMAKE_REQUIRED_LIBRARIES "unwind")
    check_c_source_compiles("${_libunwind_src}" LIBUNWIND_HAS_WORKINGLIBUNWIND)
    cmake_pop_check_state()
    if(LIBUNWIND_HAS_WORKINGLIBUNWIND)
      set(found_libunwind TRUE)
      list(APPEND EXTRA_TEST_LIBS unwind)
    endif()
  endif()

  if(NOT found_libunwind)
    set(LibUnwind_PKG_CONFIG_SPEC libunwind libunwind-generic)
    pkg_check_modules(PC_LIBUNWIND IMPORTED_TARGET ${LibUnwind_PKG_CONFIG_SPEC})
    if(PC_LIBUNWIND_FOUND)
      cmake_push_check_state()
      list(APPEND CMAKE_REQUIRED_LIBRARIES ${PC_LIBUNWIND_LIBRARIES})
      list(APPEND CMAKE_REQUIRED_INCLUDES ${PC_LIBUNWIND_INCLUDE_DIRS})
      check_c_source_compiles("${_libunwind_src}" PC_LIBUNWIND_HAS_WORKING_LIBUNWIND)
      cmake_pop_check_state()
      if(PC_LIBUNWIND_HAS_WORKING_LIBUNWIND)
        set(found_libunwind TRUE)
        list(APPEND EXTRA_TEST_LIBS ${PC_LIBUNWIND_LIBRARIES})
        list(APPEND EXTRA_TEST_INCLUDES ${PC_LIBUNWIND_INCLUDE_DIRS})
      endif()
    endif()
  endif()

  if(found_libunwind)
    list(APPEND EXTRA_TEST_DEFINES HAVE_LIBUNWIND_H)
  endif()
endmacro()
