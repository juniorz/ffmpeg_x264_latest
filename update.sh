#!/bin/bash
# ffmpegup
# a simple script to update ffmpeg and x264 from the SVNs and git
# Creative Commons Attribution-Non-Commercial-Share Alike 2.0
# taken from the excellet tutorial found here:
# http://ubuntuforums.org/showthread.php?t=786095&highlight=ffmpeg+x264+latest
# all props to fakeoutdoorsman, not me
# check http://code.google.com/p/x264-ffmpeg-up-to-date/ for updates
# also check http://www.prupert.co.uk (that's me - rupert plumridge) for other updates and new scripts.
# if you have any questions, please contact me via the code.google or www.prupert.co.uk sites.
######################################
# ver 1.9 by rupert plumridge
# 6th November 2010
# update to fix maverick support - stupid error on my part
######################################
# ver 1.8 by rupert plumridge
# 10th August 2010
# update to include maverick install and some better error detection (now detects all errors, not just exit 1 code 1)
######################################
######################################
# ver 1.7 by rupert plumridge
# 28th July 2010
# added better error checking and information to the karmic and lucid methods
# the script will now tell you what part of the compile failed and exit when that part fails - ignore the final part of the message that says everything was done
# I havne't figured out how to stop that message yet ;)
######################################
# ver 1.6 by rupert plumridge
# 8th July 2010
# added ffplay to hash command for karmic 
# added multicore make ability as kindly suggested by Louwrentius, May 30, 2010: see here: http://code.google.com/p/x264-ffmpeg-up-to-date/issues/detail?id=5
# removed the grepping of the svn log info since it wasn't that informative and didn't always work
######################################
# ver 1.5 by rupert plumridge
# 23 June 2010
# removed the --enable-libfaad option as it is no longer recquired and caused build errors
######################################
# ver 1.4 by rupert plumridge
# 14th May 2010
# Added the ability to create a .conf configuration file when this script is run.
# This allows this script to be run with no user interaction required, and removing all the silly questions. 
# Also added the option to copy the .debs created by checkinstall for the newly built x264 and ffmpeg to a location of your choice.
# This allows you to install the latest version of the two programs on other computers running the same distro as the one you run this script on.
# Added a CC license for funsies. 
# Added some decent grammer to these comments.
######################################
# ver 1.3 by rupert plumridge
# 30th April 2010
# Fixed missing "#", thanks FRED.
######################################
# ver 1.2BETA by rupert plumridge
# 18th April 2010
# Changed to suport Linux Mint varients as well.
######################################
# ver 1.1BETA by rupert plumridge
# 16th April 2010
# Changed so it updates based on distro, to keep the pkg version correct
######################################
# ver 1.0BETA by rupert plumridge
# 16th April 2010
# First version released.
# This is a BETA script, so it may not work as expected and may destroy the world, including your computer..use at your own risk.

#User Editable Variables
# please edit the following variable if you haven't installed ffmpeg and x264 via my other script and the source for each app wasn't installed in the location below
INSTALL="/usr/local/src"
# location of log file
LOG=/var/log/ffmpegup.log
CONF="/etc/ffmpegup.conf"



########################################
# do not edit anything beyond this line, unless you know what you are doing
########################################

# first some error checking
set -o nounset
set -o errexit
set -o pipefail


###############
# list of all the functions in the script
###############


##############
#UBUNTU FUNCTIONS
##############
#maverick install
#install x264

NO_OF_CPUCORES=`grep -c ^processor /proc/cpuinfo 2>/dev/null`
if [ ! "$?" = "0" ]
then
    NO_OF_CPUCORES=2
fi

