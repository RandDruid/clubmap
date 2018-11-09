#ifndef FIXEDPOSITIONSOURCE_H
#define FIXEDPOSITIONSOURCE_H

#include <QObject>
#include <QGeoPositionInfoSource>
#include <QTimer>
#include <QtMath>

#include "appSettings.h"

class FixedPositionSource : public QGeoPositionInfoSource
{
    Q_OBJECT
public:
    FixedPositionSource(AppSettings *settings, QObject *parent = nullptr);

    Q_PROPERTY(QString latitude MEMBER latitudeStr NOTIFY fixedPositionChanged)
    Q_PROPERTY(QString longitude MEMBER longitudeStr NOTIFY fixedPositionChanged)

    bool emulation;
    qreal emulationCounter;
    QGeoPositionInfo lastKnownPosition(bool fromSatellitePositioningMethodsOnly = false) const;

    PositioningMethods supportedPositioningMethods() const;
    int minimumUpdateInterval() const;
    Error error() const;

private:
    QTimer *timer;
    QGeoPositionInfo lastPosition;
    AppSettings *settings;

    bool positionSet;
    QString latitudeStr;
    QString longitudeStr;

signals:
    void fixedPositionChanged();

public slots:
    virtual void startUpdates();
    virtual void stopUpdates();

    virtual void requestUpdate(int timeout = 5000);

    void setPosition(QString latitudeStr, QString longitudeStr);
    void loadSettings();

private slots:
    void readNextPosition();

};

#endif // FIXEDPOSITIONSOURCE_H
