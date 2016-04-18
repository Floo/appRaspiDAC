#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>

#include "raspidacnetwork.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    qmlRegisterType<RaspiDACNetwork>("RaspiDACNetwork", 1, 0, "RaspiDACNetwork");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
