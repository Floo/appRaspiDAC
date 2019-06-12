TEMPLATE = app

QT += qml quick widgets
QT += network

SOURCES += main.cpp \
    raspidacnetwork.cpp \
    mpnetworkthread.cpp

RESOURCES += qml.qrc

OTHER_FILES += *.qml images/*.png \
    content/*.qml \
    javascript/*.js \
    android/AndroidManifest.xml

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    raspidacnetwork.h \
    mpnetworkthread.h

#DISTFILES += \
#    android/AndroidManifest.xml

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

DISTFILES += \
    content/PM8000.qml \
    content/Viera.qml \
    content/SystemSetup.qml \
    fonts/Abel-Regular.ttf

