#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QLocale>
#include <QQmlEngine>

#include "build_number.h"
#include "webman.h"
#include "fixedpositionsource.h"
#include "appSettings.h"

int main(int argc, char *argv[])
{
#if QT_CONFIG(library)
    const QByteArray additionalLibraryPaths = qgetenv("QTLOCATION_EXTRA_LIBRARY_PATH");
    for (const QByteArray &p : additionalLibraryPaths.split(':'))
        QCoreApplication::addLibraryPath(QString(p));
#endif

    QCoreApplication::setOrganizationName("Andrey Ludwig");
    QCoreApplication::setOrganizationDomain("ludwigpro.net");
    QCoreApplication::setApplicationName("ClubMap");

    // qDebug() << "Compile time SSL: " << QSslSocket::sslLibraryBuildVersionString() << endl;
    // qDebug() << "Runtime SSL: " << QSslSocket::sslLibraryVersionNumber() << endl;

    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication application(argc, argv);

    QVariantMap parameters;
    QStringList args(QCoreApplication::arguments());

    parameters[QStringLiteral("osm.useragent")] = QStringLiteral("ClubMap app");

    QQmlApplicationEngine engine;
    QQmlContext *context = engine.rootContext();

    AppSettings *settings = new AppSettings();
    settings->init();
    context->setContextProperty("settings", settings);

    QVariant versionString(QString("%1 from %2").arg(GIT_VERSION, GIT_DATE));
    context->setContextProperty("versionString", versionString);

    context->setContextProperty("forumBaseUrl", URL_BASE);

    FixedPositionSource* fps = new FixedPositionSource(settings);
    WebMan* webMan = new WebMan(fps, settings, &application, &engine);
    context->setContextProperty("webMan", webMan);
    context->setContextProperty("fixedPositionSource", fps);

    engine.addImportPath(QStringLiteral(":/imports"));
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));
    QObject::connect(&engine, SIGNAL(quit()), qApp, SLOT(quit()));

    QTranslator translator;
    QLocale locale;
    if (translator.load(locale, QLatin1String("clubmap"), QLatin1String("_"), QLatin1String(":/")))
    {
        application.installTranslator(&translator);
        engine.retranslate();
    }

    QList<QObject*> rootObjects = engine.rootObjects();
    if (rootObjects.count() > 0) {
        QObject *item = rootObjects.first();
        Q_ASSERT(item);

        if (item != nullptr) {
            QMetaObject::invokeMethod(item, "initializeProviders",
                                      Q_ARG(QVariant, QVariant::fromValue(parameters)));

            //fps->setPosition("55.75222", "37.61556");
#ifdef _DEBUG
            fps->emulation = true;
#endif

            webMan->setBox(-180, 180, -90, 90);

            application.setWindowIcon(QIcon(":/images/logo_small_square.png"));

            return application.exec();
        }
    } else {
        qDebug() << "Main QML file not loaded";
    }
}