maverick_x264 ()
{
apt-get -y remove ffmpeg x264 libx264-dev 2> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "x264: error removing old versions"
	exit 1
fi
cd "$INSTALL"/x264
if [ "$?" != 0 ] ; then
	echo "x264: error navigating to x264 directory"
	exit 1
fi
make -j $NO_OF_CPUCORES distclean 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "x264: error running make distclean"
	exit 1
fi
git pull 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "x264: error with git pull"
	exit 1
fi
./configure 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "x264: error configuring"
	exit 1
fi
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "x264: error making"
	exit 1
fi
sudo checkinstall --pkgname=x264 --pkgversion "2:0.`grep X264_BUILD x264.h -m1 |cut -d' ' -f3`.`git rev-list HEAD | wc -l`+git`git rev-list HEAD -n 1 | head -c 7`" --backup=no --deldoc=yes --fstrans=no --default 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "x264: error with checkinstall"
	exit 1
fi
}
#install ffmpeg
maverick_ffmpeg ()
{
cd "$INSTALL"/ffmpeg
if [ "$?" != 0 ] ; then
	echo "ffmpeg: error navigating to directory"
	exit 1
fi
make -j $NO_OF_CPUCORES clean 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES distclean 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "ffmpeg: error running make distclean"
	exit 1
fi
svn update 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "ffmpeg: error running svn update"
	exit 1
fi
./configure --enable-gpl --enable-version3 --enable-nonfree --enable-postproc --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libxvid --enable-x11grab 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "ffmpeg: error running configure"
	exit 1
fi
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "ffmpeg: error running make"
	exit 1
fi
sudo checkinstall --pkgname=ffmpeg --pkgversion "4:SVN-r`LANG=C svn info | grep Revision | awk '{ print $NF }'`" --backup=no --deldoc=yes --fstrans=no --default 2>> $LOG >> $LOG

if [ "$?" != 0 ] ; then
	echo "ffmpeg: error running checkinstall"
	exit 1
fi
hash x264 ffmpeg ffplay 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "ffmpeg: error running hash"
	exit 1
fi
REVISION=$(svn info | grep Revision | awk '{print $2}') 2>> $LOG >> $LOG
echo
echo ffmpeg is at revision $REVISION
}

#lucid install
lucid_x264 ()
{
apt-get -y remove ffmpeg x264 libx264-dev 2> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "x264: error removing old versions"
	exit 1
fi
cd "$INSTALL"/x264
if [ "$?" != 0 ] ; then
	echo "x264: error navigating to x264 directory"
	exit 1
fi
make -j $NO_OF_CPUCORES distclean 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "x264: error running make distclean"
	exit 1
fi
git pull 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "x264: error with git pull"
	exit 1
fi
./configure 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "x264: error configuring"
	exit 1
fi
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "x264: error making"
	exit 1
fi
checkinstall --pkgname=x264 --pkgversion "2:0.`grep X264_BUILD x264.h -m1 | cut -d' ' -f3`.`git rev-list HEAD | wc -l`+git`git rev-list HEAD -n 1 | head -c 7`" --backup=no --default 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "x264: error with checkinstall"
	exit 1
fi
hash x264 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "x264: error with hash"
	exit 1
fi
}
#install ffmpeg
lucid_ffmpeg ()
{
cd "$INSTALL"/ffmpeg
if [ "$?" != 0 ] ; then
	echo "ffmpeg: error navigating to directory"
	exit 1
fi
make -j $NO_OF_CPUCORES clean 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES distclean 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "ffmpeg: error running make distclean"
	exit 1
fi
svn update 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "ffmpeg: error running svn update"
	exit 1
fi
./configure --enable-gpl --enable-version3 --enable-nonfree --enable-postproc --enable-pthreads --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libx264 --enable-libxvid --enable-x11grab 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "ffmpeg: error running configure"
	exit 1
fi
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "ffmpeg: error running make"
	exit 1
fi
checkinstall --pkgname=ffmpeg --pkgversion "4:SVN-r`svn info | grep Revision | awk '{ print $NF }'`" --backup=no --default 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "ffmpeg: error running checkinstall"
	exit 1
fi
hash ffmpeg 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "ffmpeg: error running hash"
	exit 1
fi
REVISION=$(svn info | grep Revision | awk '{print $2}') 2>> $LOG >> $LOG
echo
echo ffmpeg is at revision $REVISION
}


