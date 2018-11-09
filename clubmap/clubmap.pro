QT += network quick positioning location
CONFIG += c++11

android: QT += androidextras

CONFIG(debug, release|debug):DEFINES += _DEBUG

TARGET = ClubMap

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
    main.cpp \
    webman.cpp \
    fixedpositionsource.cpp \
    appSettings.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

build_nr.target = build_number.h
unix: build_nr.commands = /bin/bash $$PWD/build_number.sh $$PWD;/bin/bash $$PWD/../get_version.sh
win32: build_nr.commands = bash $$PWD/build_number.sh $$PWD & bash $$PWD/../get_version.sh
build_nr.depends = build_nr2
build_nr2.commands = @echo Writing build number
QMAKE_EXTRA_TARGETS += build_nr build_nr2
PRE_TARGETDEPS += build_number.h

OTHER_FILES +=

contains(ANDROID_TARGET_ARCH,armeabi-v7a) {
    ANDROID_EXTRA_LIBS = \
        /usr/local/src/openssl-1.0.2p/libcrypto.so \
        /usr/local/src/openssl-1.0.2p/libssl.so
}

win32: {
    build_pass: {
        CONFIG(debug, release|debug): DESTDIR = $$PWD/../output/windows/Debug
        CONFIG(release, release|debug): DESTDIR = $$PWD/../output/windows/Release
    }
    LIBS += -lCrypt32
    RC_ICONS = images/logo.ico
}

HEADERS += \
    webman.h \
    fixedpositionsource.h \
    appSettings.h \
    build_number.h

android: {

    SOURCES += \
        sharedpreferences.cpp

    HEADERS += \
        sharedpreferences.h
}

DISTFILES += \
    android/AndroidManifest.xml \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradlew \
    android/res/values/libs.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew.bat \
    android/res/drawable-hdpi/splash.xml \
    android/res/drawable-hdpi/icon.png \
    android/res/drawable-ldpi/icon.png \
    android/res/drawable-mdpi/icon.png \
    android/res/values/theme.xml \
    android/res/drawable-ldpi/splash.xml \
    android/res/drawable-mdpi/splash.xml \
    android/src/net/ludwigpro/android/ClubMap/*.java \
    clubmap_en.ts \
    clubmap_ru.ts

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

TRANSLATIONS = clubmap_en.ts \
               clubmap_ru.ts
