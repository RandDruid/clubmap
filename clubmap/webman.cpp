#include "webman.h"

WebMan::WebMan(FixedPositionSource *fps, AppSettings *settings, QGuiApplication *application, QQmlApplicationEngine *engine, QObject *parent) : QObject(parent)
{
    sourceDefault = nullptr;
    sourceFixed = fps;
    this->settings = settings;
    this->application = application;
    this->engine = engine;

    settingsRead = false;

    if (sourceFixed) {
        connect(sourceFixed, SIGNAL(positionUpdated(QGeoPositionInfo)),
                this, SLOT(positionUpdated(QGeoPositionInfo)));
    }
    sourceCurrent = nullptr;
    m_inProgress = false;
    m_statusText1 = "";
    m_statusText2 = "";
    serverEncoding = FIRST_TRY_ENCODING;
    loginFailed = false;
    loginAttempts = 0;

//    m_positionLive = false;
//    m_icon = 0;
//    m_wantSendPosition = 60;
//    m_wantGetTargets = 60;
//    pushProperties();
    // loadSettings();

    connect(&qnam, &QNetworkAccessManager::authenticationRequired,
                this, &WebMan::authenticationRequired);

    boxSet = false;
    lastPositionSend = 0;
    lastTargetsGet = 0;
    positionSignificantlyChanged = true;
    reply = nullptr;
    lastPositionValid = false;

    timer = new QTimer(this);
    connect(timer, SIGNAL(timeout()), this, SLOT(timerExpired()));
    timer->start(1000);
}

void WebMan::pushProperties()
{
    changePositionSource(m_positionLive);
    changeIcon(m_icon);
    changeWantSendPositionInt(m_wantSendPositionInt);
    changeWantSendPositionBool(m_wantSendPositionBool);
    changeWantGetTargetsInt(m_wantGetTargetsInt);
    changeWantGetTargetsBool(m_wantGetTargetsBool);
}

//------------------------------------------------------------------------------------------------------------- Work with Position source

bool WebMan::isEnabled()
{
    return enabled;
}

void WebMan::setEnabled(bool enabled)
{
    if (sourceCurrent) {
        if (enabled) sourceCurrent->startUpdates(); else sourceCurrent->stopUpdates();
    }
    this->enabled = enabled;
}

void WebMan::changePositionSource(bool online)
{
    if (settingsRead) {
        if (sourceDefault) sourceDefault->stopUpdates();
        if (sourceFixed) sourceFixed->stopUpdates();
        if (online)  {
            if (!sourceDefault) {
                sourceDefault = QGeoPositionInfoSource::createDefaultSource(this);
                if (sourceDefault) {
                    connect(sourceDefault, SIGNAL(positionUpdated(QGeoPositionInfo)),
                            this, SLOT(positionUpdated(QGeoPositionInfo)));
                }
            }
            sourceCurrent = sourceDefault;
        } else {
            sourceCurrent = sourceFixed;
        }
        if (sourceCurrent) sourceCurrent->startUpdates();

        if (m_positionLive != online) {
            m_positionLive = online;
            positionLiveChanged(m_positionLive);
        }

        lastPositionSend = sourceCurrent->minimumUpdateInterval() / 1000 + 1;
        lastTargetsGet = lastPositionSend + 1;
    }
}

//------------------------------------------------------------------------------------------------------------- Slots for GUI to change properties

void WebMan::changeWantGetTargetsInt(int newValue)
{
    if (settingsRead) {
        m_wantGetTargetsInt = newValue;
        wantGetTargetsIntChanged(m_wantGetTargetsInt);
        lastTargetsGet = 0;
    }
}

void WebMan::changeWantGetTargetsBool(bool newValue)
{
    if (settingsRead) {
        m_wantGetTargetsBool = newValue;
        wantGetTargetsBoolChanged(m_wantGetTargetsBool);
        lastTargetsGet = 0;
    }
}

void WebMan::changeIcon(int newValue)
{
    if (settingsRead) {
        m_icon = newValue;
        iconIdChanged(m_icon);
    }
}

void WebMan::changeWantSendPositionInt(int newValue)
{
    if (settingsRead) {
        m_wantSendPositionInt = newValue;
        wantSendPositionIntChanged(m_wantSendPositionInt);
        lastPositionSend = 0;
    }
}

void WebMan::changeWantSendPositionBool(bool newValue)
{
    if (settingsRead) {
        m_wantSendPositionBool = newValue;
        wantSendPositionBoolChanged(m_wantSendPositionBool);
        lastPositionSend = 0;
    }
}

