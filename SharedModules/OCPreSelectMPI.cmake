# This module is used to condition the selection of the MPI if OPENCMISS_MPI is set

set(_PRE_SELECT_MPI FALSE)
if (OPENCMISS_MPI)
    log("Pre-selecting MPI: ${OPENCMISS_MPI}")
    if (OPENCMISS_MPI IN_LIST _MNEMONICS)
        set(_PRE_SELECT_MPI TRUE)
    else ()
        message(FATAL_ERROR "Unknown MPI requested: ${OPENCMISS_MPI}, requested MPI must be one of ${_MNEMONICS}.")
    endif ()
endif ()

macro(find_mpi_implementation)
    log("Looking for an MPI ...")
    find_package(MPI QUIET)
    if (MPI_FOUND)
        determine_mpi_mnemonic(MPI_MNEMONIC)
        log("Looking for an MPI ... found ${MPI_MNEMONIC}")
    else ()
        log("Looking for an MPI ... not found")
    endif ()
endmacro()

clear_find_mpi_variables()
if (_PRE_SELECT_MPI)
    find_package(MPI QUIET)
    set(_mpi_implementation_found ${MPI_FOUND})
    set(_mpi_matched FALSE)
    while(NOT _mpi_matched AND _mpi_implementation_found)
        clear_find_mpi_variables()
        find_mpi_implementation()
        set(_mpi_implementation_found ${MPI_FOUND})
        if (MPI_FOUND)
            if ("${OPENCMISS_MPI}" STREQUAL "${MPI_MNEMONIC}")
                set(_mpi_matched TRUE)
            else ()
                foreach(_lang C CXX Fortran)
                    if (MPI_${_lang}_COMPILER)
                        get_filename_component(_dir "${MPI_${_lang}_COMPILER}" DIRECTORY)
                        list(APPEND CMAKE_IGNORE_PATH "${_dir}")
                    endif ()
                    list(REMOVE_DUPLICATES CMAKE_IGNORE_PATH)
                endforeach()
            endif ()
        endif ()
    endwhile()
    unset(CMAKE_IGNORE_PATH)
    if (NOT _mpi_matched)
        if (OPENCMISS_MPI STREQUAL "mpich")
            clear_find_mpi_variables()
            set(MPI_EXECUTABLE_SUFFIX .mpich)
            find_mpi_implementation()
        elseif (OPENCMISS_MPI STREQUAL "openmpi")
            clear_find_mpi_variables()
            set(MPI_EXECUTABLE_SUFFIX .openmpi)
            find_mpi_implementation()
        endif ()
    endif ()
endif ()
