#include "sharedpreferences.h"

#include <QUuid>

#define JCLASS_Name "net/ludwigpro/android/ClubMap/PrefHelper"

static QVariantMap createVariantMap(jobject data);
static jobject convertToJObject(QVariant v);
static jobject createHashMap(const QVariantMap &data);

static SharedPreferences * m_instance = nullptr;

void SharedPreferences::init(){
    SharedPreferences::instance();
}

SharedPreferences *SharedPreferences::instance()
{
    if (m_instance == nullptr) {
        QCoreApplication* app = QCoreApplication::instance();
        auto id = QUuid::createUuid().toString();
        m_instance = new SharedPreferences(id, app);
    }

    return m_instance;
}

SharedPreferences::SharedPreferences(const QString &id, QObject *parent) :
    QObject(parent),
    _id(id),
    _data()
{
//    QAndroidJniEnvironment env;
//    clazz = env->FindClass(JCLASS_Name);

//    if (!clazz) {
//        qDebug() << "Can't find class : " << JCLASS_Name << ". Did init() be called within JNI_onLoad?";
//    } else {
//        JNINativeMethod methods[] =
//        {
//           {"callc", "(Ljava/lang/String;Ljava/util/Map;)V", (void *)&SharedPreferences::dispatched},
//        };

//        // Register the native methods.
//        int numMethods = sizeof(methods) / sizeof(methods[0]);
//        if (env->RegisterNatives(clazz, methods, numMethods) < 0) {
//           if (env->ExceptionOccurred()) {
//               env->ExceptionDescribe();
//               env->ExceptionClear();
//               qCritical() << "Exception in native method registration";
//           }
//        }
//   }
}

SharedPreferences::~SharedPreferences()
{
    QAndroidJniObject jId = QAndroidJniObject::fromString(_id);
    QAndroidJniObject::callStaticObjectMethod(JCLASS_Name, "remPrefs",
                                                        "(Ljava/lang/String;)V",
                                                        jId.object<jstring>());

}

SharedPreferences *SharedPreferences::getPreferences()
{
    QAndroidJniObject jId = QAndroidJniObject::fromString(instance()->_id);
    QAndroidJniObject::callStaticObjectMethod(JCLASS_Name, "getPrefs",
                                                        "(Ljava/lang/String;)V",
                                                        jId.object<jstring>());
    return instance();
}

//SharedPreferences *SharedPreferences::getSharedPreferences(const QString &name)
//{
//    QAndroidJniObject jId = QAndroidJniObject::fromString(instance()->_id);
//    QAndroidJniObject jName = QAndroidJniObject::fromString(name);
//    QAndroidJniObject::callStaticObjectMethod(JCLASS_Name, "getSharedPrefs",
//                                                        "(Ljava/lang/String;Ljava/lang/String;)V",
//                                                        jId.object<jstring>(), jName.object<jstring>());
//    return instance();
//}

//SharedPreferences *SharedPreferences::getSharedPreferencesPackage(const QString &name, const QString &packageName)
//{
//    QAndroidJniObject jId = QAndroidJniObject::fromString(instance()->_id);
//    QAndroidJniObject jName = QAndroidJniObject::fromString(name);
//    QAndroidJniObject jPackageName = QAndroidJniObject::fromString(packageName);
//    QAndroidJniObject::callStaticObjectMethod(JCLASS_Name, "getSharedPrefsPackage",
//                                                        "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V",
//                                                        jId.object<jstring>(), jName.object<jstring>(), jPackageName.object<jstring>());
//    return instance();
//}

QStringList SharedPreferences::keys() const
{
    return _data.keys();
}

bool SharedPreferences::contains(const QString &key) const
{
    return _data.contains(key);
}

QVariant SharedPreferences::value(const QString &key) const
{
    return _data.value(key);
}

QVariantMap SharedPreferences::data() const
{
    return _data;
}

void SharedPreferences::setValue(const QString &key, const QVariant &value)
{
    _data.insert(key, value);

    QAndroidJniObject jId = QAndroidJniObject::fromString(_id);
    QAndroidJniObject jKey = QAndroidJniObject::fromString(key);
    QAndroidJniObject jValue = convertToJObject(value);
    QAndroidJniObject::callStaticObjectMethod(JCLASS_Name, "save",
                                                        "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)V",
                                                        jId.object<jstring>(), jKey.object<jstring>(), jValue.object());

    emit changed(key, value);
}

void SharedPreferences::remove(const QString &key)
{
    _data.remove(key);
    QAndroidJniObject jId = QAndroidJniObject::fromString(_id);
    QAndroidJniObject jKey = QAndroidJniObject::fromString(key);
    QAndroidJniObject::callStaticObjectMethod(JCLASS_Name, "remove",
                                                        "(Ljava/lang/String;Ljava/lang/String;)V",
                                                        jId.object<jstring>(), jKey.object<jstring>());

    emit changed(key, QVariant());
}

