#!/bin/bash
# ffmpegin
# this sctipt downloads and install ffmpeg and x264 from SVN and git for the initial install

# taken from the excellet tutorial found here:
#http://ubuntuforums.org/showthread.php?t=786095&highlight=ffmpeg+x264+latest
# all props to fakeoutdoorsman, not me
# check http://code.google.com/p/x264-ffmpeg-up-to-date/ for updates
######################################
# ver 1.4 by rupert plumridge
# 10th August 2010
# updated to include maverick install and better error detection
######################################
######################################
# ver 1.3 by rupert plumridge
# 8th July 2010
# added ffplay to hash command for karmic 
# added multicore make ability as kindly suggested by Louwrentius, May 30, 2010: see here: http://code.google.com/p/x264-ffmpeg-up-to-date/issues/detail?id=5
######################################
# ver 1.2 by rupert plumridge
# 23 June 2010
# removed the --enable-libfaad option as it is no longer recquired and caused build errors
######################################
# ver 1.1 by rupert plumridge
# 18th April 2010
# changed to suport Linux Mint varients as well
# ver 1.0BETA by rupert plumridge
# 16th April 2010
# first version released
# this is a BETA script, so it may not work as expected and may destroy the world, including your computer..use at your own risk.

# Default variables
INSTALL="/usr/local/src"
# location of log file
LOG=/var/log/ffmpegin.log
#ffmpeg extra dependencies
DEP_EXTRAS=""
#ffmpeg extra configurations
FFMPEG_EXTRAS=""
# location of the script's lock file
LOCK="/var/run/ffmpegin.pid"
#User configuration file
USER_CONFIG="./config.sh"

[ -e $USER_CONFIG ] && source $USER_CONFIG

########################################
# do not edit anything beyond this line, unless you know what you are doing
########################################

# first, some error checking
set -o nounset
set -o errexit
set -o pipefail


###############
# list of all the functions in the script
###############

# Speed up build time using multpile processor cores.
NO_OF_CPUCORES=`grep -c ^processor /proc/cpuinfo 2>/dev/null`
if [ ! "$?" = "0" ]
then
    NO_OF_CPUCORES=2
fi

#maverick install
maverick_dep ()
{
apt-get -y remove ffmpeg x264 libx264-dev 2>> $LOG >> $LOG
apt-get -y update 2>> $LOG >> $LOG
apt-get -y install build-essential subversion git-core checkinstall yasm texi2html libfaac-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libsdl1.2-dev libtheora-dev libvorbis-dev libvpx-dev libx11-dev libxfixes-dev libxvidcore-dev zlib1g-dev $DEP_EXTRAS 2>> $LOG >> $LOG
}
maverick_x264 ()
{
cd $INSTALL
git clone git://git.videolan.org/x264.git 2>> $LOG >> $LOG
cd x264
./configure 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
sudo checkinstall --pkgname=x264 --pkgversion "2:0.`grep X264_BUILD x264.h -m1 |cut -d' ' -f3`.`git rev-list HEAD | wc -l`+git`git rev-list HEAD -n 1 | head -c 7`" --backup=no --deldoc=yes --fstrans=no --default 2>> $LOG >> $LOG
}
#install ffmpeg
maverick_ffmpeg ()
{
cd $INSTALL
svn checkout svn://svn.ffmpeg.org/ffmpeg/trunk ffmpeg 2>> $LOG >> $LOG
cd ffmpeg
./configure --enable-gpl --enable-version3 --enable-nonfree --enable-postproc --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libxvid --enable-x11grab $FFMPEG_EXTRAS 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
sudo checkinstall --pkgname=ffmpeg --pkgversion "4:SVN-r`LANG=C svn info | grep Revision | awk '{ print $NF }'`" --backup=no --deldoc=yes --fstrans=no --default 2>> $LOG >> $LOG
hash x264 ffmpeg ffplay 2>> $LOG >> $LOG
}