//------------------------------------------------------------------------------------------------------------- Take decision what to send and request

void WebMan::timerExpired()
{
    bool sendPosition = false;
    bool getTargets = false;

    if (m_wantGetTargetsBool) {
        lastTargetsGet--;
        if ((lastTargetsGet < 1) || boxUpdated) {
            lastTargetsGet = m_wantGetTargetsInt > 10 ? m_wantGetTargetsInt : 10;
            getTargets = true;
            boxUpdated = false;

            lastPositionSend = 1; // force 'send' if will 'get'. Because 'send' adds almost no data to 'get'
        }
    }

    if (m_wantSendPositionBool) {
        lastPositionSend--;
        lastPositionSendTimeout--;
        if (lastPositionSend < 1) {
            if ((lastPositionSendTimeout < 1) || positionSignificantlyChanged) {
                lastPositionSend = m_wantSendPositionInt > 10 ? m_wantSendPositionInt : 10;  // safeguard, minimum 10 sec
                lastPositionSendTimeout = 20 * 60; // every 20 minutes re-send position even if not changed
                positionSignificantlyChanged = false;
                sendPosition = true;
            }
        }
    }

    if (sendPosition || getTargets) {
        // if no requests in progress right now
        if (reply == nullptr) {
            startRequest(sendPosition, getTargets);
        }
    }

    m_statusText2 = QString::number(lastTargetsGet) + ";" + QString::number(lastPositionSend);
    statusText2Changed(m_statusText2);
}

//-------------------------------------------------------------------------------------------------------------

QGeoCoordinate WebMan::getCoordinate()
{
    if (sourceCurrent) {
        return sourceCurrent->lastKnownPosition().coordinate();
    } else {
        return QGeoCoordinate(0, 0);
    }
}

void WebMan::positionUpdated(const QGeoPositionInfo &pos)
{
    // qDebug() << "Position updated:" << pos;

    if (pos.isValid()) {
        positionChanged(pos.coordinate().latitude(), pos.coordinate().longitude());
        if (lastPosition.isValid()) {
            positionSignificantlyChanged =
                    lastPosition.coordinate().distanceTo(pos.coordinate()) > 30; // moved for more then 30m
        } else {
            positionSignificantlyChanged = true;
            lastPosition = pos;
        }

        // when we got valid position first time - force update
        if (!lastPositionValid) {
            lastPositionSend = 0;
            lastTargetsGet = 2;
        }
    }

    lastPositionValid = pos.isValid();
}

//------------------------------------------------------------------------------------------------------------- Work with non-volatile settings

void WebMan::loadSettings()
{
    QString qs = settings->valueNVEC("forum/login", "").toString();
    QStringList qsl = qs.split(';');
    if (qsl.length() == 3) {
        this->login = qsl[0];
        this->md5password_utf = qsl[1];
        this->md5password = qsl[2];
    } else {
        this->login = "";
        this->md5password_utf = "";
        this->md5password = "";
    }
    loginChanged(this->login);

    m_wantSendPositionInt = settings->valueNV("local/wantSendPositionInt", "60").toInt();
    wantSendPositionIntChanged(m_wantSendPositionInt);
    m_wantSendPositionBool = settings->valueNV("local/wantSendPositionBool", "True").toBool();
    wantSendPositionBoolChanged(m_wantSendPositionBool);

    m_wantGetTargetsInt = settings->valueNV("local/wantGetTargetsInt", "60").toInt();
    wantGetTargetsIntChanged(m_wantGetTargetsInt);
    m_wantGetTargetsBool = settings->valueNV("local/wantGetTargetsBool", "True").toBool();
    wantGetTargetsBoolChanged(m_wantGetTargetsBool);

    m_icon = settings->valueNV("local/iconid", "0").toInt();
    iconIdChanged(m_icon);

    m_positionLive = settings->valueNV("local/positionSourceDefault", "True").toBool();
    changePositionSource(m_positionLive);

    m_mapType = settings->valueNV("local/mapType", "osm").toString();
    mapTypeChanged(m_mapType);
    m_language = settings->valueNV("local/language", "auto").toString();
    languageChanged(m_language);
    QTimer::singleShot(200, this, SLOT(installTranslator()));

    settingsRead = true;
}