#karmic install
#install x264
karmic_x264 ()
{
apt-get -y remove ffmpeg x264 libx264-dev 2> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "x264: error removing old versions"
	exit 1
fi
cd "$INSTALL"/x264
if [ "$?" != 0 ] ; then
	echo "x264: error navigating to x264 directory"
	exit 1
fi
make -j $NO_OF_CPUCORES distclean 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "x264: error running make distclean"
	exit 1
fi
git pull 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "x264: error with git pull"
	exit 1
fi
./configure 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "x264: error configuring"
	exit 1
fi
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "x264: error making"
	exit 1
fi
checkinstall --pkgname=x264 --pkgversion "1:0.svn`date +%Y%m%d`+`git rev-list HEAD -n 1 | head -c 7`" --backup=no --default 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "x264: error with checkinstall"
	exit 1
fi
}
#install ffmpeg
karmic_ffmpeg ()
{
cd "$INSTALL"/ffmpeg
if [ "$?" != 0 ] ; then
	echo "ffmpeg: error navigating to directory"
	exit 1
fi
make -j $NO_OF_CPUCORES clean 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES distclean 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "ffmpeg: error running make distclean"
	exit 1
fi
svn update 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "ffmpeg: error running svn update"
	exit 1
fi
./configure --enable-gpl --enable-version3 --enable-nonfree --enable-postproc --enable-pthreads --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libx264 --enable-libxvid --enable-x11grab 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "ffmpeg: error running configure"
	exit 1
fi
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "ffmpeg: error running make"
	exit 1
fi
checkinstall --pkgname=ffmpeg --pkgversion "4:0.5+svn`date +%Y%m%d`" --backup=no --default 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "ffmpeg: error running checkinstall"
	exit 1
fi
hash ffmpeg ffplay 2>> $LOG >> $LOG
if [ "$?" != 0 ] ; then
	echo "ffmpeg: error running hash"
	exit 1
fi
REVISION=$(svn info | grep Revision | awk '{print $2}') 2>> $LOG >> $LOG
echo
echo ffmpeg is at revision $REVISION
}


#jaunty install
#install x264
jaunty_x264 ()
{
apt-get -y remove ffmpeg x264 libx264-dev 2> $LOG >> $LOG
cd "$INSTALL"/x264
make -j $NO_OF_CPUCORES distclean 2>> $LOG >> $LOG
git pull 2>> $LOG >> $LOG
./configure 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --fstrans=no --install=yes --pkgname=x264 --pkgversion "1:0.svn`date +%Y%m%d`-0.0ubuntu1" --backup=no --default 2>> $LOG >> $LOG
}
#install ffmpeg
jaunty_ffmpeg ()
{
cd "$INSTALL"/ffmpeg
make -j $NO_OF_CPUCORES clean 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES distclean 2>> $LOG >> $LOG
svn update 2>> $LOG >> $LOG
./configure --enable-gpl --enable-version3 --enable-nonfree --enable-postproc --enable-pthreads --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libx264 --enable-libxvid --enable-x11grab 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --fstrans=no --install=yes --pkgname=ffmpeg --pkgversion "3:0.svn`date +%Y%m%d`-12ubuntu3" --backup=no --default 2>> $LOG >> $LOG
hash ffmpeg 2>> $LOG >> $LOG
REVISION=$(svn info | grep Revision | awk '{print $2}') 2>> $LOG >> $LOG
echo
echo ffmpeg is at revision $REVISION
}


# intrepid install
#install x264
intrepid_x264 ()
{
apt-get -y remove ffmpeg x264 libx264-dev 2> $LOG >> $LOG
cd "$INSTALL"/x264
make -j $NO_OF_CPUCORES distclean 2>> $LOG >> $LOG
git pull 2>> $LOG >> $LOG
./configure 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --fstrans=no --install=yes --pkgname=x264 --pkgversion "1:0.svn`date +%Y%m%d`-0.0ubuntu1" --backup=no --default 2>> $LOG >> $LOG
}
#install ffmpeg
intrepid_ffmpeg ()
{
cd "$INSTALL"/ffmpeg
make -j $NO_OF_CPUCORES clean 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES distclean 2>> $LOG >> $LOG
svn update 2>> $LOG >> $LOG
./configure --enable-gpl --enable-version3 --enable-nonfree --enable-postproc --enable-pthreads --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libx264 --enable-libxvid --enable-x11grab 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --fstrans=no --install=yes --pkgname=ffmpeg --pkgversion "3:0.svn`date +%Y%m%d`-12ubuntu3" --backup=no --default 2>> $LOG >> $LOG
hash ffmpeg 2>> $LOG >> $LOG
REVISION=$(svn info | grep Revision | awk '{print $2}') 2>> $LOG >> $LOG
echo
echo ffmpeg is at revision $REVISION
}