#lucid install
lucid_dep ()
{
apt-get -y remove ffmpeg x264 libx264-dev 2>> $LOG >> $LOG
apt-get -y update 2>> $LOG >> $LOG
apt-get -y install build-essential subversion git-core checkinstall yasm texi2html libfaac-dev libfaad-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libsdl1.2-dev libtheora-dev libx11-dev libxfixes-dev libxvidcore-dev zlib1g-dev $DEP_EXTRAS 2>> $LOG >> $LOG
}
#install x264

lucid_x264 ()
{
cd $INSTALL
git clone git://git.videolan.org/x264.git 2>> $LOG >> $LOG
cd x264
./configure 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --pkgname=x264 --pkgversion "2:0.`grep X264_BUILD x264.h -m1 | cut -d' ' -f3`.`git rev-list HEAD | wc -l`+git`git rev-list HEAD -n 1 | head -c 7`" --backup=no --default 2>> $LOG >> $LOG
hash x264 2>> $LOG >> $LOG
}
#install ffmpeg
lucid_ffmpeg ()
{
cd $INSTALL
svn checkout svn://svn.ffmpeg.org/ffmpeg/trunk ffmpeg 2>> $LOG >> $LOG
cd ffmpeg
make -j $NO_OF_CPUCORES clean 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES distclean 2>> $LOG >> $LOG
./configure --enable-gpl --enable-version3 --enable-nonfree --enable-postproc --enable-pthreads --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libx264 --enable-libxvid --enable-x11grab $FFMPEG_EXTRAS 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --pkgname=ffmpeg --pkgversion "4:SVN-r`svn info | grep Revision | awk '{ print $NF }'`" --backup=no --default 2>> $LOG >> $LOG
hash ffmpeg 2>> $LOG >> $LOG
}


#karmic install
karmic_dep ()
{
apt-get -y remove ffmpeg x264 libx264-dev 2>> $LOG >> $LOG
apt-get -y update 2>> $LOG >> $LOG
apt-get -y install build-essential subversion git-core checkinstall yasm texi2html libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libsdl1.2-dev libx11-dev libfaac-dev libfaad-dev libxfixes-dev libxvidcore-dev zlib1g-dev $DEP_EXTRAS 2>> $LOG >> $LOG
#install libtheora needed since the repo version is too old
apt-get -y install libogg-dev 2>> $LOG  >> $LOG
cd $INSTALL
wget http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.gz 2>> $LOG >> $LOG
tar xzvf libtheora-1.1.1.tar.gz 2>> $LOG >> $LOG
cd libtheora-1.1.1
./configure --disable-shared 2>> $LOG  >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --pkgname=libtheora --pkgversion "1.1.1" --backup=no --default 2>> $LOG >> $LOG
}
#install x264
karmic_x264 ()
{
cd $INSTALL
git clone git://git.videolan.org/x264.git 2>> $LOG >> $LOG
cd x264
./configure 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --pkgname=x264 --pkgversion "1:0.svn`date +%Y%m%d`+`git rev-list HEAD -n 1 | head -c 7`" --backup=no --default 2>> $LOG >> $LOG
}
#install ffmpeg
karmic_ffmpeg ()
{
cd $INSTALL
svn checkout svn://svn.ffmpeg.org/ffmpeg/trunk ffmpeg 2>> $LOG >> $LOG
cd ffmpeg
make -j $NO_OF_CPUCORES clean 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES distclean 2>> $LOG >> $LOG
./configure --enable-gpl --enable-version3 --enable-nonfree --enable-postproc --enable-pthreads --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libx264 --enable-libxvid --enable-x11grab $FFMPEG_EXTRAS 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --pkgname=ffmpeg --pkgversion "4:0.5+svn`date +%Y%m%d`" --backup=no --default 2>> $LOG >> $LOG
hash ffmpeg ffplay 2>> $LOG >> $LOG
}