void WebMan::saveSettings()
{
    settings->setValueNV("local/positionSourceDefault", m_positionLive ? "True" : "False");
    settings->setValueNV("local/wantGetTargetsInt", m_wantGetTargetsInt);
    settings->setValueNV("local/wantGetTargetsBool", m_wantGetTargetsBool);
    settings->setValueNV("local/iconid", m_icon);
    settings->setValueNV("local/wantSendPositionInt", m_wantSendPositionInt);
    settings->setValueNV("local/wantSendPositionBool", m_wantSendPositionBool ? "True" : "False");
    settings->setValueNV("local/mapType", m_mapType);
    settings->setValueNV("local/language", m_language);
    settings->setValueNVEC("forum/login", this->login + ";" + this->md5password_utf + ";" + this->md5password);
}

//-------------------------------------------------------------------------------------------------------------

void WebMan::setMapType(QString mapType) {
    if (settingsRead) {

        m_mapType = mapType;
        mapTypeChanged(m_language);
    }
}

//-------------------------------------------------------------------------------------------------------------

void WebMan::installTranslator() {
    qDebug() << "translator: " << m_language;

    QLocale *locale;
    if (m_language == "auto")
        locale = new QLocale();
    else
        locale = new QLocale(m_language);
    if (translator.load(*locale, QLatin1String("clubmap"), QLatin1String("_"), QLatin1String(":/")))
    {
        application->removeTranslator(&translator);
        application->installTranslator(&translator);
        engine->retranslate();
    }
}

void WebMan::setLanguage(QString localeName) {
    if (settingsRead) {
        qDebug() << "set: " << localeName;

        m_language = localeName;
        languageChanged(m_language);
        installTranslator();
    }
}

//-------------------------------------------------------------------------------------------------------------

void WebMan::startRequest(bool sendPosition, bool getTargets)
{
    if (qnam.networkAccessible() == QNetworkAccessManager::Accessible) {
        url = QUrl(QString(URL_BASE) + QString(URL_PAGE));
        QUrlQuery uq;

        // "http://forester.club/position.php?x=100&y=200&s=1&i=8&x0=-1000&x1=1000&y0=-1000&y1=1000");

        bool needLogin = true;
        QList<QNetworkCookie> ncs = qnam.cookieJar()->cookiesForUrl(url);
        for (int i = 0; i < ncs.size(); i++) {
            if (ncs[i].name() == "gtuserid") {
                needLogin = false;
                break;
            }
        }

        if (needLogin && !loginFailed) {
            if (!this->login.isEmpty()) {
                uq.addQueryItem("do", "login");
                QString el = this->login;
                if (!serverEncoding.isEmpty() && (serverEncoding != UNKNOWN)) {
                    QTextCodec *codec = QTextCodec::codecForName(serverEncoding.toLatin1());
                    if (codec != nullptr) {
                        el = codec->fromUnicode(this->login).toPercentEncoding();
                    }
                }
                uq.addQueryItem("vb_login_username", el);
                uq.addQueryItem("vb_login_password", "");
                uq.addQueryItem("vb_login_md5password", this->md5password);
                uq.addQueryItem("vb_login_md5password_utf", this->md5password_utf);
                uq.addQueryItem("cookieuser", "1");
                loginAttempts++;
            } else {
                m_statusText1 = tr("Please configure Login and Password");
                statusText1Changed(m_statusText1);
                return;
            }
        }

        if (sendPosition) {
            if (sourceCurrent) {
                QGeoPositionInfo gpi = sourceCurrent->lastKnownPosition();
                QGeoCoordinate gc = gpi.coordinate();
                QString s = gpi.isValid() ? "1" : "0";
                uq.addQueryItem("x", QString::number(int(gc.longitude() * 1000000)));
                uq.addQueryItem("y", QString::number(int(gc.latitude() * 1000000)));
                uq.addQueryItem("s", s);
                uq.addQueryItem("i", QString::number(m_icon));

                // qDebug() << "s: " << s;
            }
        }

        if (getTargets && boxSet) {
            uq.addQueryItem("x0", QString::number(int(longitudeMin * 1000000)));
            uq.addQueryItem("x1", QString::number(int(longitudeMax * 1000000)));
            uq.addQueryItem("y0", QString::number(int(latitudeMin * 1000000)));
            uq.addQueryItem("y1", QString::number(int(latitudeMax * 1000000)));
        }

        url.setQuery(uq);

        m_inProgress = true;
        inProgressChanged(m_inProgress);
        m_statusText1 = tr("Communicating with server...");
        statusText1Changed(m_statusText1);

        reply = qnam.get(QNetworkRequest(url));
        connect(reply, &QNetworkReply::finished, this, &WebMan::httpFinished);
        timer->stop();
    } else {
        m_statusText1 = tr("Network is not available");
        statusText1Changed(m_statusText1);
    }
}