#hardy install

#install x264
hardy_x264 ()
{
apt-get -y remove ffmpeg x264 libx264-dev 2> $LOG >> $LOG
cd "$INSTALL"/x264
make -j $NO_OF_CPUCORES distclean 2>> $LOG >> $LOG
git pull 2>> $LOG >> $LOG
./configure 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --pkgname=x264 --pkgversion "1:0.svn`date +%Y%m%d`-0.0ubuntu1" --backup=no --default 2>> $LOG >> $LOG
}
#install ffmpeg
hardy_ffmpeg ()
{
cd "$INSTALL"/ffmpeg
make -j $NO_OF_CPUCORES clean 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES distclean 2>> $LOG >> $LOG
svn update 2>> $LOG >> $LOG
./configure --enable-gpl --enable-version3 --enable-nonfree --enable-postproc --enable-pthreads --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libx264 --enable-libxvid --enable-x11grab 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --pkgname=ffmpeg --pkgversion "3:0.svn`date +%Y%m%d`-12ubuntu3" --backup=no --default 2>> $LOG >> $LOG
REVISION=$(svn info | grep Revision | awk '{print $2}') 2>> $LOG >> $LOG
echo
echo ffmpeg is at revision $REVISION
}

#####################################
#LINUXMINT FUNCTIONS
#####################################

#isadora install
#install x264

isadora_x264 ()
{
apt-get -y remove ffmpeg x264 libx264-dev 2> $LOG >> $LOG
cd "$INSTALL"/x264
make -j $NO_OF_CPUCORES distclean 2>> $LOG >> $LOG
git pull 2>> $LOG >> $LOG
./configure 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --pkgname=x264 --pkgversion "2:0.`grep X264_BUILD x264.h -m1 | cut -d' ' -f3`.`git rev-list HEAD | wc -l`+git`git rev-list HEAD -n 1 | head -c 7`" --backup=no --default 2>> $LOG >> $LOG
hash x264 2>> $LOG >> $LOG
}
#install ffmpeg
isadora_ffmpeg ()
{
cd "$INSTALL"/ffmpeg
make -j $NO_OF_CPUCORES clean 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES distclean 2>> $LOG >> $LOG
svn update 2>> $LOG >> $LOG
./configure --enable-gpl --enable-version3 --enable-nonfree --enable-postproc --enable-pthreads --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libx264 --enable-libxvid --enable-x11grab 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --pkgname=ffmpeg --pkgversion "4:SVN-r`svn info | grep Revision | awk '{ print $NF }'`" --backup=no --default 2>> $LOG >> $LOG
hash ffmpeg 2>> $LOG >> $LOG
REVISION=$(svn info | grep Revision | awk '{print $2}') 2>> $LOG >> $LOG
echo
echo ffmpeg is at revision $REVISION
}


#helena install
#install x264
helena_x264 ()
{
apt-get -y remove ffmpeg x264 libx264-dev 2> $LOG >> $LOG
cd "$INSTALL"/x264
make -j $NO_OF_CPUCORES distclean 2>> $LOG >> $LOG
git pull 2>> $LOG >> $LOG
./configure 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --pkgname=x264 --pkgversion "1:0.svn`date +%Y%m%d`+`git rev-list HEAD -n 1 | head -c 7`" --backup=no --default 2>> $LOG >> $LOG
}
#install ffmpeg
helena_ffmpeg ()
{
cd "$INSTALL"/ffmpeg
make -j $NO_OF_CPUCORES clean 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES distclean 2>> $LOG >> $LOG
svn update 2>> $LOG >> $LOG
./configure --enable-gpl --enable-version3 --enable-nonfree --enable-postproc --enable-pthreads --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libx264 --enable-libxvid --enable-x11grab 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --pkgname=ffmpeg --pkgversion "4:0.5+svn`date +%Y%m%d`" --backup=no --default 2>> $LOG >> $LOG
hash ffmpeg 2>> $LOG >> $LOG
REVISION=$(svn info | grep Revision | awk '{print $2}') 2>> $LOG >> $LOG
echo
echo ffmpeg is at revision $REVISION
}


