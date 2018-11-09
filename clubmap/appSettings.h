#ifndef APPSETTINGS_H
#define APPSETTINGS_H

#include <QSettings>
#include <QCoreApplication>
#include <QVariant>
#include <QString>
#include <QDebug>

#if defined(Q_OS_ANDROID)
#include "sharedpreferences.h"
#elif defined(Q_OS_IOS)
class KeychainImpl;
#include "ios-sources/keychain_int.h"
#elif defined(Q_OS_WIN)
#include <stdio.h>
#include "windows.h"
#include <Wincrypt.h>
#define MY_ENCODING_TYPE  (PKCS_7_ASN_ENCODING | X509_ASN_ENCODING)
#endif

class AppSettings : public QSettings
{
    Q_OBJECT

    public:
        explicit AppSettings(QObject *parent = nullptr);
        ~AppSettings();

        QVariantMap map;

    public:
        void init(void);

        Q_INVOKABLE void setValue(const QString &key, const QVariant &value);
        Q_INVOKABLE QVariant value(const QString &key, const QVariant &defaultValue = QVariant()) const;

        Q_INVOKABLE void setValueNV(const QString &key, const QVariant &value);
        Q_INVOKABLE QVariant valueNV(const QString &key, const QVariant &defaultValue = QVariant()) const;

        Q_INVOKABLE void setValueNVEC(const QString &key, const QVariant &value);
        Q_INVOKABLE QVariant valueNVEC(const QString &key, const QVariant &defaultValue = QVariant()) const;

#if defined(Q_OS_ANDROID)
    private:
        SharedPreferences *prefs = nullptr;
#elif defined(Q_OS_IOS)
    private:
        KeychainImpl * _impl;
#endif

};

// Q_DECLARE_METATYPE(AppSettings*)

#endif // APPSETTINGS_H