void WebMan::setUser(QString login, QString password)
{
    this->login = login;
    this->md5password_utf = QCryptographicHash::hash(str2binl(password), QCryptographicHash::Md5).toHex();
    this->md5password = QCryptographicHash::hash(str2ent(password), QCryptographicHash::Md5).toHex();

    // qDebug() << this->md5password_utf << " : " << this->md5password << endl;

    loginFailed = false;
    loginAttempts = 0;
}

void WebMan::setBox(double longitudeMin, double longitudeMax, double latitudeMin, double latitudeMax)
{
    if (!std::isnan(longitudeMin) && !std::isnan(longitudeMax) && !std::isnan(latitudeMin) && !std::isnan(latitudeMax)) {
        this->longitudeMin = longitudeMin;
        this->longitudeMax = longitudeMax;
        this->latitudeMin = latitudeMin;
        this->latitudeMax = latitudeMax;
        this->boxSet = true;
        this->boxUpdated = true;
    }
}

void WebMan::setBox()
{
    this->boxSet = false;
}

void WebMan::authenticationRequired(QNetworkReply *, QAuthenticator *authenticator)
{
    Q_UNUSED(authenticator);
    qDebug() << "Authentication required!";
}

void WebMan::httpFinished()
{
    m_inProgress = false;
    inProgressChanged(m_inProgress);

    if (reply != nullptr) { // in theory shouldn't happen

        if (reply->error()) {
            QString nes = reply->errorString();

            m_statusText1 = nes;
            statusText1Changed(m_statusText1);

        } else {
            const QVariant redirectionTarget = reply->attribute(QNetworkRequest::RedirectionTargetAttribute);

            if (!redirectionTarget.isNull()) {
                qDebug() << "Redirect ?!?";
            }

            QString replyEncoding = "UTF-8";
            QVariant ct = reply->header(QNetworkRequest::KnownHeaders::ContentTypeHeader);
            if (ct.isValid()) {
                QRegularExpression re("charset=([^\\s\\;]*)");
                QRegularExpressionMatch match = re.match(ct.toString());
                if (match.isValid()) {
                    replyEncoding = match.captured(1);
                }  else replyEncoding = UNKNOWN;
            } else replyEncoding = UNKNOWN;

            QByteArray test = reply->readAll();
            QString t2 = QTextCodec::codecForName(replyEncoding.toLatin1())->toUnicode(test).trimmed();
            qDebug() << t2;
            if (!t2.isEmpty()) {
                loginAttempts = 0;
                if (t2.startsWith("userid")) {
                    m_lastTargetsStr = t2;
                    targetsListChanged(t2);

                    m_statusText1 = tr("Connection successful %1").arg(QTime::currentTime().toString());
                    statusText1Changed(m_statusText1);

                } else {
                    m_statusText1 = tr("Account blocked");
                    statusText1Changed(m_statusText1);
                }
            } else {
                if ((loginAttempts > 1) || loginFailed) {
                    m_statusText1 = tr("Authentication failed");
                    statusText1Changed(m_statusText1);
                    loginFailed = true;
                } else {
                    // let's try encode login with server charset, second attempt
                    lastPositionSend = 0;
                    lastTargetsGet = 2;
                }
            }

            serverEncoding = replyEncoding;
        }

        reply->deleteLater();
        reply = nullptr;
    }

    timer->start(1000);
}

QByteArray WebMan::str2ent(QString str)
{
    QByteArray result;

    for (int i = 0; i < str.size(); i++)
    {
        ushort c = str[i].unicode();
        QByteArray tmp;

        if (c > 255)
        {

            while (c >= 1)
            {
                tmp = QByteArray::number(c % 10) + tmp;
                c = c / 10;
            }

            if (tmp.size() == 0)
            {
                tmp = "0";
            }
            tmp = "#" + tmp;
            tmp = "&" + tmp;
            tmp = tmp + ";";

            result += tmp;
        }
        else
        {
            result += str[i].toLatin1();
        }
    }
    return result;
}

QByteArray WebMan::str2binl(QString str)
{
    QByteArray bin;
    uint8_t mask = 0xFF;

    for(int i = 0; i < str.length(); i += 1)
        bin.append(char(str.at(i).unicode() & mask));

    return bin;
}
//------------------------------------------------------------------------------------------------------------- READs for properties

int WebMan::getIconId()
{
    return m_icon;
}
