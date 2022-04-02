// (c) serein.pfeiffer@gmail.com - zlib license, see "LICENSE" file

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlExtensionPlugin>
#include <QDebug>
#include <QtPlugin>
//Activate if you want to do QML profiling
//#include <QQmlDebuggingEnabler>


int main(int argc, char *argv[])
{
    //Activate if you want to do QML profiling
    //QQmlDebuggingEnabler enabler;

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    auto runAsAutoTest = QGuiApplication::platformName() == "minimal";
    if (runAsAutoTest) {
        QObject::connect(&engine,
                         &QQmlApplicationEngine::warnings,
                         [=] (const QList<QQmlError>& warnings) {
            for (auto& w: warnings) qCritical() << w.toString();
            exit(1);
        }
        );
    }

    // Android demands qml plugins to be stored under qml, use same approach
    // for all other platforms too
    engine.addImportPath(QCoreApplication::applicationDirPath() + "/qml");
    engine.load(QUrl("qrc:/qml/main.qml"));
    return app.exec();
}