#gloria install
#install x264
gloria_x264 ()
{
apt-get -y remove ffmpeg x264 libx264-dev 2> $LOG >> $LOG
cd "$INSTALL"/x264
make -j $NO_OF_CPUCORES distclean 2>> $LOG >> $LOG
git pull 2>> $LOG >> $LOG
./configure 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --fstrans=no --install=yes --pkgname=x264 --pkgversion "1:0.svn`date +%Y%m%d`-0.0ubuntu1" --backup=no --default 2>> $LOG >> $LOG
}
#install ffmpeg
gloria_ffmpeg ()
{
cd "$INSTALL"/ffmpeg
make -j $NO_OF_CPUCORES clean 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES distclean 2>> $LOG >> $LOG
svn update 2>> $LOG >> $LOG
./configure --enable-gpl --enable-version3 --enable-nonfree --enable-postproc --enable-pthreads --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libx264 --enable-libxvid --enable-x11grab 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --fstrans=no --install=yes --pkgname=ffmpeg --pkgversion "3:0.svn`date +%Y%m%d`-12ubuntu3" --backup=no --default 2>> $LOG >> $LOG
hash ffmpeg 2>> $LOG >> $LOG
REVISION=$(svn info | grep Revision | awk '{print $2}') 2>> $LOG >> $LOG
echo
echo ffmpeg is at revision $REVISION
}


# felicia install
#install x264
felicia_x264 ()
{
apt-get -y remove ffmpeg x264 libx264-dev 2> $LOG >> $LOG
cd "$INSTALL"/x264
make -j $NO_OF_CPUCORES distclean 2>> $LOG >> $LOG
git pull 2>> $LOG >> $LOG
./configure 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --fstrans=no --install=yes --pkgname=x264 --pkgversion "1:0.svn`date +%Y%m%d`-0.0ubuntu1" --backup=no --default 2>> $LOG >> $LOG
}
#install ffmpeg
felicia_ffmpeg ()
{
cd "$INSTALL"/ffmpeg
make -j $NO_OF_CPUCORES clean 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES distclean 2>> $LOG >> $LOG
svn update 2>> $LOG >> $LOG
./configure --enable-gpl --enable-version3 --enable-nonfree --enable-postproc --enable-pthreads --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libx264 --enable-libxvid --enable-x11grab 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --fstrans=no --install=yes --pkgname=ffmpeg --pkgversion "3:0.svn`date +%Y%m%d`-12ubuntu3" --backup=no --default 2>> $LOG >> $LOG
hash ffmpeg 2>> $LOG >> $LOG
REVISION=$(svn info | grep Revision | awk '{print $2}') 2>> $LOG >> $LOG
echo
echo ffmpeg is at revision $REVISION
}


#exit function
die ()
{
	echo $@ 
	exit 1
}

#error function
error ()
{
	kill $PID 2>> $LOG >> $LOG
	echo $1
	echo $@
	exit 1
}

