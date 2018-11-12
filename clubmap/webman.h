#ifndef WEBMAN_H
#define WEBMAN_H

#include <QObject>
#include <QGeoPositionInfo>
#include <QGeoPositionInfoSource>
#include <QtNetwork>
#include <QUrl>
#include <QCryptographicHash>
#include <QDebug>
#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "fixedpositionsource.h"
#include "appSettings.h"


#define URL_BASE "https://forester.club/"
#define URL_PAGE "position.php"

class WebMan : public QObject
{
    Q_OBJECT
public:
    explicit WebMan(FixedPositionSource *fps, AppSettings *settings, QGuiApplication *application, QQmlApplicationEngine *engine, QObject *parent = nullptr);

    Q_PROPERTY(bool enabled READ isEnabled WRITE setEnabled)
    Q_PROPERTY(QGeoCoordinate coordinate READ getCoordinate)
    Q_PROPERTY(int wantSendPositionInt MEMBER m_wantSendPositionInt NOTIFY wantSendPositionIntChanged)
    Q_PROPERTY(bool wantSendPositionBool MEMBER m_wantSendPositionBool NOTIFY wantSendPositionBoolChanged)
    Q_PROPERTY(bool positionLive MEMBER m_positionLive NOTIFY positionLiveChanged)
    Q_PROPERTY(int wantGetTargetsInt MEMBER m_wantGetTargetsInt NOTIFY wantGetTargetsIntChanged)
    Q_PROPERTY(bool wantGetTargetsBool MEMBER m_wantGetTargetsBool NOTIFY wantGetTargetsBoolChanged)
    Q_PROPERTY(int iconId READ getIconId NOTIFY iconIdChanged)
    Q_PROPERTY(QString lastTargetsStr MEMBER m_lastTargetsStr)
    Q_PROPERTY(bool inProgress MEMBER m_inProgress NOTIFY inProgressChanged)
    Q_PROPERTY(QString statusText1 MEMBER m_statusText1 NOTIFY statusText1Changed)
    Q_PROPERTY(QString statusText2 MEMBER m_statusText2 NOTIFY statusText2Changed)
    Q_PROPERTY(QString language MEMBER m_language NOTIFY languageChanged)

    void startRequest(bool sendPosition, bool getTargets);
    void setBox();
    void pushProperties();
private:
    QTranslator translator;
    QGeoPositionInfoSource *sourceCurrent;
    QGeoPositionInfoSource *sourceFixed;
    QGeoPositionInfoSource *sourceDefault;
    bool enabled;
    bool settingsRead;
    bool m_positionLive;

    bool isEnabled();
    void setEnabled(bool enabled);
    QGeoCoordinate getCoordinate();
    QByteArray str2ent(QString str);
    QByteArray str2binl(QString str);

    QUrl url;
    QNetworkAccessManager qnam;
    QNetworkReply *reply;

    AppSettings *settings;
    QGuiApplication *application;
    QQmlApplicationEngine *engine;
    QString login;
    QString md5password;
    QString md5password_utf;

    QTimer *timer;
    int m_icon;
    int getIconId();
    int m_wantSendPositionInt;
    bool m_wantSendPositionBool;
    int lastPositionSend;
    int lastPositionSendTimeout;
    bool positionSignificantlyChanged;
    bool lastPositionValid;
    QGeoPositionInfo lastPosition;

    int m_wantGetTargetsInt;
    bool m_wantGetTargetsBool;
    int lastTargetsGet;
    bool boxSet;
    bool boxUpdated;
    double longitudeMin, longitudeMax;
    double latitudeMin, latitudeMax;
    QString m_lastTargetsStr;
    QString m_language;

    bool m_inProgress;
    QString m_statusText1;
    QString m_statusText2;

signals:
    void positionChanged(const double latitude, const double longitude);
    void targetsListChanged(QString targets);
    void wantSendPositionIntChanged(int newValue);
    void wantSendPositionBoolChanged(bool newValue);
    void positionLiveChanged(bool online);
    void wantGetTargetsIntChanged(int newValue);
    void wantGetTargetsBoolChanged(bool newValue);
    void iconIdChanged(int newValue);
    void inProgressChanged(bool newValue);
    void statusText1Changed(QString newValue);
    void statusText2Changed(QString newValue);
    void languageChanged(QString newValue);

public slots:
    void changeWantSendPositionInt(int newValue);
    void changeWantSendPositionBool(bool newValue);
    void changePositionSource(bool online);
    void changeWantGetTargetsInt(int newValue);
    void changeWantGetTargetsBool(bool newValue);
    void changeIcon(int newValue);
    void setUser(QString login, QString password);
    void loadSettings();
    void setLanguage(QString localeName);
    void setBox(double longitudeMin, double longitudeMax, double latitudeMin, double latitudeMax);

private slots:
    void timerExpired();

    void positionUpdated(const QGeoPositionInfo &pos);
    void authenticationRequired(QNetworkReply *, QAuthenticator *authenticator);
    void httpFinished();
    void installTranslator();

};

#endif // WEBMAN_H