#jaunty install
jaunty_dep ()
{
apt-get -y remove ffmpeg x264 libx264-dev 2>> $LOG >> $LOG
apt-get -y update 2>> $LOG >> $LOG
apt-get -y install build-essential subversion git-core checkinstall yasm texi2html libfaac-dev libfaad-dev libmp3lame-dev libsdl1.2-dev libx11-dev libxfixes-dev libxvidcore4-dev zlib1g-dev $DEP_EXTRAS 2>> $LOG >> $LOG
#install libopencore-amr
cd $INSTALL
wget http://transact.dl.sourceforge.net/project/opencore-amr/opencore-amr/0.1.2/opencore-amr-0.1.2.tar.gz 2>> $LOG >> $LOG
tar xvf opencore-amr-0.1.2.tar.gz 2>> $LOG >> $LOG
cd opencore-amr-0.1.2
./configure --disable-shared 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --fstrans=no --install=yes --pkgname="libopencore-amr" --pkgversion="0.1.2" --backup=no --default 2>> $LOG >> $LOG
#install libtheora
apt-get -y install libogg-dev 2>> $LOG >> $LOG
cd $INSTALL
wget http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.gz 2>> $LOG >> $LOG
tar xzvf libtheora-1.1.1.tar.gz 2>> $LOG >> $LOG
cd libtheora-1.1.1
./configure --disable-shared 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --fstrans=no --install=yes --pkgname=libtheora --pkgversion "1.1.1" --backup=no --default 2>> $LOG >> $LOG
}
#install x264
jaunty_x264 ()
{
cd $INSTALL
git clone git://git.videolan.org/x264.git 2>> $LOG >> $LOG
cd x264
./configure 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --fstrans=no --install=yes --pkgname=x264 --pkgversion "1:0.svn`date +%Y%m%d`-0.0ubuntu1" --backup=no --default 2>> $LOG >> $LOG
}
#install ffmpeg
jaunty_ffmpeg ()
{
cd $INSTALL
svn checkout svn://svn.ffmpeg.org/ffmpeg/trunk ffmpeg 2>> $LOG >> $LOG
cd ffmpeg
make -j $NO_OF_CPUCORES clean 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES distclean 2>> $LOG >> $LOG
./configure --enable-gpl --enable-version3 --enable-nonfree --enable-postproc --enable-pthreads --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libx264 --enable-libxvid --enable-x11grab $FFMPEG_EXTRAS 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --fstrans=no --install=yes --pkgname=ffmpeg --pkgversion "3:0.svn`date +%Y%m%d`-12ubuntu3" --backup=no --default 2>> $LOG >> $LOG
hash ffmpeg 2>> $LOG >> $LOG
}


# intrepid install
intrepid_dep ()
{
apt-get -y remove ffmpeg x264 libx264-dev 2>> $LOG >> $LOG
apt-get -y update 2>> $LOG >> $LOG
apt-get -y install build-essential subversion git-core checkinstall yasm texi2html libfaac-dev libfaad-dev libmp3lame-dev libsdl1.2-dev libx11-dev libxfixes-dev libxvidcore4-dev zlib1g-dev $DEP_EXTRAS 2>> $LOG >> $LOG
#install libopencore-amr
cd $INSTALL
wget http://transact.dl.sourceforge.net/project/opencore-amr/opencore-amr/0.1.2/opencore-amr-0.1.2.tar.gz 2>> $LOG >> $LOG
tar xvf opencore-amr-0.1.2.tar.gz 2>> $LOG >> $LOG
cd opencore-amr-0.1.2
./configure --disable-shared 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --fstrans=no --install=yes --pkgname="libopencore-amr" --pkgversion="0.1.2" --backup=no --default 2>> $LOG >> $LOG
#install libtheora
apt-get -y install libogg-dev 2>> $LOG >> $LOG
cd $INSTALL
wget http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.gz 2>> $LOG >> $LOG
tar xzvf libtheora-1.1.1.tar.gz 2>> $LOG >> $LOG
cd libtheora-1.1.1
./configure --disable-shared 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --fstrans=no --install=yes --pkgname=libtheora --pkgversion "1.1.1" --backup=no --default 2>> $LOG >> $LOG
}
#install x264
intrepid_x264 ()
{
cd $INSTALL
git clone git://git.videolan.org/x264.git 2>> $LOG >> $LOG
cd x264
./configure 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --fstrans=no --install=yes --pkgname=x264 --pkgversion "1:0.svn`date +%Y%m%d`-0.0ubuntu1" --backup=no --default 2>> $LOG >> $LOG
}
#install ffmpeg
intrepid_ffmpeg ()
{
cd $INSTALL
svn checkout svn://svn.ffmpeg.org/ffmpeg/trunk ffmpeg 2>> $LOG >> $LOG
cd ffmpeg
make -j $NO_OF_CPUCORES clean 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES distclean 2>> $LOG >> $LOG
./configure --enable-gpl --enable-version3 --enable-nonfree --enable-postproc --enable-pthreads --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libx264 --enable-libxvid --enable-x11grab $FFMPEG_EXTRAS 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --fstrans=no --install=yes --pkgname=ffmpeg --pkgversion "3:0.svn`date +%Y%m%d`-12ubuntu3" --backup=no --default 2>> $LOG >> $LOG
hash ffmpeg 2>> $LOG >> $LOG
}


