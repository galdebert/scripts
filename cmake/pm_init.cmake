cmake_minimum_required(VERSION 3.8)

if(pm_init_included)
    return()
endif()
set(pm_init_included 1)

include("belit_utils")

#----------------------------------------------------------------------
# variables passed to cmake, and as such globals:
# CMAKE_GENERATOR         cmake -G "the generator"
# PM_BUILD                cmake -D PM_BUILD=buildstr
# PM_ROOT                 cmake -D PM_ROOT=rootdir

# globals extracted from PM_BUILD
# PM_BUILD =>
#   pm_platform  : "win", "linux", "android", "ios", "osx"...
#   pm_arch_bits : "32", "64"
#   pm_msvcrt    : "mt", "md", ""
#   pm_toolchain : "vc14", "gcc", "clang"

# PM_BUILD => pm_platform, pm_platform_is_xxxxxx
macro(pm_init_platform)
    if("${PM_BUILD}" MATCHES "win")
        set(pm_platform "win")
        set(pm_platform_is_windows 1)
        belit_assert_strequal("${CMAKE_SYSTEM_NAME}" "Windows")
    elseif("${PM_BUILD}" MATCHES "linux")
        set(pm_platform "linux")
        set(pm_platform_is_linux 1)
        belit_assert_strequal("${CMAKE_SYSTEM_NAME}" "Linux")
    elseif("${PM_BUILD}" MATCHES "osx")
        set(pm_platform "osx")
        set(pm_platform_is_osx 1)
        belit_assert_strequal("${CMAKE_SYSTEM_NAME}" "Darwin")
    elseif("${PM_BUILD}" MATCHES "android")
        set(pm_platform "android")
        set(pm_platform_is_android 1)
        belit_assert_strequal("${CMAKE_SYSTEM_NAME}" "Android")
    elseif("${PM_BUILD}" MATCHES "ios")
        set(pm_platform "ios")
        set(pm_platform_is_ios 1)
        #belit_assert_strequal("${CMAKE_SYSTEM_NAME}" "ios")
    endif()
endmacro()

# PM_BUILD => pm_arch_bits, pm_arch_bits_is_32, pm_arch_bits_is_64
macro(pm_init_arch_bits)
    if("${PM_BUILD}" MATCHES "32")
        set(pm_arch_bits "32")
        set(pm_arch_bits_is_32 1)
        set(pm_arch_bits_is_64 0)
    elseif("${PM_BUILD}" MATCHES "64")
        set(pm_arch_bits "64")
        set(pm_arch_bits_is_32 1)
        set(pm_arch_bits_is_64 0)
    endif()
endmacro()

# PM_BUILD => pm_msvcrt
macro(pm_init_msvcrt)
    set(pm_msvcrt "")
    if (pm_platform_is_windows)
        set(pm_msvcrt "mt")
        if("${PM_BUILD}" MATCHES "md")
            set(pm_msvcrt "md")
        endif()
    endif()
endmacro()

# Visual Studio Version          MSVC Toolset Version              _MSC_VER
# VS2015 and updates 1, 2, & 3   v140 in VS; version 14.00         1900
# VS2017, version 15.1 & 15.2    v141 in VS; version 14.10         1910
# VS2017, version 15.3 & 15.4    v141 in VS; version 14.11         1911
# VS2017, version 15.5           v141 in VS; version 14.12         1912

# pm_toolchain_is_vc, pm_toolchain_is_xcode, pm_toolchain, pm_toolchain_minor
macro(pm_init_toolchain)
    if("${CMAKE_GENERATOR}" MATCHES "Visual Studio")
        if(MSVC_VERSION GREATER 1900 OR MSVC_VERSION EQUAL 1900)
            set(pm_toolchain "vc14")
            set(pm_toolchain_is_vc 1)
            if(MSVC_VERSION EQUAL 1900)
                set(pm_toolchain_minor "00")
            elseif(MSVC_VERSION EQUAL 1910)
                set(pm_toolchain_minor "10")
            elseif(MSVC_VERSION EQUAL 1911)
                set(pm_toolchain_minor "11")
            elseif(MSVC_VERSION EQUAL 1912)
                set(pm_toolchain_minor "12")
            else()
                belit_error("MSVC_VERSION ${MSVC_VERSION} is not supported")
            endif()
        else()
            belit_error("MSVC_VERSION ${MSVC_VERSION} is not supported")
        endif()
    elseif("${CMAKE_GENERATOR}" MATCHES "Xcode")
        set(pm_toolchain "xcode")
        set(pm_toolchain_is_xcode 1)
    endif()
endmacro()


# pm_ndk_root
macro(pm_init_ndk_root)
    if(EXISTS "$ENV{NDK_ROOT}" AND IS_DIRECTORY "$ENV{NDK_ROOT}")
        set(pm_ndk_root "$ENV{NDK_ROOT}")
        string(REGEX REPLACE "\\\\" "/" pm_ndk_root "${pm_ndk_root}")
    endif()
endmacro()

#----------------------------- pm_init_build_configs("debug;release") -----------------------------
# macro(pm_init_build_configs build_configs)
# 	#set(CMAKE_CONFIGURATION_TYPES ${build_configs} CACHE STRING "build_configs" FORCE) # hmmm why would we put that inthe cache ?
# 	set(CMAKE_CONFIGURATION_TYPES ${build_configs})

# 	# foreach(config ${CMAKE_CONFIGURATION_TYPES})
# 	# 	string(TOUPPER "${config}" config_upper)
# 	# 	set("CMAKE_CXX_FLAGS_${config_upper}" "")           # required otherwise error "Missing variable is: CMAKE_CXX_FLAGS_DEV
# 	# 	set("CMAKE_EXE_LINKER_FLAGS_${config_upper}" "")    # required otherwise error "Missing variable is: CMAKE_EXE_LINKER_FLAGS_DEV
# 	# 	set("CMAKE_MODULE_LINKER_FLAGS_${config_upper}" "") # required otherwise error "Missing variable is: CMAKE_MODULE_LINKER_FLAGS_DEV
# 	# 	set("CMAKE_SHARED_LINKER_FLAGS_${config_upper}" "") # required otherwise error "Missing variable is: CMAKE_SHARED_LINKER_FLAGS_DEV
# 	# endforeach()
# endmacro()


#----------------------------- pm_init("debug;release") -----------------------------
macro(pm_init configs)
    pm_init_platform()
    pm_init_arch_bits()
    pm_init_msvcrt()
    pm_init_toolchain()
    pm_init_ndk_root()
    set(CMAKE_CONFIGURATION_TYPES ${configs}) # is enough pm_init_build_configs("${build_configs}")
endmacro()


