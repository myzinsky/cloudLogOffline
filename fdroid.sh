export PATH="$PATH:/Users/myzinsky/Zeugs/Qt/5.15.2/android/bin/"
export ANDROID_NDK_ROOT="/Users/myzinsky/Library/Android/sdk/ndk/21.3.6528147/"
export ANDROID_SDK_ROOT="/Users/myzinsky/Library/Android/sdk/"
export JAVA_HOME="/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home"
export JAVA_BIN="$JAVA_HOME/bin"
export JAVA_LIB="$JAVA_HOME/lib"

mkdir -pv fdroidBuild
cd fdroidBuild
qmake ../CloudLogOffline.pro
make -j4 apk_install_target
make -j4 apk


