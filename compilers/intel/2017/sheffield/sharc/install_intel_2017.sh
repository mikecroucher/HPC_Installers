#!/bin/bash
# Install 'Intel Parallel Studio XE 2017 Composer Edition' on sharc

###############
# Set variables
###############
export VERS=2017
# Directory containing tarball to store downloaded tarball and build logs
export MEDIA_DIR="/usr/local/media/protected/intel/${VERS}"
export TMPDIR="${TMPDIR:-/tmp}"
# Store unpacked source files
export SOURCE_DIR="${TMPDIR}/${USER}/intel/${VERS}"
export TARBALL_FNAME="parallel_studio_xe_${VERS}_composer_edition.tgz"
export APPLICATION_ROOT="/usr/local/packages"
export INSTALL_ROOT_DIR="${APPLICATION_ROOT}/dev/intel"
# Install in this dir
export INSTALL_DIR="${INSTALL_ROOT_DIR}/${VERS}/binary"
# License file (contains details of license server)
export LIC_FPATH="/usr/local/packages/dev/intel/license.lic"

# Mapping from modulefile sources to destinations
declare -A modfile_dests_map
MODFILE_DEST_ROOT="/usr/local/modulefiles/"
modfile_dests_map["${PWD}/compilers_modulefile"] = "${MODFILE_DEST_ROOT}/dev/intel-compilers/${VERS}/binary"
modfile_dests_map["${PWD}/daal_modulefile"] = "${MODFILE_DEST_ROOT}/libs/intel-daal/${VERS}/binary"
modfile_dests_map["${PWD}/ipp_modulefile" = "${MODFILE_DEST_ROOT}/libs/intel-ipp/${VERS}/binary"
modfile_dests_map["${PWD}/mkl_modulefile" = "${MODFILE_DEST_ROOT}/libs/intel-mkl/${VERS}/binary"
modfile_dests_map["${PWD}/tbb_modulefile" = "${MODFILE_DEST_ROOT}/libs/intel-tbb/${VERS}/binary"

################
# Error handling
################
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

##############
# Untar source
##############
mkdir -p $SOURCE_DIR
cd ${SOURCE_DIR}
#if [[ -e ./.untar_complete ]]; then
#    echo "Directory already untarred. Moving on"
#else
#    echo "Untarring Intel Parallel Studio"
    tar xzf ${MEDIA_DIR}/${TARBALL_FNAME}
#    touch ./.untar_complete
#fi
extracted_dir=$(basename $TARBALL_FNAME .tgz)
cd $extracted_dir

###########
# Configure
###########
sed -e "s:.*ACCEPT_EULA=.*:ACCEPT_EULA=accept:" \
    -e "s:.*CONTINUE_WITH_OPTIONAL_ERROR=.*:CONTINUE_WITH_OPTIONAL_ERROR=no:" \
    -e "s:.*PSET_INSTALL_DIR=.*:PSET_INSTALL_DIR=${INSTALL_DIR}:" \
    -e "s:.*ACTIVATION_LICENSE_FILE=.*:ACTIVATION_LICENSE_FILE=${LIC_FPATH}:" \
    -e "s:.*PSET_MODE=.*:PSET_MODE=install:" \
    -e "s:.*ACTIVATION_TYPE=.*:ACTIVATION_TYPE=license_server:" \
    -e "s:.*SIGNING_ENABLED=.*:SIGNING_ENABLED=no:" \
    silent.cfg > silent.cfg.custom

#########
# Install
#########
mkdir -p $INSTALL_DIR
# Try to install but if an install previously failed then
# try to repair the install instead
./install.sh --silent silent.cfg.custom --user-mode --tmp-dir ${TMPDIR} || \
    sed -i -e "s:.*PSET_MODE=.*:PSET_MODE=repair:" silent.cfg.custom && \
    ./install.sh --silent silent.cfg.custom --user-mode --tmp-dir ${TMPDIR} 

#####################
# Install modulefiles
#####################

for modfile_src in ${!modfile_dests_map[@]}; do
    modfile_dest=${modfile_dests_map[${modfile_src}]}
    mkdir -m 2775 $modfile_dest
    cp $modfile_src $modfile_dest
done

#################
# Set permissions
#################
chown -R ${USER}:app-admins ${INSTALL_DIR} 
chmod -R g+w ${INSTALL_DIR} 

for modfile_src in ${!modfile_dests_map[@]}; do
    modfile_dest=${modfile_dests_map[${modfile_src}]}
    chown -R ${USER}:app-admins $modfile_dest
    chmod -R g+w $modfile_dest
done
