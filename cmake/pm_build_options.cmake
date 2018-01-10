cmake_minimum_required(VERSION 3.8)

if(pm_build_options_included)
    return()
endif()
set(pm_build_options_included 1)

function(pm_set_build_options_windows target)
    target_compile_options("${target}" PRIVATE $<$<CONFIG:DEBUG>:/Od> $<$<NOT:$<CONFIG:DEBUG>>:/Ox>)
    #target_compile_options("${target}" /Ob2) # Inline function expansion

    # Disable C++ exceptions
    # by default /EHsc is set by cmake, here we remove it, a bit later in this function we use specific flags for WINDOWSPC, UWP and XB1
    # replace_compile_flags("/EHsc" "") # replace_compile_flags function is defined in CMakeMacros.cmake

    #if(pm_mscrt STREQUAL "mt")

    # Disable run-time type information (RTTI)
    # replace_compile_flags("/GR" "/GR-")

    target_compile_options("${target}" PRIVATE "/W4") # Set warning level 4
    target_compile_options("${target}" PRIVATE "/WX") # Treat warnings as errors
    target_compile_options("${target}" PRIVATE "/GR-") # Disable RTTI
    target_compile_options("${target}" PRIVATE "/EHsc") # C++ exceptions

    target_compile_options("${target}" PRIVATE "/MP") # Enable multi-processor compilation

    # Disable warning: This object file does not define any previously undefined public symbols, so it will not be used by any link operation that consumes this library
    target_link_libraries("${target}" PRIVATE "/ignore:4221") 

endfunction()


function(pm_set_build_options_linux target)
    target_compile_options("${target}" PRIVATE $<$<CONFIG:DEBUG>:-g>)
    target_compile_options("${target}" PRIVATE $<$<CONFIG:DEBUG>:-O0> $<$<NOT:$<CONFIG:DEBUG>>:-O3>) # optimization level

    target_compile_options("${target}" PRIVATE "-pthread") # Enable pthreads
    target_compile_options("${target}" PRIVATE "-fno-rtti") # Disable RTTI
    target_compile_options("${target}" PRIVATE "-Werror") # Treat warnings as errors

    target_compile_options("${target}" PRIVATE "-std=c++11") # Enable C++11 language, but only for c++ files
endfunction()


function(pm_set_build_options target)
    if(pm_platform_is_window)
        pm_set_build_options_windows("${target}")
    elseif(pm_platform_is_linux)
        pm_set_build_options_linux("${target}")
    endif()
endfunction()