static QVariant convertToQVariant(QAndroidJniObject value) {
    QVariant v;
    if (!value.isValid()) {
        return v;
    }

    QAndroidJniEnvironment env;

    jclass jclass_of_string = env->FindClass("java/lang/String");
    jclass jclass_of_integer = env->FindClass("java/lang/Integer");
    jclass jclass_of_long = env->FindClass("java/lang/Long");
    jclass jclass_of_float = env->FindClass("java/lang/Float");
    jclass jclass_of_double = env->FindClass("java/lang/Double");
    jclass jclass_of_boolean = env->FindClass("java/lang/Boolean");
    jclass jclass_of_list = env->FindClass("java/util/List");
    jclass jclass_of_map = env->FindClass("java/util/Map");

    if (env->IsInstanceOf(value.object<jobject>(),jclass_of_boolean)) {
        v = QVariant::fromValue<bool>(value.callMethod<jboolean>("booleanValue","()Z"));
    } else if (env->IsInstanceOf(value.object<jobject>(),jclass_of_integer)) {
        v = value.callMethod<jint>("intValue","()I");
    } else if (env->IsInstanceOf(value.object<jobject>(),jclass_of_string)) {
        v = value.toString();
    } else if (env->IsInstanceOf(value.object<jobject>(),jclass_of_long)) {
        v = value.callMethod<jlong>("longValue","()J");
    } else if (env->IsInstanceOf(value.object<jobject>(),jclass_of_float)) {
        v = value.callMethod<jfloat>("floatValue","()F");
    } else if (env->IsInstanceOf(value.object<jobject>(),jclass_of_double)) {
        v = value.callMethod<jdouble>("doubleValue","()D");
    } else if (env->IsInstanceOf(value.object<jobject>(), jclass_of_map)) {
        v = createVariantMap(value.object<jobject>());
    } else if (env->IsInstanceOf(value.object<jobject>(),jclass_of_list)) {
        QVariantList list;
        int count = value.callMethod<jint>("size","()I");
        for (int i = 0 ; i < count ; i++) {
            QAndroidJniObject item = value.callObjectMethod("get","(I)Ljava/lang/Object;",i);
            list.append(convertToQVariant(item));
        }
        v = list;
    } else {
         qWarning() << "value is not an instance of any of the handled jclass types\n";
    }

    env->DeleteLocalRef(jclass_of_string);
    env->DeleteLocalRef(jclass_of_integer);
    env->DeleteLocalRef(jclass_of_long);
    env->DeleteLocalRef(jclass_of_float);
    env->DeleteLocalRef(jclass_of_double);
    env->DeleteLocalRef(jclass_of_boolean);
    env->DeleteLocalRef(jclass_of_list);
    env->DeleteLocalRef(jclass_of_map);

    return v;
}

static QVariantMap createVariantMap(jobject data) {
    QVariantMap res;

    QAndroidJniEnvironment env;
    /* Reference : https://community.oracle.com/thread/1549999 */

    // Get the HashMap Class
    jclass jclass_of_hashmap = (env)->GetObjectClass(data);

    // Get link to Method "entrySet"
    jmethodID entrySetMethod = (env)->GetMethodID(jclass_of_hashmap, "entrySet", "()Ljava/util/Set;");

    // Invoke the "entrySet" method on the HashMap object
    jobject jobject_of_entryset = env->CallObjectMethod(data, entrySetMethod);

    // Get the Set Class
    jclass jclass_of_set = (env)->FindClass("java/util/Set"); // Problem during compilation !!!!!

    if (jclass_of_set == nullptr) {
         qWarning() << "java/util/Set lookup failed\n";
         return res;
    }

    // Get link to Method "iterator"
    jmethodID iteratorMethod = env->GetMethodID(jclass_of_set, "iterator", "()Ljava/util/Iterator;");

    // Invoke the "iterator" method on the jobject_of_entryset variable of type Set
    jobject jobject_of_iterator = env->CallObjectMethod(jobject_of_entryset, iteratorMethod);

    // Get the "Iterator" class
    jclass jclass_of_iterator = (env)->FindClass("java/util/Iterator");

    // Get link to Method "hasNext"
    jmethodID hasNextMethod = env->GetMethodID(jclass_of_iterator, "hasNext", "()Z");

    jmethodID nextMethod = env->GetMethodID(jclass_of_iterator, "next", "()Ljava/lang/Object;");

    while (env->CallBooleanMethod(jobject_of_iterator, hasNextMethod) ) {
        jobject jEntry = env->CallObjectMethod(jobject_of_iterator,nextMethod);
        QAndroidJniObject entry = QAndroidJniObject(jEntry);
        QAndroidJniObject key = entry.callObjectMethod("getKey","()Ljava/lang/Object;");
        QAndroidJniObject value = entry.callObjectMethod("getValue","()Ljava/lang/Object;");
        QString k = key.toString();

        QVariant v = convertToQVariant(value);

        env->DeleteLocalRef(jEntry);

        if (v.isNull()) {
            continue;
        }

        res[k] = v;
    }

    if (env->ExceptionOccurred()) {
        env->ExceptionDescribe();
        env->ExceptionClear();
    }

    env->DeleteLocalRef(jclass_of_hashmap);
    env->DeleteLocalRef(jobject_of_entryset);
    env->DeleteLocalRef(jclass_of_set);
    env->DeleteLocalRef(jobject_of_iterator);
    env->DeleteLocalRef(jclass_of_iterator);

    return res;
}

