// SPDX-License-Identifier: LGPL-3.0-or-later

#include "cacheddata.h"

#include <QByteArray>
#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QSettings>
#include <QStandardPaths>
#include <QString>

namespace cachedData {


namespace {

QString cacheFileName(const QString& identifier)
{
    return QLatin1String("cachedData.") + identifier;
}

QString cacheSettingsKey(const QString& identifier)
{
    return QLatin1String("cachedData/stamp/") + identifier;
}

}  // namespace


bool save(const QString& identifier, const QByteArray& data)
{
    const auto cache_dir = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    if (!cache_dir.isEmpty() && QDir::root().mkpath(cache_dir))
    {
        QFile file {cache_dir + '/' + cacheFileName(identifier)};
        file.open(QIODevice::WriteOnly | QIODevice::Truncate) && file.write(data);
        if (!file.error())
        {
            qDebug("SAVED %s to %s", qPrintable(identifier), qPrintable(cache_dir));
            QSettings().setValue(cacheSettingsKey(identifier), QDateTime::currentDateTimeUtc());
            return true;
        }
    }
    return false;
}

bool restore(const QString& identifier, QByteArray &data, int max_age)
{
    if (max_age)
    {
        auto stamp = QSettings().value(cacheSettingsKey(identifier)).toDateTime();
        if (!stamp.isValid() || qAbs(stamp.secsTo(QDateTime::currentDateTimeUtc())) > max_age)
            return false;
    }

    const auto cache_dir = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    QFile file {cache_dir + '/' + cacheFileName(identifier)};
    if (!cache_dir.isEmpty() && file.open(QIODevice::ReadOnly))
    {
        auto buffer = file.readAll();
        if (!file.error())
        {
            data = buffer;
            qDebug("RESTORED %s from %s", qPrintable(identifier), qPrintable(cache_dir));
            return true;
        }
    }
    return false;
}

};  // namespace cacheddata
