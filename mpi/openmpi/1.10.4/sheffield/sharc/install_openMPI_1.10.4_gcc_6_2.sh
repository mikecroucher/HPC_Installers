#!/bin/bash

# This is a template script for building and installing software on ShARC.
# You should use it to document how you install things.
# You will need to configure any module loads the build needs and then 
# configure the variables for the build.
# This script will then create the directories you need and download and unzip
# the source in to the build dir.

############################# Error handling ###################################

handle_error () {
    errcode=$? # save the exit code as the first thing done in the trap function 
    echo "error $errorcode" 
    echo "the command executing at the
    time of the error was" echo "$BASH_COMMAND" 
    echo "on line ${BASH_LINENO[0]}"
    # do some error handling, cleanup, logging, notification $BASH_COMMAND
    # contains the command that was being executed at the time of the trap
    # ${BASH_LINENO[0]} contains the line number in the script of that command
    # exit the script or return to try again, etc.
    exit $errcode  # or use some other value or do return instead 
} 
trap handle_error ERR


############################# Module Loads ###################################

module load dev/gcc/6.2

############################## Variable Setup ################################
version=1.10.4
build_dir="/scratch/${USER}/openmpi_${version}"
prefix="/usr/local/packages/mpi/openmpi/${version}/gcc-6.2"


filename="openmpi-${version}.tar.gz"
baseurl="http://www.open-mpi.org/software/ompi/v1.10/downloads/"

##############################################################################
# This should not need modifying
##############################################################################

# Create the build dir

[[ -d $build_dir ]] || mkdir -p $build_dir
cd $build_dir

# Create the install directory and set permissions
#if [[ ! -d $prefix ]]; then
mkdir -p $prefix
chown ${USER}:app-admins $prefix
chmod 2775 $prefix
#fi 

# Download the source
if [[ -e $filename ]]; then
    echo "Install tarball exists. Download not required."                         
else                                                                            
    echo "Downloading source" 
    wget ${baseurl}/${filename}
fi

##############################################################################

##############################################################################
# Installation (Write the install script here)
##############################################################################

tar -xzf openmpi-${version}.tar.gz
cd openmpi-${version}

./configure --prefix=${prefix} --with-psm2
make -j16
make check
make install