#hardy install
hardy_dep ()
{
apt-get -y remove ffmpeg x264 libx264-dev 2>> $LOG >> $LOG
apt-get -y update 2>> $LOG >> $LOG
apt-get -y install build-essential subversion git-core checkinstall texi2html libfaac-dev libfaad-dev liblame-dev libsdl1.2-dev libx11-dev libxfixes-dev libxvidcore4-dev zlib1g-dev $DEP_EXTRAS 2>> $LOG >> $LOG
#install yasm
cd $INSTALL
wget http://www.tortall.net/projects/yasm/releases/yasm-1.0.0.tar.gz 2>> $LOG >> $LOG
tar xzvf yasm-1.0.0.tar.gz 2>> $LOG >> $LOG
cd yasm-1.0.0
./configure 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --pkgname=yasm --pkgversion "1.0.0" --backup=no --default 2>> $LOG >> $LOG
#install libopencore-amr
cd $INSTALL
wget http://transact.dl.sourceforge.net/project/opencore-amr/opencore-amr/0.1.2/opencore-amr-0.1.2.tar.gz 2>> $LOG >> $LOG
tar xvf opencore-amr-0.1.2.tar.gz 2>> $LOG >> $LOG
cd opencore-amr-0.1.2
./configure --disable-shared 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --fstrans=no --pkgname="libopencore-amr" --pkgversion="0.1.2" --backup=no --default 2>> $LOG >> $LOG
#install libtheora
apt-get -y install libogg-dev 2>> $LOG >> $LOG
cd $INSTALL
wget http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.gz 2>> $LOG >> $LOG
tar xzvf libtheora-1.1.1.tar.gz 2>> $LOG >> $LOG
cd libtheora-1.1.1
./configure --disable-shared 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --fstrans=no --pkgname=libtheora --pkgversion "1.1.1" --backup=no --default 2>> $LOG >> $LOG
}
#install x264
hardy_x264 ()
{
cd $INSTALL
git clone git://git.videolan.org/x264.git 2>> $LOG >> $LOG
cd x264
./configure 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --pkgname=x264 --pkgversion "1:0.svn`date +%Y%m%d`-0.0ubuntu1" --backup=no --default 2>> $LOG >> $LOG
}
#install ffmpeg
hardy_ffmpeg ()
{
cd $INSTALL
svn checkout svn://svn.ffmpeg.org/ffmpeg/trunk ffmpeg 2>> $LOG >> $LOG
cd ffmpeg
make -j $NO_OF_CPUCORES clean 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES distclean 2>> $LOG >> $LOG
./configure --enable-gpl --enable-version3 --enable-nonfree --enable-postproc --enable-pthreads --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libx264 --enable-libxvid --enable-x11grab $FFMPEG_EXTRAS 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --pkgname=ffmpeg --pkgversion "3:0.svn`date +%Y%m%d`-12ubuntu3" --backup=no --default 2>> $LOG >> $LOG
}