static jobject convertToJObject(QVariant v) {
    jobject res = nullptr;
    QAndroidJniEnvironment env;

    if (v.type() == QVariant::String) {
        QString str = v.toString();
        res = env->NewStringUTF(str.toLocal8Bit().data());
    } else if (v.type() == QVariant::Int) {
        jclass integerClass = env->FindClass("java/lang/Integer");
        jmethodID integerConstructor = env->GetMethodID(integerClass, "<init>", "(I)V");

        res = env->NewObject(integerClass,integerConstructor,v.toInt());

        env->DeleteLocalRef(integerClass);
    } else if (v.type() == QVariant::LongLong) {
        jclass longClass = env->FindClass("java/lang/Long");
        jmethodID longConstructor = env->GetMethodID( longClass, "<init>", "(J)V");

        res = env->NewObject(longClass,longConstructor, v.toLongLong()  );

        env->DeleteLocalRef(longClass);

    } else if (v.type() == QVariant::Double) {
        jclass doubleClass = env->FindClass("java/lang/Double");
        jmethodID doubleConstructor = env->GetMethodID( doubleClass, "<init>", "(D)V");

        res = env->NewObject(doubleClass,doubleConstructor,v.toDouble());

        env->DeleteLocalRef(doubleClass);

    } else if (v.type() == QVariant::Bool) {
        jclass booleanClass = env->FindClass("java/lang/Boolean");
        jmethodID booleanConstructor = env->GetMethodID(booleanClass,"<init>","(Z)V");

        res = env->NewObject(booleanClass,booleanConstructor,v.toBool());

        env->DeleteLocalRef(booleanClass);

    } else if (v.type() == QVariant::Map) {
        res = createHashMap(v.toMap());
    } else  if (v.type() == QVariant::List){
        QVariantList list = v.value<QVariantList>();
        jclass arrayListClass = env->FindClass("java/util/ArrayList");
        jmethodID init = env->GetMethodID(arrayListClass, "<init>", "(I)V");
        res = env->NewObject( arrayListClass, init, list.size());

        jmethodID add = env->GetMethodID( arrayListClass, "add",
                    "(Ljava/lang/Object;)Z");

        for (int i = 0 ; i < list.size() ; i++) {
            jobject item = convertToJObject(list.at(i));
            env->CallBooleanMethod(res,add, item);
            env->DeleteLocalRef(item);
        }

        env->DeleteLocalRef(arrayListClass);
    } else {
        qWarning() << "ANSystemDispatcher: Non-supported data type - " <<  v.type();
    }
    return res;
}

static jobject createHashMap(const QVariantMap &data) {
    QAndroidJniEnvironment env;

    jclass mapClass = env->FindClass("java/util/HashMap");

    if (mapClass == nullptr)  {
        qWarning() << "Failed to find class" << "java/util/HashMap";
        return nullptr;
    }

    jsize map_len = data.size();

    jmethodID init = env->GetMethodID(mapClass, "<init>", "(I)V");
    jobject hashMap = env->NewObject( mapClass, init, map_len);

    jmethodID put = env->GetMethodID( mapClass, "put",
                "(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;");

    QMapIterator<QString, QVariant> iter(data);
    while (iter.hasNext()) {
        iter.next();

        QString key = iter.key();
        jstring jkey = env->NewStringUTF(key.toLocal8Bit().data());
        QVariant v = iter.value();
        jobject item = convertToJObject(v);

        if (item == nullptr) {
            continue;
        }

        env->CallObjectMethod(hashMap,put,jkey,item);
        env->DeleteLocalRef(item);
        env->DeleteLocalRef(jkey);
     }

    if (env->ExceptionOccurred()) {
        env->ExceptionDescribe();
        env->ExceptionClear();
    }

    env->DeleteLocalRef(mapClass);

    return hashMap;
}

extern "C" {
    JNIEXPORT void JNICALL Java_net_ludwigpro_android_ClubMap_PrefHelper_callc(JNIEnv env, jobject obj, jstring message, jobject data) {
        Q_UNUSED(env);
        Q_UNUSED(obj);
        Q_UNUSED(data);

        QString qMessage = QAndroidJniObject::fromLocalRef(message).toString();
        QVariantMap qData = createVariantMap(data);

//        qDebug() << "Callback from Java, message: " << qMessage;
//        qDebug() << "Callback from Java, data: " << qData.count();

        if (m_instance != nullptr) {
            if(qMessage == QStringLiteral("ClubMap.PrefHelper.changed.") + m_instance->_id) {
                auto key = qData.value(QStringLiteral("key")).toString();
                auto removed = qData.value(QStringLiteral("removed"), false).toBool();
                auto value = qData.value(QStringLiteral("value"));
                if(removed) {
                    if(m_instance->_data.remove(key) > 0) {}
                } else {
                    m_instance->_data.insert(key, value);
                }
            } else if(qMessage == QStringLiteral("ClubMap.PrefHelper.loaded.") + m_instance->_id) {
                m_instance->_data = qData;
            }
        }
    }
}
