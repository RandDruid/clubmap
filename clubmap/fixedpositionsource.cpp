#include "fixedpositionsource.h"

FixedPositionSource::FixedPositionSource(AppSettings *settings, QObject *parent)
    : QGeoPositionInfoSource(parent),
          timer(new QTimer(this))
{
    positionSet = false;
    latitudeStr = "";
    longitudeStr = "";
    emulation = false;
    emulationCounter = 0;
    this->settings = settings;

    connect(timer, SIGNAL(timeout()), this, SLOT(readNextPosition()));
}

QGeoPositionInfo FixedPositionSource::lastKnownPosition(bool /*fromSatellitePositioningMethodsOnly*/) const
{
    return lastPosition;
}

FixedPositionSource::PositioningMethods FixedPositionSource::supportedPositioningMethods() const
{
    return AllPositioningMethods;
}

int FixedPositionSource::minimumUpdateInterval() const
{
    return 500;
}

QGeoPositionInfoSource::Error FixedPositionSource::error() const
{
    return QGeoPositionInfoSource::NoError;
}

void FixedPositionSource::startUpdates()
{
    int interval = updateInterval();
    if (interval < minimumUpdateInterval())
        interval = minimumUpdateInterval();

    timer->start(interval);
}

void FixedPositionSource::stopUpdates()
{
    timer->stop();
}

void FixedPositionSource::requestUpdate(int /*timeout*/)
{
    if (positionSet)
        readNextPosition();
    else
        emit updateTimeout();
}

void FixedPositionSource::setPosition(QString latitudeStr, QString longitudeStr)
{
    bool hasLatitude = false;
    bool hasLongitude = false;
    latitudeStr.toDouble(&hasLatitude);
    longitudeStr.toDouble(&hasLongitude);
    if (hasLatitude && hasLongitude) {
        this->latitudeStr = latitudeStr;
        this->longitudeStr = longitudeStr;
        positionSet = true;
        fixedPositionChanged();

        settings->setValueNV("local/positionLatitude", latitudeStr);
        settings->setValueNV("local/positionLongitude", longitudeStr);
    } else {
        positionSet = false;
    }
}

void FixedPositionSource::loadSettings()
{
    this->latitudeStr = settings->valueNV("local/positionLatitude", "").toString();
    this->longitudeStr = settings->valueNV("local/positionLongitude", "").toString();
    positionSet = true;
    fixedPositionChanged();
}

void FixedPositionSource::readNextPosition()
{
    double latitude;
    double longitude;
    bool hasLatitude = false;
    bool hasLongitude = false;
    QDateTime timestamp = QDateTime::currentDateTime();
    if (!emulation) {
        latitude = latitudeStr.toDouble(&hasLatitude);
        longitude = longitudeStr.toDouble(&hasLongitude);
    } else {
        emulationCounter += 0.1;
        latitude = 55.75222 + qSin(emulationCounter) * 0.001;
        longitude = 37.61556 + qCos(emulationCounter) * 0.001;
        hasLatitude = true;
        hasLongitude = true;
        setPosition(QString::number(latitude), QString::number(longitude));
    }

    if (hasLatitude && hasLongitude && timestamp.isValid()) {
        QGeoCoordinate coordinate(latitude, longitude);
        QGeoPositionInfo info(coordinate, timestamp);
        if (info.isValid()) {
            lastPosition = info;
            emit positionUpdated(info);
        }
    }
}
