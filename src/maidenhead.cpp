// SPDX-License-Identifier: LGPL-3.0-or-later

#include "maidenhead.h"

#include <QGeoCoordinate>
#include <QString>

namespace maidenhead {

QString fromGeoCoordinate(const QGeoCoordinate& coord)
{
    return fromLatLon(coord.latitude(), coord.longitude());
}

QString fromLatLon(double lat, double lon)
{
    static const QString alphabet = "ABCDEFGHIJKLMNOPQRSTUVWX";
    static const QString numbers = "0123456789";

    lat = qBound(0.0, lat + 90.0, 180.0);
    lon = qBound(0.0, lon + 180.0, 360.0);

    QString result {6, QChar::Space};
    result[0] = alphabet.at(int(lon/20));
    result[1] = alphabet.at(int(lat/10));
    result[2] = numbers.at(int((lon/2))%10);
    result[3] = numbers.at(int(lat)%10);
    double lat_remainder = (lat - int(lat)) * 60;
    double lon_remainder = ((lon) - int(lon/2)*2) * 60;
    result[4] = alphabet.at(int(lon_remainder/5));
    result[5] = alphabet.at(int(lat_remainder/2.5));
    return result;
}

QGeoCoordinate toGeoCoordinate(QString gridsquare)
{
    if (gridsquare.isEmpty())
        return {};

    const auto bytes = gridsquare.toUpper().toUtf8();
    double lat = (bytes[1] - 'A') * 10 + (bytes[3] - '0')     + (bytes[5] - 'A' + 0.5) * 2.5 / 60.0 - 90.0;
    double lon = (bytes[0] - 'A') * 20 + (bytes[2] - '0') * 2 + (bytes[4] - 'A' + 0.5) * 5.0 / 60.0 - 180.0;
    return { lat, lon };
}

}  // namespace maidenhead
