#ifndef SHAREDPREFERENCES_H
#define SHAREDPREFERENCES_H

#include <QObject>

#include <QString>
#include <QVariant>
#include <QDebug>
#include <QCoreApplication>

#if defined(Q_OS_ANDROID)
#include <QtAndroidExtras/QtAndroid>
#include <QtAndroidExtras/QAndroidJniObject>
#include <QtAndroidExtras/QAndroidActivityResultReceiver>
#include <QtAndroidExtras/QAndroidJniEnvironment>
#endif

class SharedPreferences : public QObject
{
    Q_OBJECT

public:
    ~SharedPreferences();

    static void init();

    /// Returns the global SharedPreferences instance.
    static SharedPreferences* instance();

    static SharedPreferences *getPreferences();
    // static SharedPreferences *getSharedPreferences(const QString &name);
    // static SharedPreferences *getSharedPreferencesPackage(const QString &name, const QString &packageName);

    static void dispatched(const QString &message, const QVariantMap &data);

    Q_INVOKABLE QStringList keys() const;
    Q_INVOKABLE bool contains(const QString &key) const;
    Q_INVOKABLE QVariant value(const QString &key) const;

    Q_INVOKABLE QVariantMap data() const;

    QString _id;
    QVariantMap _data;

public slots:
    void setValue(const QString &key, const QVariant &value);
    void remove(const QString &key);

signals:
    void loaded();
    void changed(const QString &key, const QVariant &value);

private:

    explicit SharedPreferences(const QString &id, QObject *parent = nullptr);
};

#endif // SHAREDPREFERENCES_H