#isadora install
isadora_dep ()
{
apt-get -y remove ffmpeg x264 libx264-dev 2>> $LOG >> $LOG
apt-get -y update 2>> $LOG >> $LOG
apt-get -y install build-essential subversion git-core checkinstall yasm texi2html libfaac-dev libfaad-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libsdl1.2-dev libtheora-dev libx11-dev libxfixes-dev libxvidcore-dev zlib1g-dev $DEP_EXTRAS 2>> $LOG >> $LOG
}
#install x264
isadora_x264 ()
{
cd $INSTALL
git clone git://git.videolan.org/x264.git 2>> $LOG >> $LOG
cd x264
./configure 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --pkgname=x264 --pkgversion "2:0.`grep X264_BUILD x264.h -m1 | cut -d' ' -f3`.`git rev-list HEAD | wc -l`+git`git rev-list HEAD -n 1 | head -c 7`" --backup=no --default 2>> $LOG >> $LOG
hash x264 2>> $LOG >> $LOG
}
#install ffmpeg
isadora_ffmpeg ()
{
cd $INSTALL
svn checkout svn://svn.ffmpeg.org/ffmpeg/trunk ffmpeg 2>> $LOG >> $LOG
cd ffmpeg
make -j $NO_OF_CPUCORES clean 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES distclean 2>> $LOG >> $LOG
./configure --enable-gpl --enable-version3 --enable-nonfree --enable-postproc --enable-pthreads --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libx264 --enable-libxvid --enable-x11grab $FFMPEG_EXTRAS 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --pkgname=ffmpeg --pkgversion "4:SVN-r`svn info | grep Revision | awk '{ print $NF }'`" --backup=no --default 2>> $LOG >> $LOG
hash ffmpeg 2>> $LOG >> $LOG
}

#helena install
helena_dep ()
{
apt-get -y remove ffmpeg x264 libx264-dev 2>> $LOG >> $LOG
apt-get -y update 2>> $LOG >> $LOG
apt-get -y install build-essential subversion git-core checkinstall yasm texi2html libfaac-dev libfaad-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libsdl1.2-dev libx11-dev libxfixes-dev libxvidcore-dev zlib1g-dev $DEP_EXTRAS 2>> $LOG >> $LOG
#install libtheora needed since the repo version is too old
apt-get -y install libogg-dev 2>> $LOG >> $LOG
cd $INSTALL
wget http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.gz 2>> $LOG >> $LOG
tar xzvf libtheora-1.1.1.tar.gz 2>> $LOG >> $LOG
cd libtheora-1.1.1
./configure --disable-shared 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --pkgname=libtheora --pkgversion "1.1.1" --backup=no --default 2>> $LOG >> $LOG
}
#install x264
helena_x264 ()
{
cd $INSTALL
git clone git://git.videolan.org/x264.git 2>> $LOG >> $LOG
cd x264
./configure 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --pkgname=x264 --pkgversion "1:0.svn`date +%Y%m%d`+`git rev-list HEAD -n 1 | head -c 7`" --backup=no --default 2>> $LOG >> $LOG
}
#install ffmpeg
helena_ffmpeg ()
{
cd $INSTALL
svn checkout svn://svn.ffmpeg.org/ffmpeg/trunk ffmpeg 2>> $LOG >> $LOG
cd ffmpeg
make -j $NO_OF_CPUCORES clean 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES distclean 2>> $LOG >> $LOG
./configure --enable-gpl --enable-version3 --enable-nonfree --enable-postproc --enable-pthreads --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libx264 --enable-libxvid --enable-x11grab $FFMPEG_EXTRAS 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --pkgname=ffmpeg --pkgversion "4:0.5+svn`date +%Y%m%d`" --backup=no --default 2>> $LOG >> $LOG
hash ffmpeg 2>> $LOG >> $LOG
}