#update function, called if the script is to be quiet
update ()
{
DISTRO=( $(cat /etc/lsb-release | grep CODE | cut -c 18-) )
OKDISTRO="hardy intrepid jaunty karmic lucid maverick felicia gloria helena isadora"

if [[ ! $(grep $DISTRO <<< $OKDISTRO) ]]; then
  die "exiting. Your distro is not supported, sorry.";
fi
echo
echo "script started" > $LOG
echo "Now running the update."
echo "Lets roll!"
echo "Now updating x264."
"$DISTRO"_x264 || error "Sorry something went wrong, please check the $LOG file." &
PID=$!
#this is a simple progress indicator
while ps |grep $PID &>/dev/null; do
	echo -n "."
	echo -en "\b-"
	sleep 1
	echo -en "\b\\"
	sleep 1
	echo -en "\b|"
	sleep 1
	echo -en "\b/"
	sleep 1
done

echo -e "\bDone"

echo "x264 updated."
echo
echo "Now updating ffmpeg."
"$DISTRO"_ffmpeg || error "Sorry something went wrong, please check the $LOG file." &
PID=$!
#this is a simple progress indicator
while ps |grep $PID &>/dev/null; do
	echo -n "."
	echo -en "\b-"
	sleep 1
	echo -en "\b\\"
	sleep 1
	echo -en "\b|"
	sleep 1
	echo -en "\b/"
	sleep 1
done

echo -e "\bDone"

echo "ffmpeg updated."
echo
echo "That's it, all done."
echo
}


###############
# this is the body of the script
###############


#this script must be run as root, so lets check that
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

#check for and parse the config file if it is present, then do a verbose update based on config settings
if [ -e $CONF ]; then
	source /etc/ffmpegup.conf
	update
	#check to see if the .debs should be copied
	if [ $COPY = n ]; then
		echo "Bye!"
		exit
	fi
	find "$INSTALL"/ffmpeg -name "*.deb" -exec mv "{}" "$LOCATION" \; 2>> $LOG >> $LOG
	find "$INSTALL"/x264 -name "*.deb" -exec mv "{}" "$LOCATION" \; 2>> $LOG >> $LOG
	echo ".deb files copied as requested to:"
	echo "$LOCATION"
	echo
	echo "That's it, everything done. Bye!"
	exit
fi

#first, lets warn the user use of this script requires some common sense and may mess things up
echo "WARNING, this script builds a number of packages from source,"
echo "this is pretty taxing on the CPU, so run it when nothing else is running"
echo "and don't expect to do much whilst it is running. It should take about 5 minutes to run."
echo
echo "WARNING, this script will update ffmpeg and x264."
echo "Please only proceed if you know what you are doing."
echo "Once this script starts, you musn't stop it,"
echo "since it could really mess with your system if stopped half way through."
echo
echo "Do you accept any problems caused by using this script are your own,"
echo "and nothing to do with me?"
read -p "Continue (y/n)?"
[ "$REPLY" == y ] || die "exiting (chicken ;) )..."
echo

#next, lets find out what version of Ubuntu we are running and check it
DISTRO=( $(cat /etc/lsb-release | grep CODE | cut -c 18-) )
OKDISTRO="hardy intrepid jaunty karmic lucid felicia gloria helena isadora maverick"

if [[ ! $(grep $DISTRO <<< $OKDISTRO) ]]; then
  die "exiting. Your distro is not supported, sorry.";
fi

DISTRIB=( $(cat /etc/lsb-release | grep ID | cut -c 12-) )

echo "Please note, earlier versions of Linux Mint appear as Ubuntu.."
read -p "You are running $DISTRIB $DISTRO, is this correct (y/n)?"
[ "$REPLY" == y ] || die "Sorry, I think you are using a different distro, exiting to be safe."
echo

# check that the default place to download to is ok
echo "Is this the location you chose when you ran fffmpegin.sh?:"
read -p ""$INSTALL" (y/n)?"
[ "$REPLY" == y ] || die "exiting. Please edit the script changing the INSTALL variable to the location of your choice."
echo

# check that the default place to log to is ok
echo "This script logs to:"
echo "$LOG"
read -p "Is this ok (y/n)?"
[ "$REPLY" == y ] || die "exiting. Please edit the script changing the LOG variable to the location of your choice."
echo

# ok, already, last check before proceeding
echo "OK, we are ready to rumble."
read -p "Shall I proceed, remember, this musn't be stopped (y/n)?"
[ "$REPLY" == y ] || die "exiting. Bye, did I come on too strong?."

