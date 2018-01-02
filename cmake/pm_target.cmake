cmake_minimum_required(VERSION 3.8)

# 2 ways to set target-props:
# set_target_properties(target1 target2 ... PROPERTIES prop1 value1 prop2 value2 ...)
# set_property(TARGET target PROPERTY value1 value2 ...)

function(pm_set_binaries_output_paths target)
	foreach(config ${CMAKE_CONFIGURATION_TYPES})
		string(TOUPPER "${config}" config_upper)

		set(bin_dir "${PM_ROOT}/bin/${PM_BUILD}/${config}")
		set(lib_dir "${PM_ROOT}/lib/${PM_BUILD}/${config}")

		# .dll
		set_property(TARGET "${target}" PROPERTY "RUNTIME_OUTPUT_DIRECTORY_${config_upper}" "${bin_dir}")
		set_property(TARGET "${target}" PROPERTY "RUNTIME_OUTPUT_NAME_${config_upper}" "${target}")

		# .lib
		set_property(TARGET "${target}" PROPERTY "ARCHIVE_OUTPUT_DIRECTORY_${config_upper}" "${lib_dir}")
		set_property(TARGET "${target}" PROPERTY "ARCHIVE_OUTPUT_NAME_${config_upper}" "${target}")

		# PDB corresponds to the /pdb linker option, creates a file in the bin dir
		set_property(TARGET "${target}" PROPERTY "PDB_OUTPUT_DIRECTORY_${config_upper}" "${bin_dir}")
		set_property(TARGET "${target}" PROPERTY "PDB_NAME_${config_upper}" "${target}")

		# COMPILE_PDB corresponds to the /Fd compiler option, creates a file in the lib dir
		set_property(TARGET "${target}" PROPERTY "COMPILE_PDB_OUTPUT_DIRECTORY_${config_upper}" "$lib_dir}")
		set_property(TARGET "${target}" PROPERTY "COMPILE_PDB_NAME_${config_upper}" "${target}")
	endforeach()
endfunction()


#----------------------------- pm_platform_specific_target_properties -----------------------------
# function(pm_platform_specific_target_properties target)
#     if(pm_toolchain_is_vc)
#         set_target_properties("${target}" PROPERTIES COMPILE_PDB_NAME "${target}") # COMPILE_PDB_NAME corresponds to the /Fd compiler option, creates a file in the lib dir
#         set_target_properties("${target}" PROPERTIES PDB_NAME "${target}") # PDB_NAME corresponds to the /pdb linker option, creates a file in the bin dir
#     endif()
# endfunction()


#----------------------------- pm_exe -----------------------------
function(pm_exe target sources include_dirs folder)
    add_executable("${target}" ${sources})

    target_include_directories("${target}" PRIVATE ${include_dirs})

    set_property(TARGET "${target}" PROPERTY FOLDER "${folder}")
    pm_set_binaries_output_paths("${target}")

endfunction()


#------------------------------- pm_shared_lib -------------------------------
function(pm_shared_lib target sources include_dirs folder)
    add_library("${target}" SHARED ${sources})

    target_include_directories("${target}" PUBLIC ${include_dirs})

    set_property(TARGET "${target}" PROPERTY FOLDER "${folder}")
    pm_set_binaries_output_paths("${target}")
endfunction()


#------------------------------- pm_static_lib -------------------------------
function(pm_static_lib lib sources include_dirs folder)
    add_library("${target}" STATIC ${sources})

    target_include_directories("${target}" PUBLIC ${include_dirs})

    set_property(TARGET "${target}" PROPERTY FOLDER "${folder}")
    pm_set_binaries_output_paths("${target}")
endfunction()