#gloria install
gloria_dep ()
{
apt-get -y remove ffmpeg x264 libx264-dev 2>> $LOG >> $LOG
apt-get -y update 2>> $LOG >> $LOG
apt-get -y install build-essential subversion git-core checkinstall yasm texi2html libfaac-dev libfaad-dev libmp3lame-dev libsdl1.2-dev libx11-dev libxfixes-dev libxvidcore4-dev zlib1g-dev $DEP_EXTRAS 2>> $LOG >> $LOG
#install libopencore-amr
cd $INSTALL
wget http://transact.dl.sourceforge.net/project/opencore-amr/opencore-amr/0.1.2/opencore-amr-0.1.2.tar.gz 2>> $LOG >> $LOG
tar xvf opencore-amr-0.1.2.tar.gz 2>> $LOG >> $LOG
cd opencore-amr-0.1.2
./configure --disable-shared 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --fstrans=no --install=yes --pkgname="libopencore-amr" --pkgversion="0.1.2" --backup=no --default 2>> $LOG >> $LOG
#install libtheora
apt-get -y install libogg-dev 2>> $LOG >> $LOG
cd $INSTALL
wget http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.gz 2>> $LOG >> $LOG
tar xzvf libtheora-1.1.1.tar.gz 2>> $LOG >> $LOG
cd libtheora-1.1.1
./configure --disable-shared 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --fstrans=no --install=yes --pkgname=libtheora --pkgversion "1.1.1" --backup=no --default 2>> $LOG >> $LOG
}
#install x264
gloria_x264 ()
{
cd $INSTALL
git clone git://git.videolan.org/x264.git 2>> $LOG >> $LOG
cd x264
./configure 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --fstrans=no --install=yes --pkgname=x264 --pkgversion "1:0.svn`date +%Y%m%d`-0.0ubuntu1" --backup=no --default 2>> $LOG >> $LOG
}
#install ffmpeg
gloria_ffmpeg ()
{
cd $INSTALL
svn checkout svn://svn.ffmpeg.org/ffmpeg/trunk ffmpeg 2>> $LOG >> $LOG
cd ffmpeg
make -j $NO_OF_CPUCORES clean 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES distclean 2>> $LOG >> $LOG
./configure --enable-gpl --enable-version3 --enable-nonfree --enable-postproc --enable-pthreads --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libx264 --enable-libxvid --enable-x11grab $FFMPEG_EXTRAS 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --fstrans=no --install=yes --pkgname=ffmpeg --pkgversion "3:0.svn`date +%Y%m%d`-12ubuntu3" --backup=no --default 2>> $LOG >> $LOG
hash ffmpeg 2>> $LOG >> $LOG
}

# felicia install
felicia_dep ()
{
apt-get -y remove ffmpeg x264 libx264-dev 2>> $LOG >> $LOG
apt-get -y update 2>> $LOG >> $LOG
apt-get -y install build-essential subversion git-core checkinstall yasm texi2html libfaac-dev libfaad-dev libmp3lame-dev libsdl1.2-dev libx11-dev libxfixes-dev libxvidcore4-dev zlib1g-dev $DEP_EXTRAS 2>> $LOG >> $LOG
#install libopencore-amr
cd $INSTALL
wget http://transact.dl.sourceforge.net/project/opencore-amr/opencore-amr/0.1.2/opencore-amr-0.1.2.tar.gz 2>> $LOG >> $LOG
tar xvf opencore-amr-0.1.2.tar.gz 2>> $LOG >> $LOG
cd opencore-amr-0.1.2
./configure --disable-shared 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --fstrans=no --install=yes --pkgname="libopencore-amr" --pkgversion="0.1.2" --backup=no --default 2>> $LOG >> $LOG
#install libtheora
apt-get -y install libogg-dev 2>> $LOG >> $LOG
cd $INSTALL
wget http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.gz 2>> $LOG >> $LOG
tar xzvf libtheora-1.1.1.tar.gz 2>> $LOG >> $LOG
cd libtheora-1.1.1
./configure --disable-shared 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --fstrans=no --install=yes --pkgname=libtheora --pkgversion "1.1.1" --backup=no --default 2>> $LOG >> $LOG
}
#install x264
felicia_x264 ()
{
cd $INSTALL
git clone git://git.videolan.org/x264.git 2>> $LOG >> $LOG
cd x264
./configure 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --fstrans=no --install=yes --pkgname=x264 --pkgversion "1:0.svn`date +%Y%m%d`-0.0ubuntu1" --backup=no --default 2>> $LOG >> $LOG
}
#install ffmpeg
felicia_ffmpeg ()
{
cd $INSTALL
svn checkout svn://svn.ffmpeg.org/ffmpeg/trunk ffmpeg 2>> $LOG >> $LOG
cd ffmpeg
make -j $NO_OF_CPUCORES clean 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES distclean 2>> $LOG >> $LOG
./configure --enable-gpl --enable-version3 --enable-nonfree --enable-postproc --enable-pthreads --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libx264 --enable-libxvid --enable-x11grab $FFMPEG_EXTRAS 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --fstrans=no --install=yes --pkgname=ffmpeg --pkgversion "3:0.svn`date +%Y%m%d`-12ubuntu3" --backup=no --default 2>> $LOG >> $LOG
hash ffmpeg 2>> $LOG >> $LOG
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
	kill "$PID" &>/dev/null 2>> $LOG >> $LOG
	
	echo $1
	echo $@
	exit 1
}