echo
echo "script started" > $LOG
echo "Now running the update."
echo "Lets roll!"
echo "Now updating x264."
"$DISTRO"_x264 || error "Sorry something went wrong, please check the $LOG file." &
PID=$!
#this is a simple progress indicator
while ps |grep $PID &>/dev/null; do
	echo -n "."
	echo -en "\b-"
	sleep 1
	echo -en "\b\\"
	sleep 1
	echo -en "\b|"
	sleep 1
	echo -en "\b/"
	sleep 1
done
echo -e "\bDone"

echo "x264 updated."
echo
echo "Now updating ffmpeg."
"$DISTRO"_ffmpeg || error "Sorry something went wrong, please check the $LOG file." &
PID=$!
#this is a simple progress indicator
while ps |grep $PID &>/dev/null; do
	echo -n "."
	echo -en "\b-"
	sleep 1
	echo -en "\b\\"
	sleep 1
	echo -en "\b|"
	sleep 1
	echo -en "\b/"
	sleep 1
done
echo -e "\bDone"

echo "ffmpeg updated."
echo
echo "That's it, all done."
echo
#checking for and creating the conf file
if [ -e $CONF ]; then
	exit
else
	echo "This script can save it's settings in a conf file"
	echo "so next time it doesn't ask you any questions,"
	echo "making it much easier and faster to run." 
	read -p "Is this ok (y/n)?"
	if [ "$REPLY" = n ]; then
		echo "OK, settings not saved, I'll ask you after the next run."
		exit
	else
		echo
		echo "The settings will be saved in ""/""etc""/""ffmpegup.conf"
	fi
	if [ -e $CONF ]; then
		echo "The conf file already exists. It was either created by ffmpegin.sh"
		echo " or this script last time you ran it."
		read -p "Do you want to create a new conf file (y/n)?"
		if [ "$REPLY" = n ];then
			echo "OK, I'll use the existing conf file next time. Bye."
			exit
		else
			echo "OK, I'll overwrite the file."
		fi
	else
		echo
		echo "Creating new conf file."	
		echo
	fi
	touch $CONF
	echo "#configuration file for the ffmpegup.sh script" > $CONF
	echo "#last modified on `date "+%m/%d/%y %l:%M:%S %p"`" >> $CONF
	echo "INSTALL=/usr/local/src" >> $CONF
	echo "LOG=/var/log/ffmpegup.log" >> $CONF
	echo
	echo "Once ffmpeg and x264 has been built and installed, a .deb"
	echo "package is left in the src folder for each program. This"
	echo "allows you to install the newly built program on other"
	echo "computers running the same distro as this computer."	
	echo "If you want, I can copy those two .debs to a folder"
	echo "of your choice."
	read -p "Do you want me to do this (y/n)?"
	if [ "$REPLY" = n ]; then
		echo "COPY=n" >> $CONF
		echo "OK, that's everything sorted. Bye."
		exit
	else
		echo "COPY=y" >> $CONF
		echo "Where would you like me to copy the .debs to?"
		echo "Please enter the full path to the folder you want to use."
		echo "Remember, don't use ~ because we run this script as root."
		echo "If the location doesn't exist, I will create it for you."
		echo ""/"home"/"YOURUSERNAME"/"ffmpegup would be a good choice."
		read -p "Please enter the full path now, spaces are ok."
		until [ "$REPLY" != "" ]; do
			echo "Sorry, that isn't a valid answer, please try again."
			read -p "Please enter the full path now."
		done
		LOCATION="$REPLY"
		echo
		echo "You chose the following location:"
		echo
		echo $LOCATION
		echo
		read -p "Is this ok (y/n)?"
		until [ "$REPLY" = y ]; do
			read -p "Please enter the full path now, spaces are ok."
			until [ "$REPLY" != "" ]; do
				echo "Sorry, that isn't a valid answer, please try again."
				read -p "Please enter the full path now."
			done			
			LOCATION="$REPLY"
			echo
			echo "You chose the following location:"
			echo
			echo $LOCATION
			echo
			read -p "Is this ok (y/n)?"
		done
		fi
		if [ ! -d "$LOCATION" ]; then
			mkdir -p "$LOCATION"
		fi
		echo "LOCATION=$LOCATION" >> $CONF
		echo "OK, that's everything sorted. Bye."
		exit
	fi
	exit
fi
exit
