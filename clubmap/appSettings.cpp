#include "appSettings.h"

#if defined(Q_OS_IOS)
//#include "ios-sources/keychain_int.h"
#endif

AppSettings::AppSettings(QObject *parent) :
    QSettings(
        QSettings::UserScope,
        QCoreApplication::instance()->organizationName(),
        QCoreApplication::instance()->applicationName(),
        parent) {

#if defined(Q_OS_ANDROID)
    prefs = SharedPreferences::getPreferences();
#endif
#if defined(Q_OS_IOS)
    _impl = NULL;
#endif
}

void AppSettings::init() {
#if defined(Q_OS_IOS)
    _impl = new KeychainImpl();
    _impl->init();
#endif
}

AppSettings::~AppSettings() {
#if defined(Q_OS_IOS)
    if (_impl) { delete _impl; _impl = NULL; }
#endif
}

void AppSettings::setValue(const QString &key, const QVariant &value) {
    map.insert(key, value);
}

QVariant AppSettings::value(const QString &key, const QVariant &defaultValue) const {
    return map.value(key, defaultValue);
}

#if defined(Q_OS_IOS)

void AppSettings::setValueNV(const QString &key, const QVariant &value) {
    _impl->saveString(value.toString(), key);
}

QVariant AppSettings::valueNV(const QString &key, const QVariant &defaultValue) const {
    QString r = _impl->getStringForKey(key);
    return (r != NULL) ? r : defaultValue;
}

#elif defined(Q_OS_ANDROID)

void AppSettings::setValueNV(const QString &key, const QVariant &value) {
    if (prefs != nullptr) prefs->setValue(key, value);
}

QVariant AppSettings::valueNV(const QString &key, const QVariant &defaultValue) const {
    return ((prefs != nullptr) && (prefs->contains(key))) ? prefs->value(key) : defaultValue;
}

void AppSettings::setValueNVEC(const QString &key, const QVariant &value) {
    QAndroidJniObject jPlainText = QAndroidJniObject::fromString(value.toString());
    QAndroidJniObject jCipherText =
        QAndroidJniObject::callStaticObjectMethod("net/ludwigpro/android/ClubMap/Crypto", "encryptAesKeyStorage",
                                                  "(Ljava/lang/String;)Ljava/lang/String;",
                                                  jPlainText.object<jstring>());
    QString cipherText = jCipherText.toString();

    if (prefs != nullptr) prefs->setValue(key, cipherText);
}

QVariant AppSettings::valueNVEC(const QString &key, const QVariant &defaultValue) const {
    QVariant cipherText2 = ((prefs != nullptr) && (prefs->contains(key))) ? prefs->value(key) : defaultValue;
    QAndroidJniObject jCipherText = QAndroidJniObject::fromString(cipherText2.toString());
    QAndroidJniObject jPlainText =
        QAndroidJniObject::callStaticObjectMethod("net/ludwigpro/android/ClubMap/Crypto", "decryptAesKeyStorage",
                                                  "(Ljava/lang/String;)Ljava/lang/String;",
                                                  jCipherText.object<jstring>());
    return jPlainText.toString();
}

#elif defined(Q_OS_WIN)

void AppSettings::setValueNV(const QString &key, const QVariant &value) {
    QSettings::setValue(key, value);
}

QVariant AppSettings::valueNV(const QString &key, const QVariant &defaultValue) const {
    return QSettings::value(key, defaultValue);
}

void AppSettings::setValueNVEC(const QString &key, const QVariant &value) {
    QByteArray dec = value.toString().toUtf8();

    DATA_BLOB DataIn;
    DATA_BLOB DataOut;
    BYTE *pbDataInput = reinterpret_cast<BYTE *>(dec.data());
    DWORD cbDataInput = static_cast<DWORD>(dec.length());
    DataIn.pbData = pbDataInput;
    DataIn.cbData = cbDataInput;

    if (CryptProtectData(&DataIn,
         nullptr,                    // A description string.
         nullptr,                    // Optional entropy
                                     // not used.
         nullptr,                    // Reserved.
         nullptr,                    // Pass a PromptStruct.
         0,
         &DataOut))
    {
        QByteArray enc(reinterpret_cast<char*>(DataOut.pbData), static_cast<int>(DataOut.cbData));
        QString encText = QString::fromLatin1(enc.toBase64());
        LocalFree(DataOut.pbData);
        QSettings::setValue(key, encText);
    }
    else
    {
        qDebug() << "Windows encryption error!";
    }
}

QVariant AppSettings::valueNVEC(const QString &key, const QVariant &defaultValue) const {
    QString encText = QSettings::value(key, defaultValue).toString();
    QByteArray enc = QByteArray::fromBase64(encText.toLatin1());

    DATA_BLOB DataIn;
    DATA_BLOB DataOut;
    BYTE *pbDataInput = reinterpret_cast<BYTE *>(enc.data());
    DWORD cbDataInput = static_cast<DWORD>(enc.length());
    DataIn.pbData = pbDataInput;
    DataIn.cbData = cbDataInput;


    if (CryptUnprotectData(
            &DataIn,
            nullptr,
            nullptr,                 // Optional entropy
            nullptr,                 // Reserved
            nullptr,        // Optional PromptStruct
            0,
            &DataOut))
    {
        QByteArray dec(reinterpret_cast<char*>(DataOut.pbData), static_cast<int>(DataOut.cbData));
        QString decText = QString::fromUtf8(dec);
        LocalFree(DataOut.pbData);
        return decText;
    }
    else
    {
        qDebug() << "Windows decryption error!";
    }

    return defaultValue;
}

#else

void AppSettings::setValueNV(const QString &key, const QVariant &value) {
    QSettings::setValue(key, value);
}

QVariant AppSettings::valueNV(const QString &key, const QVariant &defaultValue) const {
    return QSettings::value(key, defaultValue);
}

void AppSettings::setValueNVEC(const QString &key, const QVariant &value) {
    QSettings::setValue(key, value);
}

QVariant AppSettings::valueNVEC(const QString &key, const QVariant &defaultValue) const {
    return QSettings::value(key, defaultValue);
}

#endif