###############
# this is the body of the script
###############


#this script must be run as root, so lets check that
if [ "$(id -u)" != "0" ]; then
   echo "exiting. This script must be run as root" 1>&2
   exit 1
fi


#first, lets warn the user use of this script requires some common sense and may mess things up
echo "WARNING, this script builds a number of packages from source,"
echo "this is pretty taxing on the CPU, so run it when nothing else is running"
echo "and don't expect to do much whilst it is running."
echo "It should take about 5 minutes to run." 
echo
echo "WARNING, this script will uninstall ffmpeg and x264 first,"
echo "this may cause other programs to stop working."
echo "Please only proceed if you know what you are doing."
echo
echo "Once this script starts, you musn't stop it,"
echo "since it could really mess with your system if stopped half way through."
echo "If you want to reverse the changes made, use my ffmpegupreverse.sh script."
echo
echo "Do you accept any problems caused by using this script are your own,"
echo "and nothing to do with me?"
read -p "Continue (y/n)?"
[ "$REPLY" == y ] || die "exiting (chicken ;) )..."
echo



#next, lets find out what version of Ubuntu we are running and check it
DISTRO=( $(cat /etc/lsb-release | grep CODE | cut -c 18-) )
OKDISTRO="hardy intrepid jaunty karmic lucid maverick felicia gloria helena isadora"

if [[ ! $(grep $DISTRO <<< $OKDISTRO) ]]; then
  die "exiting. Your distro is not supported, sorry.";
fi

DISTRIB=( $(cat /etc/lsb-release | grep ID | cut -c 12-) )

echo "Please note, earlier versions of Linux Mint appear as Ubuntu.."
read -p "You are running $DISTRIB $DISTRO, is this correct (y/n)?"
[ "$REPLY" == y ] || die "Sorry, I think you are using a different distro, exiting to be safe."
echo

# check that the default place to download to and log file location is ok
echo "This script downloads the source files to:"
echo "$INSTALL"
read -p "Is this ok (y/n)?"
[ "$REPLY" == y ] || die "exiting. Please edit '$USER_CONFIG' changing the INSTALL variable to the location of your choice."
echo

echo "This script logs to:"
echo "$LOG"
read -p "Is this ok (y/n)?"
[ "$REPLY" == y ] || die "exiting. Please edit '$USER_CONFIG' changing the LOG variable to the location of your choice."
echo

# ok, already, last check before proceeding
echo "OK, we are ready to rumble."
read -p "Shall I proceed, remember, this musn't be stopped (y/n)?"
[ "$REPLY" == y ] || die "exiting. Bye, did I come on too strong?."

echo
echo "Lets roll!"
echo "script started" > $LOG
echo "installing dependencies"
echo "installing dependencies" 2>> $LOG >> $LOG
"$DISTRO"_dep || error "Sorry something went wrong, please check the $LOG file." &
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
echo
echo "downlading, building and installing x264"
echo "downlading, building and installing x264" 2>> $LOG >> $LOG
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
echo
echo "downloading, building and installing ffmpeg"
echo "downloading, building and installing ffmpeg" 2>> $LOG >> $LOG
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
echo
echo "That's it, all done."
echo "exiting now, bye."
echo "Remember to run ffmpegup.sh to update the install on occassion ;)"
exit 

